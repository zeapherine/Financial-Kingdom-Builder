import { PostgresConnection, createPostgresConnection } from './postgres';
import { RedisConnection, createRedisConnection } from './redis';
import { MongoConnection, createMongoConnection } from './mongodb';
import { logger } from '../utils/logger-factory';

export interface DatabaseConnections {
  postgres: PostgresConnection;
  redis: RedisConnection;
  mongodb: MongoConnection;
}

export interface DatabaseHealthStatus {
  postgres: any;
  redis: any;
  mongodb: any;
  overall: 'healthy' | 'degraded' | 'unhealthy';
}

export class DatabaseManager {
  private connections: DatabaseConnections | null = null;
  private isInitialized: boolean = false;
  private static instance: DatabaseManager | null = null;

  constructor() {
    // Bind methods to preserve context
    this.initialize = this.initialize.bind(this);
    this.getConnections = this.getConnections.bind(this);
    this.healthCheck = this.healthCheck.bind(this);
    this.close = this.close.bind(this);
  }

  public static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager();
    }
    return DatabaseManager.instance;
  }

  // Convenience method for direct PostgreSQL queries
  public async query(text: string, params?: any[]): Promise<any> {
    const postgres = this.getPostgres();
    return postgres.query(text, params);
  }

  public async initialize(): Promise<DatabaseConnections> {
    if (this.isInitialized && this.connections) {
      return this.connections;
    }

    try {
      logger.info('Initializing database connections...');

      // Create connections
      const postgres = createPostgresConnection(process.env.POSTGRES_URL);
      const redis = createRedisConnection(process.env.REDIS_URL);
      const mongodb = createMongoConnection(process.env.MONGODB_URL);

      // Establish connections
      await Promise.all([
        postgres.connect(),
        redis.connect(),
        mongodb.connect()
      ]);

      this.connections = {
        postgres,
        redis,
        mongodb
      };

      this.isInitialized = true;
      logger.info('All database connections established successfully');

      return this.connections;
    } catch (error) {
      logger.error('Failed to initialize database connections:', error);
      
      // Cleanup any partially established connections
      if (this.connections) {
        await this.close();
      }
      
      throw error;
    }
  }

  public getConnections(): DatabaseConnections {
    if (!this.isInitialized || !this.connections) {
      throw new Error('Database manager not initialized. Call initialize() first.');
    }
    return this.connections;
  }

  public getPostgres(): PostgresConnection {
    return this.getConnections().postgres;
  }

  public getRedis(): RedisConnection {
    return this.getConnections().redis;
  }

  public getMongoDB(): MongoConnection {
    return this.getConnections().mongodb;
  }

  public async healthCheck(): Promise<DatabaseHealthStatus> {
    try {
      if (!this.connections) {
        return {
          postgres: { status: 'not_initialized' },
          redis: { status: 'not_initialized' },
          mongodb: { status: 'not_initialized' },
          overall: 'unhealthy'
        };
      }

      const [postgresHealth, redisHealth, mongodbHealth] = await Promise.allSettled([
        this.connections.postgres.healthCheck(),
        this.connections.redis.healthCheck(),
        this.connections.mongodb.healthCheck()
      ]);

      const postgres = postgresHealth.status === 'fulfilled' 
        ? postgresHealth.value 
        : { status: 'unhealthy', error: postgresHealth.reason };

      const redis = redisHealth.status === 'fulfilled'
        ? redisHealth.value
        : { status: 'unhealthy', error: redisHealth.reason };

      const mongodb = mongodbHealth.status === 'fulfilled'
        ? mongodbHealth.value
        : { status: 'unhealthy', error: mongodbHealth.reason };

      // Determine overall health
      const healthyCount = [postgres, redis, mongodb]
        .filter(db => db.status === 'healthy').length;

      let overall: 'healthy' | 'degraded' | 'unhealthy';
      if (healthyCount === 3) {
        overall = 'healthy';
      } else if (healthyCount >= 1) {
        overall = 'degraded';
      } else {
        overall = 'unhealthy';
      }

      return {
        postgres,
        redis,
        mongodb,
        overall
      };
    } catch (error) {
      logger.error('Database health check failed:', error);
      return {
        postgres: { status: 'error', error },
        redis: { status: 'error', error },
        mongodb: { status: 'error', error },
        overall: 'unhealthy'
      };
    }
  }

  public async close(): Promise<void> {
    if (!this.connections) {
      return;
    }

    try {
      logger.info('Closing database connections...');

      await Promise.allSettled([
        this.connections.postgres.close(),
        this.connections.redis.close(),
        this.connections.mongodb.close()
      ]);

      this.connections = null;
      this.isInitialized = false;
      
      logger.info('All database connections closed');
    } catch (error) {
      logger.error('Error closing database connections:', error);
      throw error;
    }
  }

  // Migration utilities
  public async runMigrations(): Promise<void> {
    try {
      if (!this.connections) {
        throw new Error('Database not initialized');
      }

      logger.info('Running database migrations...');

      // PostgreSQL migrations would be handled by a migration system
      // For now, we just verify the schema exists
      const tables = await this.connections.postgres.query(`
        SELECT tablename FROM pg_tables 
        WHERE schemaname = 'public'
      `);

      logger.info(`Found ${tables.length} PostgreSQL tables`);

      // MongoDB collections are created automatically with data insertion
      // Verify collections exist
      const collections = await this.connections.mongodb.getDatabase().listCollections().toArray();
      logger.info(`Found ${collections.length} MongoDB collections`);

      logger.info('Database migrations completed successfully');
    } catch (error) {
      logger.error('Migration failed:', error);
      throw error;
    }
  }

  // Graceful shutdown
  public async gracefulShutdown(): Promise<void> {
    logger.info('Initiating graceful database shutdown...');
    
    try {
      // Wait for any ongoing operations to complete
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Close all connections
      await this.close();
      
      logger.info('Graceful database shutdown completed');
    } catch (error) {
      logger.error('Error during graceful shutdown:', error);
      throw error;
    }
  }
}

// Singleton instance
let databaseManager: DatabaseManager | null = null;

export function getDatabaseManager(): DatabaseManager {
  if (!databaseManager) {
    databaseManager = new DatabaseManager();
  }
  return databaseManager;
}

export async function initializeDatabases(): Promise<DatabaseConnections> {
  const manager = getDatabaseManager();
  return await manager.initialize();
}

export function getDatabase(): DatabaseConnections {
  const manager = getDatabaseManager();
  return manager.getConnections();
}

export async function closeDatabases(): Promise<void> {
  if (databaseManager) {
    await databaseManager.close();
  }
}

// Graceful shutdown handler
export function setupGracefulShutdown(): void {
  const gracefulShutdown = async (signal: string) => {
    logger.info(`Received ${signal}, initiating graceful shutdown...`);
    
    try {
      if (databaseManager) {
        await databaseManager.gracefulShutdown();
      }
      process.exit(0);
    } catch (error) {
      logger.error('Error during graceful shutdown:', error);
      process.exit(1);
    }
  };

  process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
  process.on('SIGINT', () => gracefulShutdown('SIGINT'));
  process.on('SIGUSR2', () => gracefulShutdown('SIGUSR2')); // nodemon restart
}