import { DatabaseManager, DatabaseMonitor, createDatabaseMonitor } from '../database';
import { logger } from './logger-factory';

export interface HealthCheckResult {
  status: 'healthy' | 'degraded' | 'unhealthy';
  timestamp: string;
  uptime: number;
  version: string;
  environment: string;
  database: {
    status: string;
    postgres: any;
    redis: any;
    mongodb: any;
  };
  performance?: {
    summary: any;
    alerts: string[];
    recommendations: string[];
  };
}

export class HealthChecker {
  private databaseManager: DatabaseManager;
  private databaseMonitor: DatabaseMonitor | null = null;
  private startTime: Date;

  constructor(databaseManager: DatabaseManager) {
    this.databaseManager = databaseManager;
    this.startTime = new Date();
  }

  public async initialize(): Promise<void> {
    try {
      const connections = this.databaseManager.getConnections();
      this.databaseMonitor = createDatabaseMonitor(
        connections.postgres,
        connections.redis,
        connections.mongodb
      );
      logger.info('Health checker initialized successfully');
    } catch (error) {
      logger.error('Failed to initialize health checker:', error);
      throw error;
    }
  }

  public async performBasicHealthCheck(): Promise<HealthCheckResult> {
    const timestamp = new Date().toISOString();
    const uptime = Math.floor((Date.now() - this.startTime.getTime()) / 1000);

    try {
      // Basic database health check
      const databaseHealth = await this.databaseManager.healthCheck();

      return {
        status: databaseHealth.overall,
        timestamp,
        uptime,
        version: process.env.npm_package_version || '1.0.0',
        environment: process.env.NODE_ENV || 'development',
        database: {
          status: databaseHealth.overall,
          postgres: databaseHealth.postgres,
          redis: databaseHealth.redis,
          mongodb: databaseHealth.mongodb
        }
      };
    } catch (error) {
      logger.error('Health check failed:', error);
      return {
        status: 'unhealthy',
        timestamp,
        uptime,
        version: process.env.npm_package_version || '1.0.0',
        environment: process.env.NODE_ENV || 'development',
        database: {
          status: 'unhealthy',
          postgres: { status: 'error', error: error instanceof Error ? error.message : String(error) },
          redis: { status: 'error', error: error instanceof Error ? error.message : String(error) },
          mongodb: { status: 'error', error: error instanceof Error ? error.message : String(error) }
        }
      };
    }
  }

  public async performDetailedHealthCheck(): Promise<HealthCheckResult> {
    const basicHealth = await this.performBasicHealthCheck();

    if (!this.databaseMonitor) {
      return basicHealth;
    }

    try {
      // Detailed performance analysis
      const performanceReport = await this.databaseMonitor.generatePerformanceReport();

      return {
        ...basicHealth,
        performance: performanceReport
      };
    } catch (error) {
      logger.error('Detailed health check failed:', error);
      return basicHealth;
    }
  }

  public async performReadinessCheck(): Promise<{ ready: boolean; checks: any }> {
    const checks = {
      database: false,
      migrations: false,
      dependencies: false
    };

    try {
      // Check database connections
      const databaseHealth = await this.databaseManager.healthCheck();
      checks.database = databaseHealth.overall === 'healthy';

      // Check if migrations are up to date (simplified check)
      try {
        const connections = this.databaseManager.getConnections();
        const migrationCheck = await connections.postgres.query(
          'SELECT COUNT(*) as count FROM schema_migrations'
        );
        checks.migrations = migrationCheck[0]?.count > 0;
      } catch (error) {
        logger.warn('Migration check failed:', error);
        checks.migrations = false;
      }

      // Check critical dependencies
      checks.dependencies = process.env.NODE_ENV !== undefined;

      const ready = Object.values(checks).every(check => check === true);

      return { ready, checks };
    } catch (error) {
      logger.error('Readiness check failed:', error);
      return { ready: false, checks };
    }
  }

  public async performLivenessCheck(): Promise<{ alive: boolean; pid: number; memory: any }> {
    try {
      const memoryUsage = process.memoryUsage();
      
      // Simple liveness check - if we can respond, we're alive
      return {
        alive: true,
        pid: process.pid,
        memory: {
          rss: Math.round(memoryUsage.rss / 1024 / 1024) + 'MB',
          heapTotal: Math.round(memoryUsage.heapTotal / 1024 / 1024) + 'MB',
          heapUsed: Math.round(memoryUsage.heapUsed / 1024 / 1024) + 'MB',
          external: Math.round(memoryUsage.external / 1024 / 1024) + 'MB'
        }
      };
    } catch (error) {
      logger.error('Liveness check failed:', error);
      return {
        alive: false,
        pid: process.pid,
        memory: null
      };
    }
  }

  public getMetrics(): any {
    if (!this.databaseMonitor) {
      return null;
    }
    return this.databaseMonitor.getLatestMetrics();
  }

  public getMetricsHistory(): any {
    if (!this.databaseMonitor) {
      return [];
    }
    return this.databaseMonitor.getMetricsHistory();
  }

  public startPeriodicMonitoring(intervalMs: number = 60000): NodeJS.Timeout | null {
    if (!this.databaseMonitor) {
      logger.warn('Database monitor not initialized, cannot start periodic monitoring');
      return null;
    }
    
    logger.info(`Starting periodic database monitoring every ${intervalMs}ms`);
    return this.databaseMonitor.startPeriodicCollection(intervalMs);
  }

  public stopPeriodicMonitoring(interval: NodeJS.Timeout): void {
    if (this.databaseMonitor) {
      this.databaseMonitor.stopPeriodicCollection(interval);
      logger.info('Stopped periodic database monitoring');
    }
  }
}

// Singleton instance
let healthChecker: HealthChecker | null = null;

export function createHealthChecker(databaseManager: DatabaseManager): HealthChecker {
  if (!healthChecker) {
    healthChecker = new HealthChecker(databaseManager);
  }
  return healthChecker;
}

export function getHealthChecker(): HealthChecker | null {
  return healthChecker;
}

// Express middleware for health endpoints
export function createHealthEndpoints() {
  return {
    // Basic health check
    health: async (req: any, res: any) => {
      try {
        const checker = getHealthChecker();
        if (!checker) {
          return res.status(503).json({ error: 'Health checker not initialized' });
        }

        const health = await checker.performBasicHealthCheck();
        const statusCode = health.status === 'healthy' ? 200 : 
                          health.status === 'degraded' ? 200 : 503;
        
        res.status(statusCode).json(health);
      } catch (error) {
        logger.error('Health endpoint error:', error);
        res.status(503).json({ error: 'Health check failed' });
      }
    },

    // Detailed health check with performance metrics
    healthDetailed: async (req: any, res: any) => {
      try {
        const checker = getHealthChecker();
        if (!checker) {
          return res.status(503).json({ error: 'Health checker not initialized' });
        }

        const health = await checker.performDetailedHealthCheck();
        const statusCode = health.status === 'healthy' ? 200 : 
                          health.status === 'degraded' ? 200 : 503;
        
        res.status(statusCode).json(health);
      } catch (error) {
        logger.error('Detailed health endpoint error:', error);
        res.status(503).json({ error: 'Detailed health check failed' });
      }
    },

    // Kubernetes readiness probe
    ready: async (req: any, res: any) => {
      try {
        const checker = getHealthChecker();
        if (!checker) {
          return res.status(503).json({ ready: false, error: 'Health checker not initialized' });
        }

        const readiness = await checker.performReadinessCheck();
        const statusCode = readiness.ready ? 200 : 503;
        
        res.status(statusCode).json(readiness);
      } catch (error) {
        logger.error('Readiness endpoint error:', error);
        res.status(503).json({ ready: false, error: 'Readiness check failed' });
      }
    },

    // Kubernetes liveness probe
    live: async (req: any, res: any) => {
      try {
        const checker = getHealthChecker();
        if (!checker) {
          return res.status(503).json({ alive: false, error: 'Health checker not initialized' });
        }

        const liveness = await checker.performLivenessCheck();
        const statusCode = liveness.alive ? 200 : 503;
        
        res.status(statusCode).json(liveness);
      } catch (error) {
        logger.error('Liveness endpoint error:', error);
        res.status(503).json({ alive: false, error: 'Liveness check failed' });
      }
    },

    // Metrics endpoint
    metrics: async (req: any, res: any) => {
      try {
        const checker = getHealthChecker();
        if (!checker) {
          return res.status(503).json({ error: 'Health checker not initialized' });
        }

        const metrics = checker.getMetrics();
        if (!metrics) {
          return res.status(503).json({ error: 'No metrics available' });
        }

        res.status(200).json(metrics);
      } catch (error) {
        logger.error('Metrics endpoint error:', error);
        res.status(503).json({ error: 'Metrics collection failed' });
      }
    },

    // Metrics history endpoint
    metricsHistory: async (req: any, res: any) => {
      try {
        const checker = getHealthChecker();
        if (!checker) {
          return res.status(503).json({ error: 'Health checker not initialized' });
        }

        const history = checker.getMetricsHistory();
        res.status(200).json({ history, count: history.length });
      } catch (error) {
        logger.error('Metrics history endpoint error:', error);
        res.status(503).json({ error: 'Metrics history collection failed' });
      }
    }
  };
}