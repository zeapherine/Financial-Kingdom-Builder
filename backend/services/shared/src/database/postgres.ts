import { Pool, PoolConfig, PoolClient } from 'pg';
import { logger } from '../utils/logger-factory';

export interface DatabaseConfig {
  host: string;
  port: number;
  database: string;
  user: string;
  password: string;
  ssl?: boolean;
  max?: number;
  idleTimeoutMillis?: number;
  connectionTimeoutMillis?: number;
}

export class PostgresConnection {
  private pool: Pool;
  private isConnected: boolean = false;

  constructor(config: DatabaseConfig) {
    const poolConfig: PoolConfig = {
      host: config.host,
      port: config.port,
      database: config.database,
      user: config.user,
      password: config.password,
      ssl: config.ssl,
      max: config.max || 20,
      idleTimeoutMillis: config.idleTimeoutMillis || 30000,
      connectionTimeoutMillis: config.connectionTimeoutMillis || 2000,
    };

    this.pool = new Pool(poolConfig);
    this.setupEventHandlers();
  }

  private setupEventHandlers(): void {
    this.pool.on('connect', (client: PoolClient) => {
      logger.info('New PostgreSQL client connected');
      this.isConnected = true;
    });

    this.pool.on('error', (err: Error) => {
      logger.error('PostgreSQL pool error:', err);
      this.isConnected = false;
    });

    this.pool.on('remove', () => {
      logger.info('PostgreSQL client removed from pool');
    });
  }

  public async connect(): Promise<void> {
    try {
      const client = await this.pool.connect();
      await client.query('SELECT NOW()');
      client.release();
      this.isConnected = true;
      logger.info('PostgreSQL connection established successfully');
    } catch (error) {
      this.isConnected = false;
      logger.error('Failed to connect to PostgreSQL:', error);
      throw error;
    }
  }

  public async query<T = any>(text: string, params?: any[]): Promise<T[]> {
    try {
      const result = await this.pool.query(text, params);
      return result.rows;
    } catch (error) {
      logger.error('PostgreSQL query error:', { text, params, error });
      throw error;
    }
  }

  public async queryOne<T = any>(text: string, params?: any[]): Promise<T | null> {
    const results = await this.query<T>(text, params);
    return results.length > 0 ? results[0] : null;
  }

  public async transaction<T>(callback: (client: PoolClient) => Promise<T>): Promise<T> {
    const client = await this.pool.connect();
    try {
      await client.query('BEGIN');
      const result = await callback(client);
      await client.query('COMMIT');
      return result;
    } catch (error) {
      await client.query('ROLLBACK');
      logger.error('PostgreSQL transaction error:', error);
      throw error;
    } finally {
      client.release();
    }
  }

  public async healthCheck(): Promise<{ status: string; timestamp: string; connectionCount: number }> {
    try {
      const result = await this.query('SELECT NOW() as timestamp');
      return {
        status: 'healthy',
        timestamp: result[0].timestamp,
        connectionCount: this.pool.totalCount
      };
    } catch (error) {
      logger.error('PostgreSQL health check failed:', error);
      return {
        status: 'unhealthy',
        timestamp: new Date().toISOString(),
        connectionCount: 0
      };
    }
  }

  public get connected(): boolean {
    return this.isConnected;
  }

  public async close(): Promise<void> {
    try {
      await this.pool.end();
      this.isConnected = false;
      logger.info('PostgreSQL connection pool closed');
    } catch (error) {
      logger.error('Error closing PostgreSQL connection pool:', error);
      throw error;
    }
  }
}

export function createPostgresConnection(connectionUrl?: string): PostgresConnection {
  if (connectionUrl) {
    const url = new URL(connectionUrl);
    const config: DatabaseConfig = {
      host: url.hostname,
      port: parseInt(url.port) || 5432,
      database: url.pathname.slice(1),
      user: url.username,
      password: url.password,
      ssl: url.searchParams.get('ssl') === 'true'
    };
    return new PostgresConnection(config);
  }

  const config: DatabaseConfig = {
    host: process.env.POSTGRES_HOST || 'localhost',
    port: parseInt(process.env.POSTGRES_PORT || '5432'),
    database: process.env.POSTGRES_DB || 'financial_kingdom',
    user: process.env.POSTGRES_USER || 'financial_kingdom',
    password: process.env.POSTGRES_PASSWORD || 'financial_kingdom_password',
    ssl: process.env.POSTGRES_SSL === 'true'
  };

  return new PostgresConnection(config);
}