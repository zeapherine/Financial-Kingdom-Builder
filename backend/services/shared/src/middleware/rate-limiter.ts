import { Request, Response, NextFunction } from 'express';
import { RedisConnection } from '../database/redis';
import { logger } from '../utils/logger-factory';

export interface RateLimitConfig {
  windowMs: number; // Time window in milliseconds
  maxRequests: number; // Maximum requests per window
  keyGenerator?: (req: Request) => string; // Custom key generation
  skipSuccessfulRequests?: boolean; // Don't count successful responses
  skipFailedRequests?: boolean; // Don't count failed responses
  onLimitReached?: (req: Request, res: Response) => void; // Custom limit reached handler
  message?: string; // Custom error message
  standardHeaders?: boolean; // Include rate limit headers
  legacyHeaders?: boolean; // Include legacy headers
}

export interface RateLimitInfo {
  totalRequests: number;
  remainingRequests: number;
  resetTime: number;
  isLimited: boolean;
}

export interface RateLimitRule {
  path: string | RegExp;
  method?: string | string[];
  config: RateLimitConfig;
  tier?: number; // User tier requirement
  authenticated?: boolean; // Requires authentication
}

export class RateLimiter {
  private redis: RedisConnection;
  private rules: RateLimitRule[] = [];

  constructor(redis: RedisConnection) {
    this.redis = redis;
  }

  /**
   * Add rate limiting rule
   */
  public addRule(rule: RateLimitRule): void {
    this.rules.push(rule);
    logger.debug('Rate limiting rule added', {
      path: rule.path.toString(),
      method: rule.method,
      maxRequests: rule.config.maxRequests,
      windowMs: rule.config.windowMs
    });
  }

  /**
   * Default key generator based on IP
   */
  private defaultKeyGenerator(req: Request): string {
    const ip = req.ip || req.connection.remoteAddress || 'unknown';
    return `rate_limit:ip:${ip}`;
  }

  /**
   * User-based key generator
   */
  public userKeyGenerator(req: Request): string {
    const userId = (req as any).user?.userId || 'anonymous';
    const ip = req.ip || req.connection.remoteAddress || 'unknown';
    return `rate_limit:user:${userId}:${ip}`;
  }

  /**
   * Endpoint-specific key generator
   */
  public endpointKeyGenerator(req: Request): string {
    const ip = req.ip || req.connection.remoteAddress || 'unknown';
    const endpoint = `${req.method}:${req.route?.path || req.path}`;
    return `rate_limit:endpoint:${endpoint}:${ip}`;
  }

  /**
   * Check rate limit for a request
   */
  public async checkRateLimit(req: Request, config: RateLimitConfig): Promise<RateLimitInfo> {
    const keyGenerator = config.keyGenerator || this.defaultKeyGenerator.bind(this);
    const key = keyGenerator(req);
    const now = Date.now();
    const windowStart = now - config.windowMs;

    try {
      // Use sliding window log algorithm
      const pipeline = this.redis.multi();
      
      // Remove expired entries
      pipeline.zremrangebyscore(key, 0, windowStart);
      
      // Count current requests in window
      pipeline.zcard(key);
      
      // Add current request timestamp
      pipeline.zadd(key, now, `${now}-${Math.random()}`);
      
      // Set expiration for cleanup
      pipeline.expire(key, Math.ceil(config.windowMs / 1000));
      
      const results = await pipeline.exec();
      
      if (!results) {
        throw new Error('Redis pipeline execution failed');
      }

      const currentRequests = results[1]?.[1] as number || 0;
      const remainingRequests = Math.max(0, config.maxRequests - currentRequests - 1);
      const resetTime = now + config.windowMs;
      const isLimited = currentRequests >= config.maxRequests;

      return {
        totalRequests: currentRequests + 1,
        remainingRequests,
        resetTime,
        isLimited
      };
    } catch (error) {
      logger.error('Rate limit check failed', {
        key,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      
      // On error, allow request but log it
      return {
        totalRequests: 0,
        remainingRequests: config.maxRequests,
        resetTime: now + config.windowMs,
        isLimited: false
      };
    }
  }

  /**
   * Find matching rule for request
   */
  private findMatchingRule(req: Request): RateLimitRule | null {
    for (const rule of this.rules) {
      // Check path matching
      let pathMatches = false;
      if (typeof rule.path === 'string') {
        pathMatches = req.path === rule.path || req.path.startsWith(rule.path);
      } else {
        pathMatches = rule.path.test(req.path);
      }

      if (!pathMatches) continue;

      // Check method matching
      if (rule.method) {
        const methods = Array.isArray(rule.method) ? rule.method : [rule.method];
        if (!methods.includes(req.method)) continue;
      }

      // Check authentication requirement
      if (rule.authenticated && !(req as any).user) {
        continue;
      }

      // Check tier requirement
      if (rule.tier && (!(req as any).user?.tier || (req as any).user.tier < rule.tier)) {
        continue;
      }

      return rule;
    }

    return null;
  }

  /**
   * Express middleware factory
   */
  public middleware(defaultConfig?: RateLimitConfig) {
    return async (req: Request, res: Response, next: NextFunction) => {
      try {
        // Find matching rule or use default config
        const rule = this.findMatchingRule(req);
        const config = rule?.config || defaultConfig;

        if (!config) {
          return next();
        }

        const rateLimitInfo = await this.checkRateLimit(req, config);

        // Add rate limit headers
        if (config.standardHeaders !== false) {
          res.set({
            'RateLimit-Limit': config.maxRequests.toString(),
            'RateLimit-Remaining': rateLimitInfo.remainingRequests.toString(),
            'RateLimit-Reset': new Date(rateLimitInfo.resetTime).toISOString()
          });
        }

        if (config.legacyHeaders) {
          res.set({
            'X-RateLimit-Limit': config.maxRequests.toString(),
            'X-RateLimit-Remaining': rateLimitInfo.remainingRequests.toString(),
            'X-RateLimit-Reset': Math.ceil(rateLimitInfo.resetTime / 1000).toString()
          });
        }

        // Check if rate limited
        if (rateLimitInfo.isLimited) {
          logger.warn('Rate limit exceeded', {
            ip: req.ip,
            path: req.path,
            method: req.method,
            userAgent: req.get('User-Agent'),
            userId: (req as any).user?.userId,
            totalRequests: rateLimitInfo.totalRequests,
            maxRequests: config.maxRequests
          });

          if (config.onLimitReached) {
            config.onLimitReached(req, res);
            return;
          }

          res.status(429).json({
            error: 'Too Many Requests',
            message: config.message || 'Rate limit exceeded. Please try again later.',
            retryAfter: Math.ceil((rateLimitInfo.resetTime - Date.now()) / 1000)
          });
          return;
        }

        next();
      } catch (error) {
        logger.error('Rate limiter middleware error', {
          error: error instanceof Error ? error.message : 'Unknown error',
          path: req.path,
          method: req.method
        });
        
        // On error, allow request to continue
        next();
      }
    };
  }

  /**
   * Reset rate limit for a specific key
   */
  public async resetRateLimit(key: string): Promise<void> {
    try {
      await this.redis.del(key);
      logger.info('Rate limit reset', { key });
    } catch (error) {
      logger.error('Failed to reset rate limit', {
        key,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }

  /**
   * Get rate limit info for a key
   */
  public async getRateLimitInfo(key: string, config: RateLimitConfig): Promise<RateLimitInfo> {
    const now = Date.now();
    const windowStart = now - config.windowMs;

    try {
      // Count current requests in window
      const currentRequests = await this.redis.zcount(key, windowStart, now);
      const remainingRequests = Math.max(0, config.maxRequests - currentRequests);
      const resetTime = now + config.windowMs;
      const isLimited = currentRequests >= config.maxRequests;

      return {
        totalRequests: currentRequests,
        remainingRequests,
        resetTime,
        isLimited
      };
    } catch (error) {
      logger.error('Failed to get rate limit info', {
        key,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      
      return {
        totalRequests: 0,
        remainingRequests: config.maxRequests,
        resetTime: now + config.windowMs,
        isLimited: false
      };
    }
  }

  /**
   * Clean up expired rate limit entries
   */
  public async cleanup(): Promise<number> {
    try {
      let cleanedCount = 0;
      const pattern = 'rate_limit:*';
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

      logger.info('Rate limit cleanup completed', { cleanedCount });
      return cleanedCount;
    } catch (error) {
      logger.error('Rate limit cleanup failed', {
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      return 0;
    }
  }

  /**
   * Health check for rate limiter
   */
  public async healthCheck(): Promise<{ status: string; message: string }> {
    try {
      // Test Redis connection
      await this.redis.ping();
      
      // Test rate limit functionality
      const testKey = 'rate_limit:health_check';
      const testConfig: RateLimitConfig = {
        windowMs: 60000,
        maxRequests: 1
      };

      const info = await this.getRateLimitInfo(testKey, testConfig);
      await this.redis.del(testKey);

      return {
        status: 'healthy',
        message: 'Rate limiter operational'
      };
    } catch (error) {
      logger.error('Rate limiter health check failed', {
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      return {
        status: 'unhealthy',
        message: 'Rate limiter not operational'
      };
    }
  }
}

/**
 * Pre-configured rate limiting rules
 */
export const standardRateLimitRules: RateLimitRule[] = [
  // Authentication endpoints - strict limits
  {
    path: '/auth/login',
    method: 'POST',
    config: {
      windowMs: 15 * 60 * 1000, // 15 minutes
      maxRequests: 5, // 5 attempts per 15 minutes
      message: 'Too many login attempts. Please try again in 15 minutes.'
    }
  },
  {
    path: '/auth/register',
    method: 'POST',
    config: {
      windowMs: 60 * 60 * 1000, // 1 hour
      maxRequests: 3, // 3 registrations per hour per IP
      message: 'Too many registration attempts. Please try again in 1 hour.'
    }
  },
  {
    path: '/auth/forgot-password',
    method: 'POST',
    config: {
      windowMs: 60 * 60 * 1000, // 1 hour
      maxRequests: 3, // 3 password reset requests per hour
      message: 'Too many password reset requests. Please try again in 1 hour.'
    }
  },
  
  // Trading endpoints - moderate limits
  {
    path: /^\/trading\/.*/,
    method: ['POST', 'PUT', 'DELETE'],
    authenticated: true,
    config: {
      windowMs: 60 * 1000, // 1 minute
      maxRequests: 30, // 30 trading actions per minute
      keyGenerator: function(req: Request) {
        const userId = (req as any).user?.userId || 'anonymous';
        return `rate_limit:trading:${userId}`;
      }
    }
  },
  
  // API general endpoints
  {
    path: /^\/api\/.*/,
    authenticated: true,
    config: {
      windowMs: 60 * 1000, // 1 minute
      maxRequests: 100, // 100 requests per minute for authenticated users
      keyGenerator: function(req: Request) {
        const userId = (req as any).user?.userId || 'anonymous';
        return `rate_limit:api:${userId}`;
      }
    }
  },
  
  // Public endpoints - loose limits
  {
    path: /^\/public\/.*/,
    config: {
      windowMs: 60 * 1000, // 1 minute
      maxRequests: 30 // 30 requests per minute per IP
    }
  }
];

/**
 * Create rate limiter with standard rules
 */
export function createRateLimiter(redis: RedisConnection): RateLimiter {
  const rateLimiter = new RateLimiter(redis);
  
  // Add standard rules
  standardRateLimitRules.forEach(rule => {
    rateLimiter.addRule(rule);
  });
  
  return rateLimiter;
}