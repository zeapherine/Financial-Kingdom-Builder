// Database connections and utilities
export * from './postgres';
export * from './redis';
export * from './mongodb';
export * from './manager';
export * from './migrations';
export * from './monitoring';

// Re-export commonly used types and interfaces
export type {
  DatabaseConfig as PostgresConfig,
  PostgresConnection
} from './postgres';

export type {
  RedisConfig,
  RedisConnection
} from './redis';

export type {
  MongoConfig,
  MongoConnection
} from './mongodb';

export type {
  DatabaseConnections,
  DatabaseHealthStatus,
  DatabaseManager
} from './manager';

export type {
  Migration,
  MigrationManager
} from './migrations';

export type {
  DatabaseMetrics,
  PostgresMetrics,
  RedisMetrics,
  MongoMetrics,
  DatabaseMonitor
} from './monitoring';