import { randomBytes, createHash } from 'crypto';
import { URLSearchParams } from 'url';
import axios, { AxiosInstance } from 'axios';
import { logger } from '../utils/logger-factory';
import { RedisConnection } from '../database/redis';

export interface OAuthConfig {
  clientId: string;
  clientSecret: string;
  redirectUri: string;
  scope: string[];
  authorizationUrl: string;
  tokenUrl: string;
  userInfoUrl?: string;
  revokeUrl?: string;
  provider: string;
  pkceEnabled: boolean;
  state: boolean;
}

export interface OAuthTokens {
  accessToken: string;
  refreshToken?: string;
  tokenType: string;
  expiresIn: number;
  scope?: string;
  expiresAt: Date;
}

export interface OAuthUserInfo {
  id: string;
  email?: string;
  name?: string;
  username?: string;
  avatar?: string;
  verified?: boolean;
  provider: string;
  raw?: Record<string, any>;
}

export interface OAuthAuthorizationRequest {
  state: string;
  codeVerifier?: string;
  codeChallenge?: string;
  redirectUri: string;
  scope: string[];
  provider: string;
  userId?: string;
  createdAt: Date;
  expiresAt: Date;
}

export interface OAuthTokenExchange {
  code: string;
  state: string;
  codeVerifier?: string;
}

export class OAuthManager {
  private config: OAuthConfig;
  private redis: RedisConnection;
  private httpClient!: AxiosInstance;

  constructor(config: OAuthConfig, redis: RedisConnection) {
    this.config = config;
    this.redis = redis;
    this.validateConfig();
    this.setupHttpClient();
  }

  private validateConfig(): void {
    const required = ['clientId', 'clientSecret', 'redirectUri', 'authorizationUrl', 'tokenUrl', 'provider'];
    
    for (const field of required) {
      if (!this.config[field as keyof OAuthConfig]) {
        throw new Error(`OAuth configuration missing required field: ${field}`);
      }
    }

    // Validate URLs
    try {
      new URL(this.config.authorizationUrl);
      new URL(this.config.tokenUrl);
      new URL(this.config.redirectUri);
      if (this.config.userInfoUrl) {
        new URL(this.config.userInfoUrl);
      }
    } catch (error) {
      throw new Error('Invalid URL in OAuth configuration');
    }

    // Validate scope
    if (!Array.isArray(this.config.scope) || this.config.scope.length === 0) {
      throw new Error('OAuth scope must be a non-empty array');
    }
  }

  private setupHttpClient(): void {
    this.httpClient = axios.create({
      timeout: 30000,
      headers: {
        'User-Agent': 'Financial-Kingdom-Builder/1.0',
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });

    // Add request/response interceptors for logging
    this.httpClient.interceptors.request.use(
      (config) => {
        logger.debug('OAuth HTTP request', {
          method: config.method,
          url: config.url,
          provider: this.config.provider
        });
        return config;
      },
      (error) => {
        logger.error('OAuth HTTP request error', { error: error.message });
        return Promise.reject(error);
      }
    );

    this.httpClient.interceptors.response.use(
      (response) => {
        logger.debug('OAuth HTTP response', {
          status: response.status,
          url: response.config.url,
          provider: this.config.provider
        });
        return response;
      },
      (error) => {
        logger.error('OAuth HTTP response error', {
          status: error.response?.status,
          url: error.config?.url,
          provider: this.config.provider,
          error: error.message
        });
        return Promise.reject(error);
      }
    );
  }

  /**
   * Generate secure random string
   */
  private generateSecureRandom(length: number = 32): string {
    return randomBytes(length).toString('base64url');
  }

  /**
   * Generate PKCE code verifier and challenge
   */
  private generatePKCE(): { codeVerifier: string; codeChallenge: string } {
    const codeVerifier = this.generateSecureRandom(32);
    const codeChallenge = createHash('sha256')
      .update(codeVerifier)
      .digest('base64url');
    
    return { codeVerifier, codeChallenge };
  }

  /**
   * Generate authorization URL for OAuth flow
   */
  public async generateAuthorizationUrl(userId?: string): Promise<{
    url: string;
    state: string;
    codeVerifier?: string;
  }> {
    const state = this.generateSecureRandom();
    let codeVerifier: string | undefined;
    let codeChallenge: string | undefined;

    // Generate PKCE parameters if enabled
    if (this.config.pkceEnabled) {
      const pkce = this.generatePKCE();
      codeVerifier = pkce.codeVerifier;
      codeChallenge = pkce.codeChallenge;
    }

    // Store authorization request in Redis
    const authRequest: OAuthAuthorizationRequest = {
      state,
      codeVerifier,
      codeChallenge,
      redirectUri: this.config.redirectUri,
      scope: this.config.scope,
      provider: this.config.provider,
      userId,
      createdAt: new Date(),
      expiresAt: new Date(Date.now() + 10 * 60 * 1000) // 10 minutes
    };

    await this.redis.setex(
      `oauth:auth:${state}`,
      10 * 60, // 10 minutes
      JSON.stringify(authRequest)
    );

    // Build authorization URL
    const params = new URLSearchParams({
      response_type: 'code',
      client_id: this.config.clientId,
      redirect_uri: this.config.redirectUri,
      scope: this.config.scope.join(' '),
      state
    });

    if (codeChallenge) {
      params.append('code_challenge', codeChallenge);
      params.append('code_challenge_method', 'S256');
    }

    const url = `${this.config.authorizationUrl}?${params.toString()}`;

    logger.info('OAuth authorization URL generated', {
      provider: this.config.provider,
      userId,
      state,
      pkceEnabled: this.config.pkceEnabled
    });

    return { url, state, codeVerifier };
  }

  /**
   * Exchange authorization code for tokens
   */
  public async exchangeCodeForTokens(exchange: OAuthTokenExchange): Promise<OAuthTokens> {
    // Retrieve and validate authorization request
    const authRequestData = await this.redis.get(`oauth:auth:${exchange.state}`);
    if (!authRequestData) {
      throw new Error('Invalid or expired authorization state');
    }

    const authRequest: OAuthAuthorizationRequest = JSON.parse(authRequestData);
    
    // Verify state and expiration
    if (authRequest.state !== exchange.state) {
      throw new Error('State parameter mismatch');
    }

    if (new Date() > authRequest.expiresAt) {
      throw new Error('Authorization request expired');
    }

    // PKCE verification
    if (this.config.pkceEnabled) {
      if (!authRequest.codeVerifier || !exchange.codeVerifier) {
        throw new Error('PKCE code verifier required');
      }
      if (authRequest.codeVerifier !== exchange.codeVerifier) {
        throw new Error('PKCE code verifier mismatch');
      }
    }

    // Prepare token exchange request
    const tokenParams = new URLSearchParams({
      grant_type: 'authorization_code',
      client_id: this.config.clientId,
      client_secret: this.config.clientSecret,
      code: exchange.code,
      redirect_uri: authRequest.redirectUri
    });

    if (this.config.pkceEnabled && exchange.codeVerifier) {
      tokenParams.append('code_verifier', exchange.codeVerifier);
    }

    try {
      const response = await this.httpClient.post(
        this.config.tokenUrl,
        tokenParams.toString(),
        {
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
          }
        }
      );

      const tokenData = response.data;
      
      // Validate token response
      if (!tokenData.access_token) {
        throw new Error('Access token not received from provider');
      }

      const tokens: OAuthTokens = {
        accessToken: tokenData.access_token,
        refreshToken: tokenData.refresh_token,
        tokenType: tokenData.token_type || 'Bearer',
        expiresIn: parseInt(tokenData.expires_in) || 3600,
        scope: tokenData.scope,
        expiresAt: new Date(Date.now() + (parseInt(tokenData.expires_in) || 3600) * 1000)
      };

      // Clean up authorization request
      await this.redis.del(`oauth:auth:${exchange.state}`);

      // Store tokens if refresh token is available
      if (tokens.refreshToken && authRequest.userId) {
        await this.storeTokens(authRequest.userId, tokens);
      }

      logger.info('OAuth tokens exchanged successfully', {
        provider: this.config.provider,
        userId: authRequest.userId,
        tokenType: tokens.tokenType,
        expiresIn: tokens.expiresIn
      });

      return tokens;

    } catch (error) {
      logger.error('OAuth token exchange failed', {
        provider: this.config.provider,
        error: error instanceof Error ? error.message : 'Unknown error',
        state: exchange.state
      });

      // Clean up authorization request on error
      await this.redis.del(`oauth:auth:${exchange.state}`);
      
      throw new Error(`Token exchange failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  /**
   * Get user information using access token
   */
  public async getUserInfo(accessToken: string): Promise<OAuthUserInfo> {
    if (!this.config.userInfoUrl) {
      throw new Error('User info URL not configured for this provider');
    }

    try {
      const response = await this.httpClient.get(this.config.userInfoUrl, {
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Accept': 'application/json'
        }
      });

      const userData = response.data;
      
      // Map provider-specific user data to standard format
      const userInfo: OAuthUserInfo = this.mapUserData(userData);

      logger.info('OAuth user info retrieved', {
        provider: this.config.provider,
        userId: userInfo.id,
        email: userInfo.email ? '[REDACTED]' : undefined
      });

      return userInfo;

    } catch (error) {
      logger.error('OAuth user info retrieval failed', {
        provider: this.config.provider,
        error: error instanceof Error ? error.message : 'Unknown error'
      });

      throw new Error(`User info retrieval failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  /**
   * Map provider-specific user data to standard format
   */
  private mapUserData(userData: any): OAuthUserInfo {
    // This would need to be customized for each OAuth provider
    // This is a generic implementation
    
    let userInfo: OAuthUserInfo = {
      id: userData.id || userData.sub || userData.user_id,
      provider: this.config.provider,
      raw: userData
    };

    // Common field mappings
    if (userData.email) userInfo.email = userData.email;
    if (userData.name) userInfo.name = userData.name;
    if (userData.username || userData.login) userInfo.username = userData.username || userData.login;
    if (userData.avatar_url || userData.picture) userInfo.avatar = userData.avatar_url || userData.picture;
    if (userData.email_verified !== undefined) userInfo.verified = userData.email_verified;

    // Provider-specific mappings
    switch (this.config.provider.toLowerCase()) {
      case 'github':
        userInfo.username = userData.login;
        userInfo.avatar = userData.avatar_url;
        break;
      case 'google':
        userInfo.name = userData.name;
        userInfo.avatar = userData.picture;
        userInfo.verified = userData.email_verified;
        break;
      case 'discord':
        userInfo.username = userData.username;
        userInfo.avatar = userData.avatar ? `https://cdn.discordapp.com/avatars/${userData.id}/${userData.avatar}.png` : undefined;
        userInfo.verified = userData.verified;
        break;
    }

    return userInfo;
  }

  /**
   * Refresh access tokens
   */
  public async refreshTokens(userId: string): Promise<OAuthTokens | null> {
    const storedTokens = await this.getStoredTokens(userId);
    if (!storedTokens || !storedTokens.refreshToken) {
      return null;
    }

    const refreshParams = new URLSearchParams({
      grant_type: 'refresh_token',
      client_id: this.config.clientId,
      client_secret: this.config.clientSecret,
      refresh_token: storedTokens.refreshToken
    });

    try {
      const response = await this.httpClient.post(
        this.config.tokenUrl,
        refreshParams.toString(),
        {
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
          }
        }
      );

      const tokenData = response.data;
      
      const newTokens: OAuthTokens = {
        accessToken: tokenData.access_token,
        refreshToken: tokenData.refresh_token || storedTokens.refreshToken,
        tokenType: tokenData.token_type || 'Bearer',
        expiresIn: parseInt(tokenData.expires_in) || 3600,
        scope: tokenData.scope || storedTokens.scope,
        expiresAt: new Date(Date.now() + (parseInt(tokenData.expires_in) || 3600) * 1000)
      };

      await this.storeTokens(userId, newTokens);

      logger.info('OAuth tokens refreshed', {
        provider: this.config.provider,
        userId,
        expiresIn: newTokens.expiresIn
      });

      return newTokens;

    } catch (error) {
      logger.error('OAuth token refresh failed', {
        provider: this.config.provider,
        userId,
        error: error instanceof Error ? error.message : 'Unknown error'
      });

      // Remove invalid tokens
      await this.revokeTokens(userId);
      return null;
    }
  }

  /**
   * Store tokens in Redis
   */
  private async storeTokens(userId: string, tokens: OAuthTokens): Promise<void> {
    const key = `oauth:tokens:${this.config.provider}:${userId}`;
    const ttl = Math.max(tokens.expiresIn - 60, 300); // Store until expiry minus 1 minute, minimum 5 minutes

    await this.redis.setex(key, ttl, JSON.stringify(tokens));
  }

  /**
   * Get stored tokens from Redis
   */
  private async getStoredTokens(userId: string): Promise<OAuthTokens | null> {
    const key = `oauth:tokens:${this.config.provider}:${userId}`;
    const tokenData = await this.redis.get(key);
    
    if (!tokenData) {
      return null;
    }

    const tokens: OAuthTokens = JSON.parse(tokenData);
    tokens.expiresAt = new Date(tokens.expiresAt);
    
    return tokens;
  }

  /**
   * Revoke tokens
   */
  public async revokeTokens(userId: string): Promise<void> {
    const tokens = await this.getStoredTokens(userId);
    
    if (tokens && this.config.revokeUrl) {
      try {
        await this.httpClient.post(
          this.config.revokeUrl,
          new URLSearchParams({
            token: tokens.accessToken,
            client_id: this.config.clientId,
            client_secret: this.config.clientSecret
          }).toString(),
          {
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded'
            }
          }
        );
      } catch (error) {
        logger.warn('OAuth token revocation failed', {
          provider: this.config.provider,
          userId,
          error: error instanceof Error ? error.message : 'Unknown error'
        });
      }
    }

    // Remove from Redis
    const key = `oauth:tokens:${this.config.provider}:${userId}`;
    await this.redis.del(key);

    logger.info('OAuth tokens revoked', {
      provider: this.config.provider,
      userId
    });
  }

  /**
   * Check if user has valid tokens
   */
  public async hasValidTokens(userId: string): Promise<boolean> {
    const tokens = await this.getStoredTokens(userId);
    
    if (!tokens) {
      return false;
    }

    // Check if tokens are expired
    if (new Date() >= tokens.expiresAt) {
      // Try to refresh if refresh token is available
      const refreshedTokens = await this.refreshTokens(userId);
      return refreshedTokens !== null;
    }

    return true;
  }

  /**
   * Get valid access token for user
   */
  public async getValidAccessToken(userId: string): Promise<string | null> {
    const tokens = await this.getStoredTokens(userId);
    
    if (!tokens) {
      return null;
    }

    // Check if tokens are expired
    if (new Date() >= tokens.expiresAt) {
      const refreshedTokens = await this.refreshTokens(userId);
      return refreshedTokens?.accessToken || null;
    }

    return tokens.accessToken;
  }

  /**
   * Health check for OAuth manager
   */
  public async healthCheck(): Promise<{ status: string; message: string }> {
    try {
      // Test Redis connection
      await this.redis.ping();
      
      // Test HTTP client connectivity (optional - depends on provider)
      // await this.httpClient.head(this.config.authorizationUrl);

      return {
        status: 'healthy',
        message: 'OAuth manager operational'
      };
    } catch (error) {
      logger.error('OAuth manager health check failed', {
        provider: this.config.provider,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      
      return {
        status: 'unhealthy',
        message: 'OAuth manager not operational'
      };
    }
  }
}

/**
 * OAuth provider configurations
 */
export const OAuthProviders = {
  extended: {
    provider: 'extended',
    authorizationUrl: 'https://api.extended.com/oauth/authorize',
    tokenUrl: 'https://api.extended.com/oauth/token',
    userInfoUrl: 'https://api.extended.com/oauth/user',
    revokeUrl: 'https://api.extended.com/oauth/revoke',
    scope: ['trading', 'portfolio:read', 'user:read'],
    pkceEnabled: true,
    state: true
  },
  
  github: {
    provider: 'github',
    authorizationUrl: 'https://github.com/login/oauth/authorize',
    tokenUrl: 'https://github.com/login/oauth/access_token',
    userInfoUrl: 'https://api.github.com/user',
    scope: ['user:email'],
    pkceEnabled: false,
    state: true
  },
  
  google: {
    provider: 'google',
    authorizationUrl: 'https://accounts.google.com/o/oauth2/v2/auth',
    tokenUrl: 'https://oauth2.googleapis.com/token',
    userInfoUrl: 'https://www.googleapis.com/oauth2/v2/userinfo',
    revokeUrl: 'https://oauth2.googleapis.com/revoke',
    scope: ['openid', 'email', 'profile'],
    pkceEnabled: true,
    state: true
  }
};

/**
 * Create OAuth manager for Extended API
 */
export function createExtendedOAuthManager(redis: RedisConnection): OAuthManager {
  const config: OAuthConfig = {
    ...OAuthProviders.extended,
    clientId: process.env.EXTENDED_CLIENT_ID || '',
    clientSecret: process.env.EXTENDED_CLIENT_SECRET || '',
    redirectUri: process.env.EXTENDED_REDIRECT_URI || 'https://localhost:3000/auth/extended/callback'
  };

  if (!config.clientId || !config.clientSecret) {
    throw new Error('Extended OAuth credentials not configured');
  }

  return new OAuthManager(config, redis);
}

/**
 * Create OAuth manager factory for multiple providers
 */
export function createOAuthManagerFactory(redis: RedisConnection) {
  const managers = new Map<string, OAuthManager>();

  return {
    getManager(provider: string): OAuthManager {
      if (!managers.has(provider)) {
        const providerConfig = OAuthProviders[provider as keyof typeof OAuthProviders];
        if (!providerConfig) {
          throw new Error(`Unsupported OAuth provider: ${provider}`);
        }

        const config: OAuthConfig = {
          ...providerConfig,
          clientId: process.env[`${provider.toUpperCase()}_CLIENT_ID`] || '',
          clientSecret: process.env[`${provider.toUpperCase()}_CLIENT_SECRET`] || '',
          redirectUri: process.env[`${provider.toUpperCase()}_REDIRECT_URI`] || `https://localhost:3000/auth/${provider}/callback`
        };

        if (!config.clientId || !config.clientSecret) {
          throw new Error(`${provider} OAuth credentials not configured`);
        }

        managers.set(provider, new OAuthManager(config, redis));
      }

      return managers.get(provider)!;
    },

    listProviders(): string[] {
      return Object.keys(OAuthProviders);
    }
  };
}