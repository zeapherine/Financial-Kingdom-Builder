import Redis, { RedisOptions } from 'ioredis';
import { logger } from '../utils/logger-factory';

export interface RedisConfig {
  host: string;
  port: number;
  password?: string;
  db?: number;
  keyPrefix?: string;
  retryDelayOnFailover?: number;
  maxRetriesPerRequest?: number;
  lazyConnect?: boolean;
}

export class RedisConnection {
  private client: Redis;
  private isConnected: boolean = false;

  constructor(config: RedisConfig) {
    const options: RedisOptions = {
      host: config.host,
      port: config.port,
      password: config.password,
      db: config.db || 0,
      keyPrefix: config.keyPrefix,
      maxRetriesPerRequest: config.maxRetriesPerRequest || 3,
      lazyConnect: config.lazyConnect !== false,
      reconnectOnError: (err) => {
        const targetErrors = ['READONLY', 'ECONNRESET', 'ENOTFOUND'];
        return targetErrors.some(targetError => err.message.includes(targetError));
      }
    };

    this.client = new Redis(options);
    this.setupEventHandlers();
  }

  private setupEventHandlers(): void {
    this.client.on('connect', () => {
      logger.info('Redis client connected');
      this.isConnected = true;
    });

    this.client.on('ready', () => {
      logger.info('Redis client ready');
      this.isConnected = true;
    });

    this.client.on('error', (err: Error) => {
      logger.error('Redis client error:', err);
      this.isConnected = false;
    });

    this.client.on('close', () => {
      logger.info('Redis client connection closed');
      this.isConnected = false;
    });

    this.client.on('reconnecting', () => {
      logger.info('Redis client reconnecting');
    });
  }

  public async connect(): Promise<void> {
    try {
      await this.client.ping();
      this.isConnected = true;
      logger.info('Redis connection established successfully');
    } catch (error) {
      this.isConnected = false;
      logger.error('Failed to connect to Redis:', error);
      throw error;
    }
  }

  // Basic operations
  public async get(key: string): Promise<string | null> {
    try {
      return await this.client.get(key);
    } catch (error) {
      logger.error('Redis GET error:', { key, error });
      throw error;
    }
  }

  public async set(key: string, value: string, ttl?: number): Promise<'OK'> {
    try {
      if (ttl) {
        return await this.client.setex(key, ttl, value);
      }
      return await this.client.set(key, value);
    } catch (error) {
      logger.error('Redis SET error:', { key, value, ttl, error });
      throw error;
    }
  }

  public async del(key: string): Promise<number> {
    try {
      return await this.client.del(key);
    } catch (error) {
      logger.error('Redis DEL error:', { key, error });
      throw error;
    }
  }

  public async exists(key: string): Promise<number> {
    try {
      return await this.client.exists(key);
    } catch (error) {
      logger.error('Redis EXISTS error:', { key, error });
      throw error;
    }
  }

  public async expire(key: string, seconds: number): Promise<number> {
    try {
      return await this.client.expire(key, seconds);
    } catch (error) {
      logger.error('Redis EXPIRE error:', { key, seconds, error });
      throw error;
    }
  }

  // Hash operations for session management
  public async hget(key: string, field: string): Promise<string | null> {
    try {
      return await this.client.hget(key, field);
    } catch (error) {
      logger.error('Redis HGET error:', { key, field, error });
      throw error;
    }
  }

  public async hset(key: string, field: string, value: string): Promise<number> {
    try {
      return await this.client.hset(key, field, value);
    } catch (error) {
      logger.error('Redis HSET error:', { key, field, value, error });
      throw error;
    }
  }

  public async hgetall(key: string): Promise<Record<string, string>> {
    try {
      return await this.client.hgetall(key);
    } catch (error) {
      logger.error('Redis HGETALL error:', { key, error });
      throw error;
    }
  }

  public async hdel(key: string, ...fields: string[]): Promise<number> {
    try {
      return await this.client.hdel(key, ...fields);
    } catch (error) {
      logger.error('Redis HDEL error:', { key, fields, error });
      throw error;
    }
  }

  // Sorted set operations for leaderboards
  public async zadd(key: string, score: number, member: string): Promise<number> {
    try {
      return await this.client.zadd(key, score, member);
    } catch (error) {
      logger.error('Redis ZADD error:', { key, score, member, error });
      throw error;
    }
  }

  public async zrevrange(key: string, start: number, stop: number, withScores = false): Promise<string[]> {
    try {
      if (withScores) {
        return await this.client.zrevrange(key, start, stop, 'WITHSCORES');
      }
      return await this.client.zrevrange(key, start, stop);
    } catch (error) {
      logger.error('Redis ZREVRANGE error:', { key, start, stop, withScores, error });
      throw error;
    }
  }

  public async zrank(key: string, member: string): Promise<number | null> {
    try {
      return await this.client.zrank(key, member);
    } catch (error) {
      logger.error('Redis ZRANK error:', { key, member, error });
      throw error;
    }
  }

  public async zscore(key: string, member: string): Promise<string | null> {
    try {
      return await this.client.zscore(key, member);
    } catch (error) {
      logger.error('Redis ZSCORE error:', { key, member, error });
      throw error;
    }
  }

  // JSON operations for complex data structures
  public async setJson(key: string, value: any, ttl?: number): Promise<'OK'> {
    try {
      const jsonValue = JSON.stringify(value);
      return await this.set(key, jsonValue, ttl);
    } catch (error) {
      logger.error('Redis setJson error:', { key, value, ttl, error });
      throw error;
    }
  }

  public async getJson<T = any>(key: string): Promise<T | null> {
    try {
      const value = await this.get(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      logger.error('Redis getJson error:', { key, error });
      throw error;
    }
  }

  // Session management helpers
  public async createSession(sessionId: string, userId: string, sessionData: any, ttl = 86400): Promise<void> {
    try {
      const sessionKey = `session:${sessionId}`;
      await this.setJson(sessionKey, { userId, ...sessionData }, ttl);
      
      // Also maintain user sessions index
      const userSessionsKey = `user_sessions:${userId}`;
      await this.client.sadd(userSessionsKey, sessionId);
      await this.expire(userSessionsKey, ttl);
    } catch (error) {
      logger.error('Redis createSession error:', { sessionId, userId, error });
      throw error;
    }
  }

  public async getSession(sessionId: string): Promise<any | null> {
    try {
      const sessionKey = `session:${sessionId}`;
      return await this.getJson(sessionKey);
    } catch (error) {
      logger.error('Redis getSession error:', { sessionId, error });
      throw error;
    }
  }

  public async deleteSession(sessionId: string): Promise<void> {
    try {
      const session = await this.getSession(sessionId);
      if (session && session.userId) {
        const userSessionsKey = `user_sessions:${session.userId}`;
        await this.client.srem(userSessionsKey, sessionId);
      }
      
      const sessionKey = `session:${sessionId}`;
      await this.del(sessionKey);
    } catch (error) {
      logger.error('Redis deleteSession error:', { sessionId, error });
      throw error;
    }
  }

  public async healthCheck(): Promise<{ status: string; timestamp: string; memory: any }> {
    try {
      const ping = await this.client.ping();
      const info = await this.client.info('memory');
      
      return {
        status: ping === 'PONG' ? 'healthy' : 'unhealthy',
        timestamp: new Date().toISOString(),
        memory: info
      };
    } catch (error) {
      logger.error('Redis health check failed:', error);
      return {
        status: 'unhealthy',
        timestamp: new Date().toISOString(),
        memory: null
      };
    }
  }

  public get connected(): boolean {
    return this.isConnected;
  }

  public getClient(): Redis {
    return this.client;
  }

  public async close(): Promise<void> {
    try {
      await this.client.quit();
      this.isConnected = false;
      logger.info('Redis connection closed');
    } catch (error) {
      logger.error('Error closing Redis connection:', error);
      throw error;
    }
  }
}

export function createRedisConnection(connectionUrl?: string): RedisConnection {
  if (connectionUrl) {
    const url = new URL(connectionUrl);
    const config: RedisConfig = {
      host: url.hostname,
      port: parseInt(url.port) || 6379,
      password: url.password || undefined,
      db: url.pathname ? parseInt(url.pathname.slice(1)) : 0
    };
    return new RedisConnection(config);
  }

  const config: RedisConfig = {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379'),
    password: process.env.REDIS_PASSWORD || undefined,
    db: parseInt(process.env.REDIS_DB || '0'),
    keyPrefix: process.env.REDIS_KEY_PREFIX || 'fkb:'
  };

  return new RedisConnection(config);
}