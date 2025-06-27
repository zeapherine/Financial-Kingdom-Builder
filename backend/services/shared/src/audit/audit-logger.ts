import { Request } from 'express';
import { logger } from '../utils/logger-factory';
import { RedisConnection } from '../database/redis';
import { PostgresConnection } from '../database/postgres';

export interface AuditEvent {
  id: string;
  timestamp: Date;
  userId?: string;
  sessionId?: string;
  action: string;
  resource: string;
  resourceId?: string;
  outcome: 'success' | 'failure' | 'error';
  ipAddress?: string;
  userAgent?: string;
  requestMethod?: string;
  requestPath?: string;
  statusCode?: number;
  errorMessage?: string;
  metadata?: Record<string, any>;
  severity: 'low' | 'medium' | 'high' | 'critical';
  category: 'authentication' | 'authorization' | 'trading' | 'data_access' | 'system' | 'security';
}

export interface AuditConfig {
  enabledCategories: string[];
  logToDatabase: boolean;
  logToRedis: boolean;
  logToFile: boolean;
  retentionDays: number;
  realTimeAlerts: boolean;
  alertThresholds: {
    failedLogins: number;
    suspiciousIPs: number;
    highValueTrades: number;
  };
  sensitiveFields: string[];
}

export class AuditLogger {
  private config: AuditConfig;
  private postgres?: PostgresConnection;
  private redis?: RedisConnection;

  constructor(
    config: AuditConfig,
    postgres?: PostgresConnection,
    redis?: RedisConnection
  ) {
    this.config = config;
    this.postgres = postgres;
    this.redis = redis;
    this.validateConfig();
  }

  private validateConfig(): void {
    if (this.config.retentionDays < 1) {
      throw new Error('Audit log retention must be at least 1 day');
    }

    if (this.config.logToDatabase && !this.postgres) {
      throw new Error('PostgreSQL connection required for database logging');
    }

    if (this.config.logToRedis && !this.redis) {
      throw new Error('Redis connection required for Redis logging');
    }
  }

  /**
   * Generate unique audit event ID
   */
  private generateAuditId(): string {
    return `audit_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Sanitize sensitive data from metadata
   */
  private sanitizeMetadata(metadata?: Record<string, any>): Record<string, any> {
    if (!metadata) return {};

    const sanitized = { ...metadata };
    
    for (const field of this.config.sensitiveFields) {
      if (sanitized[field]) {
        sanitized[field] = '[REDACTED]';
      }
    }

    // Always redact these sensitive fields
    const alwaysRedact = ['password', 'token', 'secret', 'key', 'creditCard', 'ssn'];
    for (const field of alwaysRedact) {
      if (sanitized[field]) {
        sanitized[field] = '[REDACTED]';
      }
    }

    return sanitized;
  }

  /**
   * Extract audit information from Express request
   */
  private extractRequestInfo(req: Request): Partial<AuditEvent> {
    return {
      ipAddress: req.ip || req.connection.remoteAddress,
      userAgent: req.get('User-Agent'),
      requestMethod: req.method,
      requestPath: req.path,
      userId: (req as any).user?.userId,
      sessionId: (req as any).sessionId || req.get('X-Session-ID')
    };
  }

  /**
   * Log audit event
   */
  public async logEvent(event: Omit<AuditEvent, 'id' | 'timestamp'>): Promise<void> {
    // Check if category is enabled
    if (!this.config.enabledCategories.includes(event.category)) {
      return;
    }

    const auditEvent: AuditEvent = {
      id: this.generateAuditId(),
      timestamp: new Date(),
      ...event,
      metadata: this.sanitizeMetadata(event.metadata)
    };

    try {
      // Log to application logger
      logger.info('Audit event', auditEvent);

      // Log to database
      if (this.config.logToDatabase && this.postgres) {
        await this.logToDatabase(auditEvent);
      }

      // Log to Redis for real-time processing
      if (this.config.logToRedis && this.redis) {
        await this.logToRedis(auditEvent);
      }

      // Check for alert conditions
      if (this.config.realTimeAlerts) {
        await this.checkAlertConditions(auditEvent);
      }

    } catch (error) {
      logger.error('Failed to log audit event', {
        error: error instanceof Error ? error.message : 'Unknown error',
        eventId: auditEvent.id,
        action: auditEvent.action
      });
    }
  }

  /**
   * Log to PostgreSQL database
   */
  private async logToDatabase(event: AuditEvent): Promise<void> {
    if (!this.postgres) return;

    const query = `
      INSERT INTO audit_logs (
        id, timestamp, user_id, session_id, action, resource, resource_id,
        outcome, ip_address, user_agent, request_method, request_path,
        status_code, error_message, metadata, severity, category
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17
      )
    `;

    const values = [
      event.id,
      event.timestamp,
      event.userId,
      event.sessionId,
      event.action,
      event.resource,
      event.resourceId,
      event.outcome,
      event.ipAddress,
      event.userAgent,
      event.requestMethod,
      event.requestPath,
      event.statusCode,
      event.errorMessage,
      JSON.stringify(event.metadata),
      event.severity,
      event.category
    ];

    await this.postgres.query(query, values);
  }

  /**
   * Log to Redis for real-time processing
   */
  private async logToRedis(event: AuditEvent): Promise<void> {
    if (!this.redis) return;

    // Store in Redis with expiration
    const key = `audit:${event.id}`;
    const ttl = this.config.retentionDays * 24 * 60 * 60; // Convert to seconds
    
    await this.redis.setex(key, ttl, JSON.stringify(event));

    // Add to category-specific lists for querying
    const categoryKey = `audit:category:${event.category}`;
    await this.redis.lpush(categoryKey, event.id);
    await this.redis.expire(categoryKey, ttl);

    // Add to user-specific lists if user is present
    if (event.userId) {
      const userKey = `audit:user:${event.userId}`;
      await this.redis.lpush(userKey, event.id);
      await this.redis.expire(userKey, ttl);
    }

    // Add to failure tracking for alerts
    if (event.outcome === 'failure') {
      const failureKey = `audit:failures:${event.category}`;
      await this.redis.incr(failureKey);
      await this.redis.expire(failureKey, 3600); // 1 hour window
    }
  }

  /**
   * Check for alert conditions
   */
  private async checkAlertConditions(event: AuditEvent): Promise<void> {
    if (!this.redis) return;

    try {
      // Check failed login attempts
      if (event.category === 'authentication' && event.outcome === 'failure') {
        const key = `audit:failed_logins:${event.ipAddress}`;
        const count = await this.redis.incr(key);
        await this.redis.expire(key, 900); // 15 minutes

        if (count >= this.config.alertThresholds.failedLogins) {
          await this.triggerAlert('FAILED_LOGIN_THRESHOLD', {
            ipAddress: event.ipAddress,
            attempts: count,
            threshold: this.config.alertThresholds.failedLogins
          });
        }
      }

      // Check suspicious IP activity
      if (event.ipAddress) {
        const ipKey = `audit:ip_activity:${event.ipAddress}`;
        const ipCount = await this.redis.incr(ipKey);
        await this.redis.expire(ipKey, 3600); // 1 hour

        if (ipCount >= this.config.alertThresholds.suspiciousIPs) {
          await this.triggerAlert('SUSPICIOUS_IP_ACTIVITY', {
            ipAddress: event.ipAddress,
            activityCount: ipCount,
            threshold: this.config.alertThresholds.suspiciousIPs
          });
        }
      }

      // Check high-value trading activity
      if (event.category === 'trading' && event.metadata?.amount) {
        const amount = parseFloat(event.metadata.amount);
        if (amount >= this.config.alertThresholds.highValueTrades) {
          await this.triggerAlert('HIGH_VALUE_TRADE', {
            userId: event.userId,
            amount: amount,
            threshold: this.config.alertThresholds.highValueTrades,
            symbol: event.metadata.symbol
          });
        }
      }

    } catch (error) {
      logger.error('Failed to check alert conditions', {
        error: error instanceof Error ? error.message : 'Unknown error',
        eventId: event.id
      });
    }
  }

  /**
   * Trigger security alert
   */
  private async triggerAlert(alertType: string, data: Record<string, any>): Promise<void> {
    const alert = {
      id: this.generateAuditId(),
      type: alertType,
      timestamp: new Date(),
      data,
      severity: 'high'
    };

    logger.warn('Security alert triggered', alert);

    if (this.redis) {
      // Store alert for dashboard/notification processing
      await this.redis.lpush('security:alerts', JSON.stringify(alert));
      await this.redis.expire('security:alerts', 86400); // 24 hours
    }
  }

  /**
   * Create audit middleware for Express
   */
  public middleware() {
    const auditLogger = this;
    
    return (req: Request, res: any, next: any) => {
      const startTime = Date.now();
      
      // Capture original response methods
      const originalSend = res.send;
      const originalJson = res.json;

      const logRequestCompletion = function(responseBody: any) {
        const duration = Date.now() - startTime;
        const statusCode = res.statusCode;
        
        // Determine if this should be audited
        const shouldAudit = 
          req.path.startsWith('/auth') ||
          req.path.startsWith('/trading') ||
          req.path.startsWith('/admin') ||
          statusCode >= 400;

        if (shouldAudit) {
          const requestInfo = auditLogger.extractRequestInfo(req);
          
          auditLogger.logEvent({
            ...requestInfo,
            action: `${req.method}_${req.path}`,
            resource: req.path,
            outcome: statusCode < 400 ? 'success' : 'failure',
            statusCode,
            severity: statusCode >= 500 ? 'critical' : statusCode >= 400 ? 'medium' : 'low',
            category: auditLogger.determineCategory(req.path),
            metadata: {
              duration,
              bodySize: JSON.stringify(responseBody || {}).length,
              query: req.query,
              params: req.params
            }
          }).catch((error: any) => {
            logger.error('Audit middleware error', { error });
          });
        }
      };

      // Override response methods to capture response
      res.send = function(body: any) {
        logRequestCompletion(body);
        return originalSend.call(res, body);
      };

      res.json = function(body: any) {
        logRequestCompletion(body);
        return originalJson.call(res, body);
      };

      next();
    };
  }

  /**
   * Determine audit category from request path
   */
  private determineCategory(path: string): AuditEvent['category'] {
    if (path.startsWith('/auth')) return 'authentication';
    if (path.startsWith('/trading')) return 'trading';
    if (path.startsWith('/admin')) return 'system';
    if (path.includes('/user') || path.includes('/profile')) return 'data_access';
    return 'system';
  }

  /**
   * Authentication-specific audit methods
   */
  public async logAuthentication(req: Request, outcome: 'success' | 'failure', metadata?: Record<string, any>): Promise<void> {
    const requestInfo = this.extractRequestInfo(req);
    
    await this.logEvent({
      ...requestInfo,
      action: 'user_login',
      resource: 'authentication',
      outcome,
      severity: outcome === 'failure' ? 'medium' : 'low',
      category: 'authentication',
      metadata
    });
  }

  /**
   * Trading-specific audit methods
   */
  public async logTrade(
    req: Request,
    action: string,
    outcome: 'success' | 'failure',
    tradeData: Record<string, any>
  ): Promise<void> {
    const requestInfo = this.extractRequestInfo(req);
    
    await this.logEvent({
      ...requestInfo,
      action: `trade_${action}`,
      resource: 'trading_order',
      resourceId: tradeData.orderId,
      outcome,
      severity: 'medium',
      category: 'trading',
      metadata: tradeData
    });
  }

  /**
   * Data access audit
   */
  public async logDataAccess(
    req: Request,
    resource: string,
    resourceId?: string,
    metadata?: Record<string, any>
  ): Promise<void> {
    const requestInfo = this.extractRequestInfo(req);
    
    await this.logEvent({
      ...requestInfo,
      action: 'data_access',
      resource,
      resourceId,
      outcome: 'success',
      severity: 'low',
      category: 'data_access',
      metadata
    });
  }

  /**
   * Get audit events by criteria
   */
  public async getAuditEvents(criteria: {
    userId?: string;
    category?: string;
    startDate?: Date;
    endDate?: Date;
    limit?: number;
    offset?: number;
  }): Promise<AuditEvent[]> {
    if (!this.postgres) {
      throw new Error('Database connection required for audit queries');
    }

    let query = 'SELECT * FROM audit_logs WHERE 1=1';
    const values: any[] = [];
    let paramCount = 0;

    if (criteria.userId) {
      query += ` AND user_id = $${++paramCount}`;
      values.push(criteria.userId);
    }

    if (criteria.category) {
      query += ` AND category = $${++paramCount}`;
      values.push(criteria.category);
    }

    if (criteria.startDate) {
      query += ` AND timestamp >= $${++paramCount}`;
      values.push(criteria.startDate);
    }

    if (criteria.endDate) {
      query += ` AND timestamp <= $${++paramCount}`;
      values.push(criteria.endDate);
    }

    query += ' ORDER BY timestamp DESC';

    if (criteria.limit) {
      query += ` LIMIT $${++paramCount}`;
      values.push(criteria.limit);
    }

    if (criteria.offset) {
      query += ` OFFSET $${++paramCount}`;
      values.push(criteria.offset);
    }

    const results = await this.postgres.query(query, values);
    return results.map(row => ({
      ...row,
      metadata: typeof row.metadata === 'string' ? JSON.parse(row.metadata) : row.metadata
    }));
  }

  /**
   * Clean up old audit logs
   */
  public async cleanup(): Promise<number> {
    if (!this.postgres) {
      return 0;
    }

    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - this.config.retentionDays);

    const query = 'DELETE FROM audit_logs WHERE timestamp < $1';
    const result = await this.postgres.query(query, [cutoffDate]);
    
    logger.info('Audit log cleanup completed', {
      deletedRows: result.length,
      cutoffDate: cutoffDate.toISOString()
    });

    return result.length;
  }

  /**
   * Health check for audit logger
   */
  public async healthCheck(): Promise<{ status: string; message: string; stats: any }> {
    try {
      const stats: any = {
        enabledCategories: this.config.enabledCategories.length,
        retentionDays: this.config.retentionDays
      };

      if (this.postgres) {
        // Test database connection and get recent log count
        const result = await this.postgres.query(
          'SELECT COUNT(*) as count FROM audit_logs WHERE timestamp > NOW() - INTERVAL \'1 hour\''
        );
        stats.recentLogs = parseInt(result[0]?.count || '0');
      }

      if (this.redis) {
        // Test Redis connection
        await this.redis.ping();
        stats.redisConnected = true;
      }

      return {
        status: 'healthy',
        message: 'Audit logger operational',
        stats
      };
    } catch (error) {
      logger.error('Audit logger health check failed', {
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      
      return {
        status: 'unhealthy',
        message: 'Audit logger not operational',
        stats: null
      };
    }
  }
}

/**
 * Create audit logger with environment configuration
 */
export function createAuditLogger(
  postgres?: PostgresConnection,
  redis?: RedisConnection
): AuditLogger {
  const config: AuditConfig = {
    enabledCategories: (process.env.AUDIT_CATEGORIES || 'authentication,trading,security,system').split(','),
    logToDatabase: process.env.AUDIT_LOG_TO_DB !== 'false',
    logToRedis: process.env.AUDIT_LOG_TO_REDIS !== 'false',
    logToFile: process.env.AUDIT_LOG_TO_FILE === 'true',
    retentionDays: parseInt(process.env.AUDIT_RETENTION_DAYS || '90'),
    realTimeAlerts: process.env.AUDIT_REAL_TIME_ALERTS !== 'false',
    alertThresholds: {
      failedLogins: parseInt(process.env.AUDIT_FAILED_LOGIN_THRESHOLD || '5'),
      suspiciousIPs: parseInt(process.env.AUDIT_SUSPICIOUS_IP_THRESHOLD || '100'),
      highValueTrades: parseInt(process.env.AUDIT_HIGH_VALUE_TRADE_THRESHOLD || '10000')
    },
    sensitiveFields: (process.env.AUDIT_SENSITIVE_FIELDS || 'password,token,secret,key').split(',')
  };

  return new AuditLogger(config, postgres, redis);
}