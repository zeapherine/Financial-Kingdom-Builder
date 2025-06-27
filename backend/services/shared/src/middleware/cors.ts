import cors from 'cors';
import { Request } from 'express';
import { logger } from '../utils/logger-factory';

export interface CORSConfig {
  allowedOrigins: string[];
  allowedMethods: string[];
  allowedHeaders: string[];
  exposedHeaders: string[];
  credentials: boolean;
  maxAge: number;
  preflightContinue: boolean;
  optionsSuccessStatus: number;
}

export class CORSManager {
  private config: CORSConfig;

  constructor(config?: Partial<CORSConfig>) {
    this.config = {
      allowedOrigins: ['http://localhost:3000', 'https://localhost:3000'],
      allowedMethods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: [
        'Origin',
        'X-Requested-With',
        'Content-Type',
        'Accept',
        'Authorization',
        'X-Session-ID',
        'X-Device-ID',
        'X-App-Version',
        'X-Platform',
        'User-Agent'
      ],
      exposedHeaders: [
        'X-Total-Count',
        'X-Page-Count',
        'X-Current-Page',
        'X-Per-Page',
        'X-Rate-Limit-Remaining',
        'X-Rate-Limit-Reset',
        'RateLimit-Limit',
        'RateLimit-Remaining',
        'RateLimit-Reset'
      ],
      credentials: true,
      maxAge: 86400, // 24 hours
      preflightContinue: false,
      optionsSuccessStatus: 204,
      ...config
    };

    this.validateConfig();
  }

  private validateConfig(): void {
    // Validate origins
    if (!Array.isArray(this.config.allowedOrigins) || this.config.allowedOrigins.length === 0) {
      throw new Error('At least one allowed origin must be specified');
    }

    // Validate each origin format
    for (const origin of this.config.allowedOrigins) {
      if (origin !== '*' && !this.isValidOrigin(origin)) {
        throw new Error(`Invalid origin format: ${origin}`);
      }
    }

    // Validate methods
    const validMethods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS', 'HEAD'];
    for (const method of this.config.allowedMethods) {
      if (!validMethods.includes(method.toUpperCase())) {
        throw new Error(`Invalid HTTP method: ${method}`);
      }
    }

    // Security warning for wildcard origin with credentials
    if (this.config.allowedOrigins.includes('*') && this.config.credentials) {
      logger.warn('CORS configured with wildcard origin and credentials enabled - this is a security risk');
    }
  }

  private isValidOrigin(origin: string): boolean {
    try {
      new URL(origin);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Dynamic origin validation
   */
  private originChecker = (origin: string | undefined, callback: (err: Error | null, allow?: boolean) => void) => {
    // Allow requests with no origin (like mobile apps or Postman)
    if (!origin) {
      return callback(null, true);
    }

    // Check if origin is in allowed list
    if (this.config.allowedOrigins.includes('*') || this.config.allowedOrigins.includes(origin)) {
      return callback(null, true);
    }

    // Check for environment-specific origins
    if (this.isDevelopmentEnvironment() && this.isDevelopmentOrigin(origin)) {
      logger.debug('Allowing development origin', { origin });
      return callback(null, true);
    }

    // Check for subdomain matching
    if (this.isSubdomainMatch(origin)) {
      logger.debug('Allowing subdomain match', { origin });
      return callback(null, true);
    }

    logger.warn('CORS origin rejected', { 
      origin,
      allowedOrigins: this.config.allowedOrigins,
      userAgent: 'unknown' // Will be set by middleware if available
    });

    callback(new Error(`CORS policy violation: Origin ${origin} is not allowed`), false);
  };

  private isDevelopmentEnvironment(): boolean {
    return process.env.NODE_ENV === 'development' || process.env.NODE_ENV === 'test';
  }

  private isDevelopmentOrigin(origin: string): boolean {
    const devPatterns = [
      /^http:\/\/localhost:\d+$/,
      /^https:\/\/localhost:\d+$/,
      /^http:\/\/127\.0\.0\.1:\d+$/,
      /^https:\/\/127\.0\.0\.1:\d+$/,
      /^http:\/\/.*\.local$/,
      /^https:\/\/.*\.local$/
    ];

    return devPatterns.some(pattern => pattern.test(origin));
  }

  private isSubdomainMatch(origin: string): boolean {
    try {
      const originUrl = new URL(origin);
      
      for (const allowedOrigin of this.config.allowedOrigins) {
        if (allowedOrigin.startsWith('*.')) {
          const domain = allowedOrigin.substring(2);
          if (originUrl.hostname.endsWith(`.${domain}`) || originUrl.hostname === domain) {
            return true;
          }
        }
      }
      
      return false;
    } catch {
      return false;
    }
  }

  /**
   * Get CORS middleware
   */
  public getMiddleware() {
    const corsOptions: cors.CorsOptions = {
      origin: this.originChecker,
      methods: this.config.allowedMethods,
      allowedHeaders: this.config.allowedHeaders,
      exposedHeaders: this.config.exposedHeaders,
      credentials: this.config.credentials,
      maxAge: this.config.maxAge,
      preflightContinue: this.config.preflightContinue,
      optionsSuccessStatus: this.config.optionsSuccessStatus
    };

    return cors(corsOptions);
  }

  /**
   * Get preflight middleware for specific routes
   */
  public getPreflightMiddleware(specificOptions?: Partial<CORSConfig>) {
    const mergedConfig = { ...this.config, ...specificOptions };
    
    const corsOptions: cors.CorsOptions = {
      origin: this.originChecker,
      methods: mergedConfig.allowedMethods,
      allowedHeaders: mergedConfig.allowedHeaders,
      exposedHeaders: mergedConfig.exposedHeaders,
      credentials: mergedConfig.credentials,
      maxAge: mergedConfig.maxAge,
      preflightContinue: false,
      optionsSuccessStatus: mergedConfig.optionsSuccessStatus
    };

    return cors(corsOptions);
  }

  /**
   * Add origin to allowed list
   */
  public addAllowedOrigin(origin: string): void {
    if (!this.isValidOrigin(origin) && origin !== '*') {
      throw new Error(`Invalid origin format: ${origin}`);
    }

    if (!this.config.allowedOrigins.includes(origin)) {
      this.config.allowedOrigins.push(origin);
      logger.info('Added allowed CORS origin', { origin });
    }
  }

  /**
   * Remove origin from allowed list
   */
  public removeAllowedOrigin(origin: string): void {
    const index = this.config.allowedOrigins.indexOf(origin);
    if (index > -1) {
      this.config.allowedOrigins.splice(index, 1);
      logger.info('Removed allowed CORS origin', { origin });
    }
  }

  /**
   * Update CORS configuration
   */
  public updateConfig(newConfig: Partial<CORSConfig>): void {
    this.config = { ...this.config, ...newConfig };
    this.validateConfig();
    logger.info('CORS configuration updated');
  }

  /**
   * Get current configuration
   */
  public getConfig(): CORSConfig {
    return { ...this.config };
  }

  /**
   * Health check for CORS manager
   */
  public healthCheck(): { status: string; message: string; config: any } {
    try {
      this.validateConfig();
      
      return {
        status: 'healthy',
        message: 'CORS manager operational',
        config: {
          allowedOriginsCount: this.config.allowedOrigins.length,
          credentialsEnabled: this.config.credentials,
          maxAge: this.config.maxAge
        }
      };
    } catch (error) {
      logger.error('CORS manager health check failed', {
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      
      return {
        status: 'unhealthy',
        message: 'CORS manager configuration invalid',
        config: null
      };
    }
  }
}

/**
 * Environment-specific CORS configurations
 */
export const CORSConfigurations = {
  development: {
    allowedOrigins: [
      'http://localhost:3000',
      'https://localhost:3000',
      'http://localhost:3001',
      'https://localhost:3001',
      'http://127.0.0.1:3000',
      'https://127.0.0.1:3000'
    ],
    credentials: true,
    maxAge: 300 // 5 minutes for development
  },

  staging: {
    allowedOrigins: [
      'https://staging.financialkingdom.app',
      'https://staging-mobile.financialkingdom.app'
    ],
    credentials: true,
    maxAge: 3600 // 1 hour
  },

  production: {
    allowedOrigins: [
      'https://financialkingdom.app',
      'https://www.financialkingdom.app',
      'https://mobile.financialkingdom.app'
    ],
    credentials: true,
    maxAge: 86400 // 24 hours
  },

  // Mobile app specific configuration
  mobile: {
    allowedOrigins: ['*'], // Mobile apps don't send origin headers
    credentials: false,
    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'X-App-Version',
      'X-Platform',
      'X-Device-ID'
    ]
  }
};

/**
 * Create CORS manager with environment-specific configuration
 */
export function createCORSManager(): CORSManager {
  const environment = process.env.NODE_ENV || 'development';
  const isMobileAPI = process.env.MOBILE_API === 'true';
  
  let config: Partial<CORSConfig>;
  
  if (isMobileAPI) {
    config = CORSConfigurations.mobile;
  } else {
    config = CORSConfigurations[environment as keyof typeof CORSConfigurations] || CORSConfigurations.development;
  }

  // Override with environment variables if present
  if (process.env.CORS_ALLOWED_ORIGINS) {
    config.allowedOrigins = process.env.CORS_ALLOWED_ORIGINS.split(',').map(origin => origin.trim());
  }

  if (process.env.CORS_CREDENTIALS !== undefined) {
    config.credentials = process.env.CORS_CREDENTIALS === 'true';
  }

  if (process.env.CORS_MAX_AGE) {
    config.maxAge = parseInt(process.env.CORS_MAX_AGE, 10);
  }

  logger.info('CORS manager initialized', {
    environment,
    isMobileAPI,
    allowedOriginsCount: config.allowedOrigins?.length || 0,
    credentials: config.credentials
  });

  return new CORSManager(config);
}

/**
 * Strict CORS configuration for authentication endpoints
 */
export function createStrictCORSManager(): CORSManager {
  return new CORSManager({
    allowedOrigins: process.env.CORS_ALLOWED_ORIGINS?.split(',') || ['https://financialkingdom.app'],
    allowedMethods: ['POST', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    exposedHeaders: [],
    credentials: true,
    maxAge: 300 // 5 minutes for auth endpoints
  });
}