import { Request, Response, NextFunction } from 'express';
import helmet from 'helmet';
import { logger } from '../utils/logger-factory';

export interface SecurityHeadersConfig {
  contentSecurityPolicy: {
    enabled: boolean;
    directives?: Record<string, string[]>;
    reportOnly?: boolean;
    reportUri?: string;
  };
  crossOriginEmbedderPolicy: boolean;
  crossOriginOpenerPolicy: boolean;
  crossOriginResourcePolicy: {
    enabled: boolean;
    policy: 'same-origin' | 'same-site' | 'cross-origin';
  };
  dnsPrefetchControl: boolean;
  frameguard: {
    enabled: boolean;
    action: 'deny' | 'sameorigin' | 'allow-from';
    domain?: string;
  };
  hidePoweredBy: boolean;
  hsts: {
    enabled: boolean;
    maxAge: number;
    includeSubDomains: boolean;
    preload: boolean;
  };
  ieNoOpen: boolean;
  noSniff: boolean;
  originAgentCluster: boolean;
  permittedCrossDomainPolicies: boolean;
  referrerPolicy: {
    enabled: boolean;
    policy: string[];
  };
  xssFilter: boolean;
  customHeaders: Record<string, string>;
}

export class SecurityHeadersManager {
  private config: SecurityHeadersConfig;

  constructor(config?: Partial<SecurityHeadersConfig>) {
    this.config = {
      contentSecurityPolicy: {
        enabled: true,
        directives: {
          defaultSrc: ["'self'"],
          styleSrc: ["'self'", "'unsafe-inline'"],
          scriptSrc: ["'self'"],
          imgSrc: ["'self'", 'data:', 'https:'],
          connectSrc: ["'self'"],
          fontSrc: ["'self'"],
          objectSrc: ["'none'"],
          mediaSrc: ["'self'"],
          frameSrc: ["'none'"],
          childSrc: ["'none'"],
          workerSrc: ["'none'"],
          manifestSrc: ["'self'"],
          upgradeInsecureRequests: []
        },
        reportOnly: false
      },
      crossOriginEmbedderPolicy: true,
      crossOriginOpenerPolicy: true,
      crossOriginResourcePolicy: {
        enabled: true,
        policy: 'same-origin'
      },
      dnsPrefetchControl: true,
      frameguard: {
        enabled: true,
        action: 'deny'
      },
      hidePoweredBy: true,
      hsts: {
        enabled: true,
        maxAge: 31536000, // 1 year
        includeSubDomains: true,
        preload: true
      },
      ieNoOpen: true,
      noSniff: true,
      originAgentCluster: true,
      permittedCrossDomainPolicies: false,
      referrerPolicy: {
        enabled: true,
        policy: ['strict-origin-when-cross-origin']
      },
      xssFilter: true,
      customHeaders: {},
      ...config
    };

    this.validateConfig();
  }

  private validateConfig(): void {
    // Validate HSTS configuration
    if (this.config.hsts.enabled && this.config.hsts.maxAge < 0) {
      throw new Error('HSTS maxAge must be a non-negative number');
    }

    // Validate frameguard configuration
    if (this.config.frameguard.enabled && 
        this.config.frameguard.action === 'allow-from' && 
        !this.config.frameguard.domain) {
      throw new Error('Frameguard allow-from action requires a domain');
    }

    // Validate CSP directives
    if (this.config.contentSecurityPolicy.enabled && this.config.contentSecurityPolicy.directives) {
      const validDirectives = [
        'default-src', 'script-src', 'style-src', 'img-src', 'connect-src',
        'font-src', 'object-src', 'media-src', 'frame-src', 'child-src',
        'worker-src', 'manifest-src', 'upgrade-insecure-requests', 'base-uri',
        'form-action', 'frame-ancestors', 'plugin-types', 'sandbox',
        'script-src-elem', 'script-src-attr', 'style-src-elem', 'style-src-attr'
      ];

      for (const directive of Object.keys(this.config.contentSecurityPolicy.directives)) {
        const kebabDirective = directive.replace(/([A-Z])/g, '-$1').toLowerCase();
        if (!validDirectives.includes(kebabDirective)) {
          logger.warn('Unknown CSP directive', { directive });
        }
      }
    }
  }

  /**
   * Generate Content Security Policy header value
   */
  private generateCSPHeader(): string {
    if (!this.config.contentSecurityPolicy.enabled || !this.config.contentSecurityPolicy.directives) {
      return '';
    }

    const directives: string[] = [];

    for (const [key, values] of Object.entries(this.config.contentSecurityPolicy.directives)) {
      const kebabKey = key.replace(/([A-Z])/g, '-$1').toLowerCase();
      
      if (Array.isArray(values) && values.length > 0) {
        directives.push(`${kebabKey} ${values.join(' ')}`);
      } else if (key === 'upgradeInsecureRequests') {
        directives.push('upgrade-insecure-requests');
      }
    }

    return directives.join('; ');
  }

  /**
   * Get helmet configuration
   */
  private getHelmetConfig(): Parameters<typeof helmet>[0] {
    const helmetConfig: Parameters<typeof helmet>[0] = {
      contentSecurityPolicy: this.config.contentSecurityPolicy.enabled ? {
        directives: this.config.contentSecurityPolicy.directives,
        reportOnly: this.config.contentSecurityPolicy.reportOnly
      } : false,
      
      crossOriginEmbedderPolicy: this.config.crossOriginEmbedderPolicy,
      crossOriginOpenerPolicy: this.config.crossOriginOpenerPolicy,
      
      crossOriginResourcePolicy: this.config.crossOriginResourcePolicy.enabled ? {
        policy: this.config.crossOriginResourcePolicy.policy
      } : false,
      
      dnsPrefetchControl: this.config.dnsPrefetchControl,
      
      frameguard: this.config.frameguard.enabled ? {
        action: this.config.frameguard.action === 'allow-from' ? 'deny' : this.config.frameguard.action
      } : false,
      
      hidePoweredBy: this.config.hidePoweredBy,
      
      hsts: this.config.hsts.enabled ? {
        maxAge: this.config.hsts.maxAge,
        includeSubDomains: this.config.hsts.includeSubDomains,
        preload: this.config.hsts.preload
      } : false,
      
      ieNoOpen: this.config.ieNoOpen,
      noSniff: this.config.noSniff,
      originAgentCluster: this.config.originAgentCluster,
      permittedCrossDomainPolicies: this.config.permittedCrossDomainPolicies,
      
      referrerPolicy: this.config.referrerPolicy.enabled ? {
        policy: this.config.referrerPolicy.policy as any
      } : false,
      
      xssFilter: this.config.xssFilter
    };

    return helmetConfig;
  }

  /**
   * Custom headers middleware
   */
  private customHeadersMiddleware = (req: Request, res: Response, next: NextFunction) => {
    // Add custom security headers
    for (const [header, value] of Object.entries(this.config.customHeaders)) {
      res.setHeader(header, value);
    }

    // Add Financial Kingdom specific headers
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-XSS-Protection', '1; mode=block');
    
    // API versioning header
    res.setHeader('X-API-Version', process.env.API_VERSION || '1.0');
    
    // Remove potentially sensitive headers
    res.removeHeader('X-Powered-By');
    res.removeHeader('Server');
    
    // Add security policy headers for trading endpoints
    if (req.path.startsWith('/trading') || req.path.startsWith('/api/trading')) {
      res.setHeader('X-Trading-Security', 'enhanced');
      res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, private');
      res.setHeader('Pragma', 'no-cache');
      res.setHeader('Expires', '0');
    }

    // Add HSTS header for HTTPS
    if (req.secure || req.get('X-Forwarded-Proto') === 'https') {
      const hstsValue = `max-age=${this.config.hsts.maxAge}${
        this.config.hsts.includeSubDomains ? '; includeSubDomains' : ''
      }${this.config.hsts.preload ? '; preload' : ''}`;
      res.setHeader('Strict-Transport-Security', hstsValue);
    }

    next();
  };

  /**
   * CSP violation reporting middleware
   */
  private cspReportingMiddleware = (req: Request, res: Response, next: NextFunction) => {
    if (req.path === '/csp-violation-report' && req.method === 'POST') {
      logger.warn('CSP violation reported', {
        ip: req.ip,
        userAgent: req.get('User-Agent'),
        report: req.body,
        timestamp: new Date().toISOString()
      });
      
      res.status(204).end();
      return;
    }
    
    next();
  };

  /**
   * Get complete security middleware stack
   */
  public getMiddleware() {
    const helmetMiddleware = helmet(this.getHelmetConfig());
    
    return [
      helmetMiddleware,
      this.customHeadersMiddleware,
      this.cspReportingMiddleware
    ];
  }

  /**
   * Get middleware for API endpoints
   */
  public getAPIMiddleware() {
    const apiConfig = { ...this.config };
    
    // More restrictive CSP for API endpoints
    if (apiConfig.contentSecurityPolicy.enabled) {
      apiConfig.contentSecurityPolicy.directives = {
        defaultSrc: ["'none'"],
        connectSrc: ["'self'"]
      };
    }

    const helmetMiddleware = helmet(this.getHelmetConfig());
    
    return [
      helmetMiddleware,
      (req: Request, res: Response, next: NextFunction) => {
        // API-specific headers
        res.setHeader('X-Content-Type-Options', 'nosniff');
        res.setHeader('X-Frame-Options', 'DENY');
        res.setHeader('Cache-Control', 'no-store');
        res.setHeader('Pragma', 'no-cache');
        
        next();
      }
    ];
  }

  /**
   * Get middleware for static content
   */
  public getStaticMiddleware() {
    const staticConfig = { ...this.config };
    
    // Allow more sources for static content
    if (staticConfig.contentSecurityPolicy.enabled) {
      staticConfig.contentSecurityPolicy.directives = {
        ...staticConfig.contentSecurityPolicy.directives,
        imgSrc: ["'self'", 'data:', 'https:', '*.financialkingdom.app'],
        styleSrc: ["'self'", "'unsafe-inline'"],
        fontSrc: ["'self'", 'data:', 'https:']
      };
    }

    const helmetMiddleware = helmet(this.getHelmetConfig());
    
    return [
      helmetMiddleware,
      (req: Request, res: Response, next: NextFunction) => {
        // Static content caching
        res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
        
        next();
      }
    ];
  }

  /**
   * Update security configuration
   */
  public updateConfig(newConfig: Partial<SecurityHeadersConfig>): void {
    this.config = { ...this.config, ...newConfig };
    this.validateConfig();
    logger.info('Security headers configuration updated');
  }

  /**
   * Add custom header
   */
  public addCustomHeader(name: string, value: string): void {
    this.config.customHeaders[name] = value;
    logger.info('Custom security header added', { name, value });
  }

  /**
   * Remove custom header
   */
  public removeCustomHeader(name: string): void {
    delete this.config.customHeaders[name];
    logger.info('Custom security header removed', { name });
  }

  /**
   * Get current configuration
   */
  public getConfig(): SecurityHeadersConfig {
    return { ...this.config };
  }

  /**
   * Health check for security headers manager
   */
  public healthCheck(): { status: string; message: string; config: any } {
    try {
      this.validateConfig();
      
      return {
        status: 'healthy',
        message: 'Security headers manager operational',
        config: {
          cspEnabled: this.config.contentSecurityPolicy.enabled,
          hstsEnabled: this.config.hsts.enabled,
          customHeadersCount: Object.keys(this.config.customHeaders).length
        }
      };
    } catch (error) {
      logger.error('Security headers manager health check failed', {
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      
      return {
        status: 'unhealthy',
        message: 'Security headers manager configuration invalid',
        config: null
      };
    }
  }
}

/**
 * Environment-specific security configurations
 */
export const SecurityConfigurations = {
  development: {
    contentSecurityPolicy: {
      enabled: false, // Disabled for easier development
      reportOnly: true
    },
    hsts: {
      enabled: false, // No HTTPS in development
      maxAge: 0,
      includeSubDomains: false,
      preload: false
    }
  },

  staging: {
    contentSecurityPolicy: {
      enabled: true,
      reportOnly: true, // Report only in staging
      reportUri: '/csp-violation-report'
    },
    hsts: {
      enabled: true,
      maxAge: 86400, // 1 day
      includeSubDomains: false,
      preload: false
    }
  },

  production: {
    contentSecurityPolicy: {
      enabled: true,
      reportOnly: false,
      reportUri: '/csp-violation-report'
    },
    hsts: {
      enabled: true,
      maxAge: 31536000, // 1 year
      includeSubDomains: true,
      preload: true
    },
    customHeaders: {
      'X-Financial-Security': 'enhanced',
      'X-Trading-Protection': 'enabled'
    }
  }
};

/**
 * Create security headers manager with environment-specific configuration
 */
export function createSecurityHeadersManager(): SecurityHeadersManager {
  const environment = process.env.NODE_ENV || 'development';
  const config = SecurityConfigurations[environment as keyof typeof SecurityConfigurations] || SecurityConfigurations.development;

  logger.info('Security headers manager initialized', {
    environment,
    cspEnabled: config.contentSecurityPolicy?.enabled,
    hstsEnabled: config.hsts?.enabled
  });

  return new SecurityHeadersManager(config);
}

/**
 * Enhanced security headers for authentication endpoints
 */
export function createAuthSecurityHeaders(): SecurityHeadersManager {
  return new SecurityHeadersManager({
    contentSecurityPolicy: {
      enabled: true,
      directives: {
        defaultSrc: ["'none'"],
        connectSrc: ["'self'"],
        scriptSrc: ["'none'"],
        styleSrc: ["'none'"],
        imgSrc: ["'none'"],
        fontSrc: ["'none'"],
        objectSrc: ["'none'"],
        mediaSrc: ["'none'"],
        frameSrc: ["'none'"],
        childSrc: ["'none'"],
        workerSrc: ["'none'"]
      }
    },
    frameguard: {
      enabled: true,
      action: 'deny'
    },
    customHeaders: {
      'X-Auth-Security': 'maximum',
      'Cache-Control': 'no-store, no-cache, must-revalidate, private',
      'Pragma': 'no-cache'
    }
  });
}