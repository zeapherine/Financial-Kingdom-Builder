import { randomBytes, createHash } from 'crypto';
import { logger } from '../utils/logger-factory';
import { RedisConnection } from '../database/redis';

export interface SessionData {
  sessionId: string;
  userId: string;
  userAgent?: string;
  ipAddress?: string;
  loginTime: string;
  lastActivity: string;
  isActive: boolean;
  deviceInfo?: {
    platform?: string;
    browser?: string;
    version?: string;
    isMobile?: boolean;
  };
  permissions: string[];
  tier: number;
  metadata?: Record<string, any>;
}

export interface SessionConfig {
  maxSessions: number; // Maximum concurrent sessions per user
  sessionTTL: number; // Session timeout in seconds
  extendOnActivity: boolean; // Whether to extend session on activity
  requireDeviceFingerprint: boolean; // Whether to track device fingerprints
  cleanupInterval: number; // Cleanup interval in seconds
}

export interface CreateSessionOptions {
  userId: string;
  userAgent?: string;
  ipAddress?: string;
  deviceInfo?: SessionData['deviceInfo'];
  permissions: string[];
  tier: number;
  metadata?: Record<string, any>;
}

export class SessionManager {
  private config: SessionConfig;
  private redis: RedisConnection;

  constructor(config: SessionConfig, redis: RedisConnection) {
    this.config = config;
    this.redis = redis;
    this.validateConfig();
  }

  private validateConfig(): void {
    if (this.config.maxSessions < 1) {
      throw new Error('Maximum sessions must be at least 1');
    }

    if (this.config.sessionTTL < 300) {
      throw new Error('Session TTL must be at least 5 minutes (300 seconds)');
    }

    if (this.config.cleanupInterval < 60) {
      throw new Error('Cleanup interval must be at least 1 minute (60 seconds)');
    }
  }

  /**
   * Generate secure session ID
   */
  private generateSessionId(): string {
    return randomBytes(32).toString('hex');
  }

  /**
   * Create device fingerprint hash
   */
  private createDeviceFingerprint(userAgent?: string, deviceInfo?: SessionData['deviceInfo']): string {
    const fingerprintData = {
      userAgent: userAgent || '',
      platform: deviceInfo?.platform || '',
      browser: deviceInfo?.browser || '',
      version: deviceInfo?.version || ''
    };

    const fingerprintString = JSON.stringify(fingerprintData);
    return createHash('sha256').update(fingerprintString).digest('hex');
  }

  /**
   * Create new session
   */
  public async createSession(options: CreateSessionOptions): Promise<SessionData> {
    const sessionId = this.generateSessionId();
    const now = new Date().toISOString();
    
    const sessionData: SessionData = {
      sessionId,
      userId: options.userId,
      userAgent: options.userAgent,
      ipAddress: options.ipAddress,
      loginTime: now,
      lastActivity: now,
      isActive: true,
      deviceInfo: options.deviceInfo,
      permissions: options.permissions,
      tier: options.tier,
      metadata: options.metadata || {}
    };

    // Check and enforce session limits
    await this.enforceSessionLimits(options.userId);

    // Store session data
    const sessionKey = `session:${sessionId}`;
    await this.redis.setex(
      sessionKey,
      this.config.sessionTTL,
      JSON.stringify(sessionData)
    );

    // Add to user's active sessions
    const userSessionsKey = `user_sessions:${options.userId}`;
    await this.redis.sadd(userSessionsKey, sessionId);
    await this.redis.expire(userSessionsKey, this.config.sessionTTL);

    // Track by device fingerprint if enabled
    if (this.config.requireDeviceFingerprint && (options.userAgent || options.deviceInfo)) {
      const deviceFingerprint = this.createDeviceFingerprint(options.userAgent, options.deviceInfo);
      const deviceKey = `device:${deviceFingerprint}`;
      await this.redis.setex(deviceKey, this.config.sessionTTL, sessionId);
    }

    // Track IP address
    if (options.ipAddress) {
      const ipKey = `ip_sessions:${options.ipAddress}`;
      await this.redis.sadd(ipKey, sessionId);
      await this.redis.expire(ipKey, this.config.sessionTTL);
    }

    logger.info('Session created', {
      sessionId,
      userId: options.userId,
      ipAddress: options.ipAddress,
      userAgent: options.userAgent?.substring(0, 100)
    });

    return sessionData;
  }

  /**
   * Get session by ID
   */
  public async getSession(sessionId: string): Promise<SessionData | null> {
    try {
      const sessionKey = `session:${sessionId}`;
      const sessionDataJson = await this.redis.get(sessionKey);
      
      if (!sessionDataJson) {
        return null;
      }

      const sessionData: SessionData = JSON.parse(sessionDataJson);
      
      // Update last activity if configured
      if (this.config.extendOnActivity) {
        await this.updateLastActivity(sessionId);
      }

      return sessionData;
    } catch (error) {
      logger.error('Error getting session', {
        sessionId,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      return null;
    }
  }

  /**
   * Update session last activity
   */
  public async updateLastActivity(sessionId: string): Promise<void> {
    try {
      const sessionKey = `session:${sessionId}`;
      const sessionDataJson = await this.redis.get(sessionKey);
      
      if (!sessionDataJson) {
        return;
      }

      const sessionData: SessionData = JSON.parse(sessionDataJson);
      sessionData.lastActivity = new Date().toISOString();

      // Update session with extended TTL
      await this.redis.setex(
        sessionKey,
        this.config.sessionTTL,
        JSON.stringify(sessionData)
      );

      // Extend user sessions set TTL
      const userSessionsKey = `user_sessions:${sessionData.userId}`;
      await this.redis.expire(userSessionsKey, this.config.sessionTTL);
    } catch (error) {
      logger.error('Error updating session activity', {
        sessionId,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }

  /**
   * Invalidate session
   */
  public async invalidateSession(sessionId: string): Promise<void> {
    try {
      const sessionData = await this.getSession(sessionId);
      if (!sessionData) {
        return;
      }

      // Remove session
      const sessionKey = `session:${sessionId}`;
      await this.redis.del(sessionKey);

      // Remove from user sessions
      const userSessionsKey = `user_sessions:${sessionData.userId}`;
      await this.redis.srem(userSessionsKey, sessionId);

      // Remove from IP sessions
      if (sessionData.ipAddress) {
        const ipKey = `ip_sessions:${sessionData.ipAddress}`;
        await this.redis.srem(ipKey, sessionId);
      }

      // Remove device fingerprint mapping
      if (this.config.requireDeviceFingerprint && 
          (sessionData.userAgent || sessionData.deviceInfo)) {
        const deviceFingerprint = this.createDeviceFingerprint(
          sessionData.userAgent, 
          sessionData.deviceInfo
        );
        const deviceKey = `device:${deviceFingerprint}`;
        await this.redis.del(deviceKey);
      }

      logger.info('Session invalidated', {
        sessionId,
        userId: sessionData.userId
      });
    } catch (error) {
      logger.error('Error invalidating session', {
        sessionId,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      throw error;
    }
  }

  /**
   * Invalidate all user sessions
   */
  public async invalidateAllUserSessions(userId: string): Promise<number> {
    try {
      const userSessionsKey = `user_sessions:${userId}`;
      const sessionIds = await this.redis.smembers(userSessionsKey);
      
      if (sessionIds.length === 0) {
        return 0;
      }

      // Invalidate each session
      const invalidatePromises = sessionIds.map(sessionId => 
        this.invalidateSession(sessionId)
      );
      await Promise.all(invalidatePromises);

      // Clear user sessions set
      await this.redis.del(userSessionsKey);

      logger.info('All user sessions invalidated', {
        userId,
        invalidatedCount: sessionIds.length
      });

      return sessionIds.length;
    } catch (error) {
      logger.error('Error invalidating all user sessions', {
        userId,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      throw error;
    }
  }

  /**
   * Get all active sessions for user
   */
  public async getUserSessions(userId: string): Promise<SessionData[]> {
    try {
      const userSessionsKey = `user_sessions:${userId}`;
      const sessionIds = await this.redis.smembers(userSessionsKey);
      
      if (sessionIds.length === 0) {
        return [];
      }

      const sessionPromises = sessionIds.map(sessionId => this.getSession(sessionId));
      const sessions = await Promise.all(sessionPromises);
      
      // Filter out null sessions and return valid ones
      return sessions.filter((session): session is SessionData => session !== null);
    } catch (error) {
      logger.error('Error getting user sessions', {
        userId,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      return [];
    }
  }

  /**
   * Enforce session limits per user
   */
  private async enforceSessionLimits(userId: string): Promise<void> {
    const sessions = await this.getUserSessions(userId);
    
    if (sessions.length >= this.config.maxSessions) {
      // Sort by last activity (oldest first)
      sessions.sort((a, b) => new Date(a.lastActivity).getTime() - new Date(b.lastActivity).getTime());
      
      // Remove oldest sessions to make room
      const sessionsToRemove = sessions.slice(0, sessions.length - this.config.maxSessions + 1);
      
      for (const session of sessionsToRemove) {
        await this.invalidateSession(session.sessionId);
      }

      logger.info('Session limit enforced', {
        userId,
        removedSessions: sessionsToRemove.length,
        maxSessions: this.config.maxSessions
      });
    }
  }

  /**
   * Check if session exists and is valid
   */
  public async isValidSession(sessionId: string): Promise<boolean> {
    const session = await this.getSession(sessionId);
    return session !== null && session.isActive;
  }

  /**
   * Get session count by IP address (for security monitoring)
   */
  public async getSessionCountByIP(ipAddress: string): Promise<number> {
    try {
      const ipKey = `ip_sessions:${ipAddress}`;
      return await this.redis.scard(ipKey);
    } catch (error) {
      logger.error('Error getting session count by IP', {
        ipAddress,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      return 0;
    }
  }

  /**
   * Clean up expired sessions (maintenance task)
   */
  public async cleanupExpiredSessions(): Promise<number> {
    try {
      let cleanedCount = 0;
      const pattern = 'session:*';
      let cursor = '0';

      do {
        const result = await this.redis.scan(cursor, 'MATCH', pattern, 'COUNT', '100');
        cursor = result[0];
        const keys = result[1];

        for (const key of keys) {
          const ttl = await this.redis.ttl(key);
          if (ttl === -2) { // Key expired
            const sessionId = key.replace('session:', '');
            await this.invalidateSession(sessionId);
            cleanedCount++;
          }
        }
      } while (cursor !== '0');

      logger.info('Session cleanup completed', { cleanedCount });
      return cleanedCount;
    } catch (error) {
      logger.error('Session cleanup failed', {
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      return 0;
    }
  }

  /**
   * Update session metadata
   */
  public async updateSessionMetadata(sessionId: string, metadata: Record<string, any>): Promise<void> {
    try {
      const sessionKey = `session:${sessionId}`;
      const sessionDataJson = await this.redis.get(sessionKey);
      
      if (!sessionDataJson) {
        throw new Error('Session not found');
      }

      const sessionData: SessionData = JSON.parse(sessionDataJson);
      sessionData.metadata = { ...sessionData.metadata, ...metadata };

      await this.redis.setex(
        sessionKey,
        this.config.sessionTTL,
        JSON.stringify(sessionData)
      );
    } catch (error) {
      logger.error('Error updating session metadata', {
        sessionId,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      throw error;
    }
  }

  /**
   * Health check for session manager
   */
  public async healthCheck(): Promise<{ status: string; message: string; stats: any }> {
    try {
      // Test Redis connection
      await this.redis.ping();
      
      // Get session statistics
      const pattern = 'session:*';
      const keys = await this.redis.keys(pattern);
      const activeSessionCount = keys.length;

      // Test session creation and retrieval
      const testSession = await this.createSession({
        userId: 'health-check-user',
        permissions: ['read'],
        tier: 1,
        metadata: { test: true }
      });

      const retrievedSession = await this.getSession(testSession.sessionId);
      await this.invalidateSession(testSession.sessionId);

      if (!retrievedSession) {
        throw new Error('Session creation/retrieval test failed');
      }

      return {
        status: 'healthy',
        message: 'Session manager operational',
        stats: {
          activeSessionCount,
          maxSessions: this.config.maxSessions,
          sessionTTL: this.config.sessionTTL
        }
      };
    } catch (error) {
      logger.error('Session manager health check failed', {
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      return {
        status: 'unhealthy',
        message: 'Session manager not operational',
        stats: null
      };
    }
  }
}

/**
 * Create session manager with environment configuration
 */
export function createSessionManager(redis: RedisConnection): SessionManager {
  const config: SessionConfig = {
    maxSessions: parseInt(process.env.SESSION_MAX_SESSIONS || '5'),
    sessionTTL: parseInt(process.env.SESSION_TTL || '3600'), // 1 hour default
    extendOnActivity: process.env.SESSION_EXTEND_ON_ACTIVITY !== 'false',
    requireDeviceFingerprint: process.env.SESSION_REQUIRE_DEVICE_FINGERPRINT === 'true',
    cleanupInterval: parseInt(process.env.SESSION_CLEANUP_INTERVAL || '300') // 5 minutes
  };

  return new SessionManager(config, redis);
}