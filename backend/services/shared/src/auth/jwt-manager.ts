import jwt, { JwtPayload, SignOptions, VerifyOptions } from 'jsonwebtoken';
import { randomBytes, createHash } from 'crypto';
import { logger } from '../utils/logger-factory';
import { RedisConnection } from '../database/redis';

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  refreshExpiresIn: number;
}

export interface JWTPayload extends JwtPayload {
  userId: string;
  email: string;
  username: string;
  tier: number;
  permissions: string[];
  tokenType: 'access' | 'refresh';
  jti: string; // JWT ID for token tracking
}

export interface TokenConfig {
  accessTokenSecret: string;
  refreshTokenSecret: string;
  accessTokenExpiry: string; // e.g., '15m'
  refreshTokenExpiry: string; // e.g., '7d'
  issuer: string;
  audience: string;
}

export class JWTManager {
  private config: TokenConfig;
  private redis: RedisConnection;

  constructor(config: TokenConfig, redis: RedisConnection) {
    this.config = config;
    this.redis = redis;
    this.validateConfig();
  }

  private validateConfig(): void {
    const required = [
      'accessTokenSecret',
      'refreshTokenSecret',
      'accessTokenExpiry',
      'refreshTokenExpiry',
      'issuer',
      'audience'
    ];

    for (const field of required) {
      if (!this.config[field as keyof TokenConfig]) {
        throw new Error(`JWT configuration missing required field: ${field}`);
      }
    }

    // Validate token secrets are different
    if (this.config.accessTokenSecret === this.config.refreshTokenSecret) {
      throw new Error('Access and refresh token secrets must be different');
    }

    // Validate secret strength (minimum 32 characters)
    if (this.config.accessTokenSecret.length < 32 || this.config.refreshTokenSecret.length < 32) {
      throw new Error('JWT secrets must be at least 32 characters long');
    }
  }

  /**
   * Generate a secure JWT ID
   */
  private generateJTI(): string {
    return randomBytes(16).toString('hex');
  }

  /**
   * Create access token hash for Redis storage
   */
  private createTokenHash(token: string): string {
    return createHash('sha256').update(token).digest('hex');
  }

  /**
   * Generate token pair (access + refresh tokens)
   */
  public async generateTokenPair(payload: {
    userId: string;
    email: string;
    username: string;
    tier: number;
    permissions: string[];
  }): Promise<TokenPair> {
    const accessJTI = this.generateJTI();
    const refreshJTI = this.generateJTI();

    const basePayload = {
      ...payload,
      iss: this.config.issuer,
      aud: this.config.audience
    };

    // Create access token
    const accessTokenPayload: Partial<JWTPayload> = {
      ...basePayload,
      tokenType: 'access' as const,
      jti: accessJTI
    };

    const accessTokenOptions: SignOptions = {
      expiresIn: this.config.accessTokenExpiry,
      algorithm: 'HS256'
    } as SignOptions;

    const accessToken = jwt.sign(accessTokenPayload, this.config.accessTokenSecret, accessTokenOptions);

    // Create refresh token (minimal payload for security)
    const refreshTokenPayload: Partial<JWTPayload> = {
      userId: payload.userId,
      tokenType: 'refresh' as const,
      jti: refreshJTI,
      iss: this.config.issuer,
      aud: this.config.audience
    };

    const refreshTokenOptions: SignOptions = {
      expiresIn: this.config.refreshTokenExpiry,
      algorithm: 'HS256'
    } as SignOptions;

    const refreshToken = jwt.sign(refreshTokenPayload, this.config.refreshTokenSecret, refreshTokenOptions);

    // Store refresh token hash in Redis with user association
    const refreshTokenHash = this.createTokenHash(refreshToken);
    const refreshExpiry = this.parseTokenExpiry(this.config.refreshTokenExpiry);
    
    await this.redis.setex(
      `refresh_token:${refreshTokenHash}`,
      refreshExpiry,
      JSON.stringify({
        userId: payload.userId,
        jti: refreshJTI,
        createdAt: new Date().toISOString()
      })
    );

    // Store active session mapping
    await this.redis.sadd(`user_sessions:${payload.userId}`, refreshTokenHash);
    await this.redis.expire(`user_sessions:${payload.userId}`, refreshExpiry);

    const accessExpiry = this.parseTokenExpiry(this.config.accessTokenExpiry);

    logger.info('Token pair generated', {
      userId: payload.userId,
      accessJTI,
      refreshJTI,
      accessExpiry: `${accessExpiry}s`,
      refreshExpiry: `${refreshExpiry}s`
    });

    return {
      accessToken,
      refreshToken,
      expiresIn: accessExpiry,
      refreshExpiresIn: refreshExpiry
    };
  }

  /**
   * Verify and decode access token
   */
  public async verifyAccessToken(token: string): Promise<JWTPayload> {
    try {
      const verifyOptions: VerifyOptions = {
        issuer: this.config.issuer,
        audience: this.config.audience,
        algorithms: ['HS256']
      };

      const decoded = jwt.verify(token, this.config.accessTokenSecret, verifyOptions) as JWTPayload;

      if (decoded.tokenType !== 'access') {
        throw new Error('Invalid token type');
      }

      return decoded;
    } catch (error) {
      logger.warn('Access token verification failed', {
        error: error instanceof Error ? error.message : 'Unknown error',
        tokenPrefix: token.substring(0, 20) + '...'
      });
      throw new Error('Invalid access token');
    }
  }

  /**
   * Verify and decode refresh token
   */
  public async verifyRefreshToken(token: string): Promise<JWTPayload> {
    try {
      const verifyOptions: VerifyOptions = {
        issuer: this.config.issuer,
        audience: this.config.audience,
        algorithms: ['HS256']
      };

      const decoded = jwt.verify(token, this.config.refreshTokenSecret, verifyOptions) as JWTPayload;

      if (decoded.tokenType !== 'refresh') {
        throw new Error('Invalid token type');
      }

      // Verify token exists in Redis
      const tokenHash = this.createTokenHash(token);
      const storedData = await this.redis.get(`refresh_token:${tokenHash}`);
      
      if (!storedData) {
        throw new Error('Refresh token not found or expired');
      }

      const parsedData = JSON.parse(storedData);
      if (parsedData.userId !== decoded.userId || parsedData.jti !== decoded.jti) {
        throw new Error('Token validation failed');
      }

      return decoded;
    } catch (error) {
      logger.warn('Refresh token verification failed', {
        error: error instanceof Error ? error.message : 'Unknown error',
        tokenPrefix: token.substring(0, 20) + '...'
      });
      throw new Error('Invalid refresh token');
    }
  }

  /**
   * Refresh token pair using refresh token
   */
  public async refreshTokenPair(refreshToken: string, userPayload: {
    email: string;
    username: string;
    tier: number;
    permissions: string[];
  }): Promise<TokenPair> {
    // Verify refresh token
    const decoded = await this.verifyRefreshToken(refreshToken);

    // Revoke old refresh token
    await this.revokeRefreshToken(refreshToken);

    // Generate new token pair
    const newTokenPair = await this.generateTokenPair({
      userId: decoded.userId,
      ...userPayload
    });

    logger.info('Token pair refreshed', {
      userId: decoded.userId,
      oldJTI: decoded.jti
    });

    return newTokenPair;
  }

  /**
   * Revoke a specific refresh token
   */
  public async revokeRefreshToken(refreshToken: string): Promise<void> {
    try {
      const decoded = await this.verifyRefreshToken(refreshToken);
      const tokenHash = this.createTokenHash(refreshToken);

      // Remove from Redis
      await this.redis.del(`refresh_token:${tokenHash}`);
      
      // Remove from user sessions
      await this.redis.srem(`user_sessions:${decoded.userId}`, tokenHash);

      logger.info('Refresh token revoked', {
        userId: decoded.userId,
        jti: decoded.jti
      });
    } catch (error) {
      // Token might already be invalid/expired, log warning but don't throw
      logger.warn('Failed to revoke refresh token', {
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }

  /**
   * Revoke all refresh tokens for a user
   */
  public async revokeAllUserTokens(userId: string): Promise<void> {
    try {
      const sessionTokens = await this.redis.smembers(`user_sessions:${userId}`);
      
      if (sessionTokens.length > 0) {
        // Delete all refresh tokens
        const deletePromises = sessionTokens.map(tokenHash => 
          this.redis.del(`refresh_token:${tokenHash}`)
        );
        await Promise.all(deletePromises);

        // Clear user sessions set
        await this.redis.del(`user_sessions:${userId}`);
      }

      logger.info('All user tokens revoked', {
        userId,
        revokedCount: sessionTokens.length
      });
    } catch (error) {
      logger.error('Failed to revoke all user tokens', {
        userId,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      throw error;
    }
  }

  /**
   * Get active session count for user
   */
  public async getUserSessionCount(userId: string): Promise<number> {
    try {
      return await this.redis.scard(`user_sessions:${userId}`);
    } catch (error) {
      logger.error('Failed to get user session count', {
        userId,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      return 0;
    }
  }

  /**
   * Cleanup expired tokens (maintenance task)
   */
  public async cleanupExpiredTokens(): Promise<number> {
    try {
      let cleanedCount = 0;
      const pattern = 'refresh_token:*';
      let cursor = '0';

      do {
        const result = await this.redis.scan(cursor, 'MATCH', pattern, 'COUNT', '100');
        cursor = result[0];
        const keys = result[1];

        for (const key of keys) {
          const ttl = await this.redis.ttl(key);
          if (ttl === -2) { // Key expired
            await this.redis.del(key);
            cleanedCount++;
          }
        }
      } while (cursor !== '0');

      logger.info('Token cleanup completed', { cleanedCount });
      return cleanedCount;
    } catch (error) {
      logger.error('Token cleanup failed', {
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      return 0;
    }
  }

  /**
   * Parse token expiry string to seconds
   */
  private parseTokenExpiry(expiry: string): number {
    const match = expiry.match(/^(\d+)([smhd])$/);
    if (!match) {
      throw new Error(`Invalid token expiry format: ${expiry}`);
    }

    const value = parseInt(match[1]);
    const unit = match[2];

    const multipliers = {
      s: 1,
      m: 60,
      h: 3600,
      d: 86400
    };

    return value * multipliers[unit as keyof typeof multipliers];
  }

  /**
   * Health check for JWT manager
   */
  public async healthCheck(): Promise<{ status: string; message: string }> {
    try {
      // Test Redis connection
      await this.redis.ping();
      
      // Test token generation
      const testPayload = {
        userId: 'health-check',
        email: 'test@example.com',
        username: 'healthcheck',
        tier: 1,
        permissions: ['read']
      };

      const tokens = await this.generateTokenPair(testPayload);
      await this.verifyAccessToken(tokens.accessToken);
      await this.revokeRefreshToken(tokens.refreshToken);

      return {
        status: 'healthy',
        message: 'JWT manager operational'
      };
    } catch (error) {
      logger.error('JWT manager health check failed', {
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      return {
        status: 'unhealthy',
        message: 'JWT manager not operational'
      };
    }
  }
}

/**
 * Create JWT manager instance with environment configuration
 */
export function createJWTManager(redis: RedisConnection): JWTManager {
  const config: TokenConfig = {
    accessTokenSecret: process.env.JWT_ACCESS_SECRET || '',
    refreshTokenSecret: process.env.JWT_REFRESH_SECRET || '',
    accessTokenExpiry: process.env.JWT_ACCESS_EXPIRY || '15m',
    refreshTokenExpiry: process.env.JWT_REFRESH_EXPIRY || '7d',
    issuer: process.env.JWT_ISSUER || 'financial-kingdom-builder',
    audience: process.env.JWT_AUDIENCE || 'financial-kingdom-users'
  };

  // Validate required environment variables
  if (!config.accessTokenSecret || !config.refreshTokenSecret) {
    throw new Error('JWT secrets must be provided via environment variables: JWT_ACCESS_SECRET, JWT_REFRESH_SECRET');
  }

  return new JWTManager(config, redis);
}