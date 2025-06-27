import { PostgresConnection } from './postgres';
import { RedisConnection } from './redis';
import { MongoConnection } from './mongodb';
import { logger } from '../utils/logger-factory';

export interface DatabaseMetrics {
  timestamp: Date;
  postgres: PostgresMetrics;
  redis: RedisMetrics;
  mongodb: MongoMetrics;
}

export interface PostgresMetrics {
  connections: {
    active: number;
    idle: number;
    total: number;
    max: number;
  };
  performance: {
    avgQueryTime: number;
    slowQueries: number;
    locksWaiting: number;
    deadlocks: number;
  };
  storage: {
    databaseSize: string;
    indexSize: string;
    tableStats: Array<{
      tableName: string;
      rowCount: number;
      size: string;
    }>;
  };
  replication: {
    isReplica: boolean;
    lagBytes?: number;
    lagTime?: number;
  };
}

export interface RedisMetrics {
  memory: {
    used: number;
    peak: number;
    fragmentation: number;
    evictedKeys: number;
  };
  performance: {
    commandsPerSecond: number;
    hitRate: number;
    missRate: number;
    avgCommandTime: number;
  };
  connections: {
    connected: number;
    blocked: number;
    rejected: number;
  };
  persistence: {
    lastSave: Date;
    changesSinceLastSave: number;
    aofSize?: number;
  };
}

export interface MongoMetrics {
  connections: {
    current: number;
    available: number;
    totalCreated: number;
  };
  performance: {
    avgQueryTime: number;
    operationsPerSecond: number;
    documentsPerSecond: number;
  };
  storage: {
    dataSize: number;
    storageSize: number;
    indexSize: number;
    collections: Array<{
      name: string;
      documentCount: number;
      avgDocumentSize: number;
      indexCount: number;
    }>;
  };
  replication: {
    isReplSet: boolean;
    isPrimary: boolean;
    replicationLag?: number;
  };
}

export class DatabaseMonitor {
  private postgresConnection: PostgresConnection;
  private redisConnection: RedisConnection;
  private mongoConnection: MongoConnection;
  private metricsHistory: DatabaseMetrics[] = [];
  private maxHistorySize: number = 1000;

  constructor(
    postgresConnection: PostgresConnection,
    redisConnection: RedisConnection,
    mongoConnection: MongoConnection
  ) {
    this.postgresConnection = postgresConnection;
    this.redisConnection = redisConnection;
    this.mongoConnection = mongoConnection;
  }

  public async collectMetrics(): Promise<DatabaseMetrics> {
    try {
      const timestamp = new Date();
      
      const [postgres, redis, mongodb] = await Promise.allSettled([
        this.collectPostgresMetrics(),
        this.collectRedisMetrics(),
        this.collectMongoMetrics()
      ]);

      const metrics: DatabaseMetrics = {
        timestamp,
        postgres: postgres.status === 'fulfilled' ? postgres.value : this.getEmptyPostgresMetrics(),
        redis: redis.status === 'fulfilled' ? redis.value : this.getEmptyRedisMetrics(),
        mongodb: mongodb.status === 'fulfilled' ? mongodb.value : this.getEmptyMongoMetrics()
      };

      // Store in history
      this.metricsHistory.push(metrics);
      if (this.metricsHistory.length > this.maxHistorySize) {
        this.metricsHistory.shift();
      }

      return metrics;
    } catch (error) {
      logger.error('Failed to collect database metrics:', error);
      throw error;
    }
  }

  private async collectPostgresMetrics(): Promise<PostgresMetrics> {
    try {
      // Connection metrics
      const connectionStats = await this.postgresConnection.query(`
        SELECT 
          count(*) as total_connections,
          count(*) FILTER (WHERE state = 'active') as active_connections,
          count(*) FILTER (WHERE state = 'idle') as idle_connections
        FROM pg_stat_activity 
        WHERE datname = current_database()
      `);

      const maxConnections = await this.postgresConnection.queryOne(`
        SHOW max_connections
      `);

      // Performance metrics (fallback if pg_stat_statements is not available)
      let performanceStats: any[] = [];
      try {
        performanceStats = await this.postgresConnection.query(`
          SELECT 
            COALESCE(avg(mean_exec_time), 0) as avg_query_time,
            COALESCE(sum(calls) FILTER (WHERE mean_exec_time > 1000), 0) as slow_queries
          FROM pg_stat_statements 
          WHERE dbid = (SELECT oid FROM pg_database WHERE datname = current_database())
        `);
      } catch (error) {
        // pg_stat_statements not available, use default values
        performanceStats = [{ avg_query_time: 0, slow_queries: 0 }];
      }

      const lockStats = await this.postgresConnection.query(`
        SELECT count(*) as waiting_locks
        FROM pg_locks 
        WHERE NOT granted
      `);

      const deadlockStats = await this.postgresConnection.queryOne(`
        SELECT deadlocks 
        FROM pg_stat_database 
        WHERE datname = current_database()
      `);

      // Storage metrics
      const databaseSize = await this.postgresConnection.queryOne(`
        SELECT pg_size_pretty(pg_database_size(current_database())) as size
      `);

      const indexSize = await this.postgresConnection.queryOne(`
        SELECT pg_size_pretty(sum(pg_relation_size(indexrelid))) as size
        FROM pg_index i
        JOIN pg_class c ON c.oid = i.indrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public'
      `);

      const tableStats = await this.postgresConnection.query(`
        SELECT 
          schemaname,
          tablename,
          n_tup_ins + n_tup_upd + n_tup_del as row_count,
          pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
        FROM pg_stat_user_tables 
        ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
        LIMIT 10
      `);

      // Replication metrics
      const replicationStats = await this.postgresConnection.queryOne(`
        SELECT pg_is_in_recovery() as is_replica
      `);

      return {
        connections: {
          active: connectionStats[0]?.active_connections || 0,
          idle: connectionStats[0]?.idle_connections || 0,
          total: connectionStats[0]?.total_connections || 0,
          max: parseInt(maxConnections?.max_connections || '0')
        },
        performance: {
          avgQueryTime: parseFloat(performanceStats[0]?.avg_query_time || '0'),
          slowQueries: parseInt(performanceStats[0]?.slow_queries || '0'),
          locksWaiting: parseInt(lockStats[0]?.waiting_locks || '0'),
          deadlocks: parseInt(deadlockStats?.deadlocks || '0')
        },
        storage: {
          databaseSize: databaseSize?.size || '0 bytes',
          indexSize: indexSize?.size || '0 bytes',
          tableStats: tableStats.map(row => ({
            tableName: row.tablename,
            rowCount: parseInt(row.row_count || '0'),
            size: row.size
          }))
        },
        replication: {
          isReplica: replicationStats?.is_replica || false
        }
      };
    } catch (error) {
      logger.error('Failed to collect PostgreSQL metrics:', error);
      throw error;
    }
  }

  private async collectRedisMetrics(): Promise<RedisMetrics> {
    try {
      const info = await this.redisConnection.getClient().info();
      const stats = this.parseRedisInfo(info);

      return {
        memory: {
          used: parseInt(stats.used_memory || '0'),
          peak: parseInt(stats.used_memory_peak || '0'),
          fragmentation: parseFloat(stats.mem_fragmentation_ratio || '1'),
          evictedKeys: parseInt(stats.evicted_keys || '0')
        },
        performance: {
          commandsPerSecond: parseInt(stats.instantaneous_ops_per_sec || '0'),
          hitRate: this.calculateRedisHitRate(stats),
          missRate: this.calculateRedisMissRate(stats),
          avgCommandTime: parseFloat(stats.avg_ttl || '0')
        },
        connections: {
          connected: parseInt(stats.connected_clients || '0'),
          blocked: parseInt(stats.blocked_clients || '0'),
          rejected: parseInt(stats.rejected_connections || '0')
        },
        persistence: {
          lastSave: new Date(parseInt(stats.rdb_last_save_time || '0') * 1000),
          changesSinceLastSave: parseInt(stats.rdb_changes_since_last_save || '0'),
          aofSize: stats.aof_current_size ? parseInt(stats.aof_current_size) : undefined
        }
      };
    } catch (error) {
      logger.error('Failed to collect Redis metrics:', error);
      throw error;
    }
  }

  private async collectMongoMetrics(): Promise<MongoMetrics> {
    try {
      const db = this.mongoConnection.getDatabase();
      
      // Server status
      const serverStatus = await db.admin().serverStatus();
      
      // Database stats
      const dbStats = await db.stats();
      
      // Collection stats
      const collections = await db.listCollections().toArray();
      const collectionStats = await Promise.all(
        collections.map(async (collection: any) => {
          try {
            const stats = await db.collection(collection.name).estimatedDocumentCount();
            return {
              name: collection.name,
              documentCount: stats || 0,
              avgDocumentSize: 0, // Not available without full stats
              indexCount: 0 // Not easily available
            };
          } catch (error) {
            return {
              name: collection.name,
              documentCount: 0,
              avgDocumentSize: 0,
              indexCount: 0
            };
          }
        })
      );

      return {
        connections: {
          current: serverStatus.connections?.current || 0,
          available: serverStatus.connections?.available || 0,
          totalCreated: serverStatus.connections?.totalCreated || 0
        },
        performance: {
          avgQueryTime: serverStatus.opLatencies?.reads?.latency || 0,
          operationsPerSecond: serverStatus.opcounters?.query || 0,
          documentsPerSecond: serverStatus.metrics?.document?.returned || 0
        },
        storage: {
          dataSize: dbStats.dataSize || 0,
          storageSize: dbStats.storageSize || 0,
          indexSize: dbStats.indexSize || 0,
          collections: collectionStats
        },
        replication: {
          isReplSet: !!serverStatus.repl?.setName,
          isPrimary: serverStatus.repl?.ismaster || false,
          replicationLag: serverStatus.repl?.lag || undefined
        }
      };
    } catch (error) {
      logger.error('Failed to collect MongoDB metrics:', error);
      throw error;
    }
  }

  private parseRedisInfo(info: string): Record<string, string> {
    const lines = info.split('\r\n');
    const stats: Record<string, string> = {};
    
    lines.forEach(line => {
      if (line.includes(':') && !line.startsWith('#')) {
        const [key, value] = line.split(':');
        stats[key] = value;
      }
    });
    
    return stats;
  }

  private calculateRedisHitRate(stats: Record<string, string>): number {
    const hits = parseInt(stats.keyspace_hits || '0');
    const misses = parseInt(stats.keyspace_misses || '0');
    const total = hits + misses;
    return total > 0 ? (hits / total) * 100 : 0;
  }

  private calculateRedisMissRate(stats: Record<string, string>): number {
    const hits = parseInt(stats.keyspace_hits || '0');
    const misses = parseInt(stats.keyspace_misses || '0');
    const total = hits + misses;
    return total > 0 ? (misses / total) * 100 : 0;
  }

  private getEmptyPostgresMetrics(): PostgresMetrics {
    return {
      connections: { active: 0, idle: 0, total: 0, max: 0 },
      performance: { avgQueryTime: 0, slowQueries: 0, locksWaiting: 0, deadlocks: 0 },
      storage: { databaseSize: '0 bytes', indexSize: '0 bytes', tableStats: [] },
      replication: { isReplica: false }
    };
  }

  private getEmptyRedisMetrics(): RedisMetrics {
    return {
      memory: { used: 0, peak: 0, fragmentation: 1, evictedKeys: 0 },
      performance: { commandsPerSecond: 0, hitRate: 0, missRate: 0, avgCommandTime: 0 },
      connections: { connected: 0, blocked: 0, rejected: 0 },
      persistence: { lastSave: new Date(), changesSinceLastSave: 0 }
    };
  }

  private getEmptyMongoMetrics(): MongoMetrics {
    return {
      connections: { current: 0, available: 0, totalCreated: 0 },
      performance: { avgQueryTime: 0, operationsPerSecond: 0, documentsPerSecond: 0 },
      storage: { dataSize: 0, storageSize: 0, indexSize: 0, collections: [] },
      replication: { isReplSet: false, isPrimary: false }
    };
  }

  public getMetricsHistory(): DatabaseMetrics[] {
    return [...this.metricsHistory];
  }

  public getLatestMetrics(): DatabaseMetrics | null {
    return this.metricsHistory.length > 0 
      ? this.metricsHistory[this.metricsHistory.length - 1] 
      : null;
  }

  public async generatePerformanceReport(): Promise<{
    summary: any;
    recommendations: string[];
    alerts: string[];
  }> {
    const metrics = await this.collectMetrics();
    const recommendations: string[] = [];
    const alerts: string[] = [];

    // PostgreSQL analysis
    if (metrics.postgres.connections.max > 0 && 
        metrics.postgres.connections.total / metrics.postgres.connections.max > 0.8) {
      alerts.push('PostgreSQL connection pool is near capacity');
      recommendations.push('Consider increasing max_connections or implementing connection pooling');
    }

    if (metrics.postgres.performance.avgQueryTime > 1000) {
      alerts.push('Average PostgreSQL query time is high');
      recommendations.push('Review slow queries and consider adding indexes');
    }

    if (metrics.postgres.performance.locksWaiting > 0) {
      alerts.push('PostgreSQL has queries waiting for locks');
      recommendations.push('Review long-running transactions and query patterns');
    }

    // Redis analysis
    if (metrics.redis.memory.fragmentation > 1.5) {
      alerts.push('Redis memory fragmentation is high');
      recommendations.push('Consider restarting Redis during maintenance window');
    }

    if (metrics.redis.performance.hitRate < 90) {
      alerts.push('Redis cache hit rate is low');
      recommendations.push('Review cache key expiration policies and cache warming strategies');
    }

    // MongoDB analysis
    const totalMongoConnections = metrics.mongodb.connections.current + metrics.mongodb.connections.available;
    if (totalMongoConnections > 0 && 
        metrics.mongodb.connections.current / totalMongoConnections > 0.8) {
      alerts.push('MongoDB connection pool is near capacity');
      recommendations.push('Consider increasing connection pool size');
    }

    return {
      summary: {
        timestamp: metrics.timestamp,
        postgres: {
          health: alerts.filter(a => a.includes('PostgreSQL')).length === 0 ? 'healthy' : 'warning',
          connectionUtilization: metrics.postgres.connections.max > 0 
            ? (metrics.postgres.connections.total / metrics.postgres.connections.max * 100).toFixed(1) + '%'
            : '0%',
          avgQueryTime: metrics.postgres.performance.avgQueryTime.toFixed(2) + 'ms'
        },
        redis: {
          health: alerts.filter(a => a.includes('Redis')).length === 0 ? 'healthy' : 'warning',
          memoryUtilization: (metrics.redis.memory.used / (1024 * 1024)).toFixed(1) + 'MB',
          hitRate: metrics.redis.performance.hitRate.toFixed(1) + '%'
        },
        mongodb: {
          health: alerts.filter(a => a.includes('MongoDB')).length === 0 ? 'healthy' : 'warning',
          connectionUtilization: metrics.mongodb.connections.current + metrics.mongodb.connections.available > 0 
            ? (metrics.mongodb.connections.current / (metrics.mongodb.connections.current + metrics.mongodb.connections.available) * 100).toFixed(1) + '%'
            : '0%',
          dataSize: (metrics.mongodb.storage.dataSize / (1024 * 1024)).toFixed(1) + 'MB'
        }
      },
      recommendations,
      alerts
    };
  }

  public startPeriodicCollection(intervalMs: number = 60000): NodeJS.Timeout {
    return setInterval(async () => {
      try {
        await this.collectMetrics();
      } catch (error) {
        logger.error('Periodic metrics collection failed:', error);
      }
    }, intervalMs);
  }

  public stopPeriodicCollection(interval: NodeJS.Timeout): void {
    clearInterval(interval);
  }
}

export function createDatabaseMonitor(
  postgresConnection: PostgresConnection,
  redisConnection: RedisConnection,
  mongoConnection: MongoConnection
): DatabaseMonitor {
  return new DatabaseMonitor(postgresConnection, redisConnection, mongoConnection);
}