import { MongoClient, Db, Collection, MongoClientOptions, Document } from 'mongodb';
import { logger } from '../utils/logger-factory';

export interface MongoConfig {
  url: string;
  dbName: string;
  options?: MongoClientOptions;
}

export class MongoConnection {
  private client: MongoClient;
  private db: Db | null = null;
  private isConnected: boolean = false;
  private config: MongoConfig;

  constructor(config: MongoConfig) {
    this.config = config;
    
    const defaultOptions: MongoClientOptions = {
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
      family: 4
    };

    this.client = new MongoClient(config.url, {
      ...defaultOptions,
      ...config.options
    });

    this.setupEventHandlers();
  }

  private setupEventHandlers(): void {
    this.client.on('connectionPoolCreated', () => {
      logger.info('MongoDB connection pool created');
    });

    this.client.on('connectionPoolClosed', () => {
      logger.info('MongoDB connection pool closed');
      this.isConnected = false;
    });

    this.client.on('commandStarted', (event) => {
      logger.debug('MongoDB command started:', {
        commandName: event.commandName,
        databaseName: event.databaseName,
        requestId: event.requestId
      });
    });

    this.client.on('commandFailed', (event) => {
      logger.error('MongoDB command failed:', {
        commandName: event.commandName,
        failure: event.failure,
        requestId: event.requestId
      });
    });
  }

  public async connect(): Promise<void> {
    try {
      await this.client.connect();
      this.db = this.client.db(this.config.dbName);
      
      // Test the connection
      await this.db.admin().ping();
      
      this.isConnected = true;
      logger.info('MongoDB connection established successfully');
    } catch (error) {
      this.isConnected = false;
      logger.error('Failed to connect to MongoDB:', error);
      throw error;
    }
  }

  public getDatabase(): Db {
    if (!this.db) {
      throw new Error('MongoDB not connected. Call connect() first.');
    }
    return this.db;
  }

  public getCollection<T extends Document = Document>(name: string): Collection<T> {
    if (!this.db) {
      throw new Error('MongoDB not connected. Call connect() first.');
    }
    return this.db.collection<T>(name);
  }

  // Educational Modules operations
  public async getEducationalModule(moduleId: string): Promise<any | null> {
    try {
      const collection = this.getCollection('educational_modules');
      return await collection.findOne({ id: moduleId, isActive: true });
    } catch (error) {
      logger.error('Error getting educational module:', { moduleId, error });
      throw error;
    }
  }

  public async getEducationalModulesByTier(tier: number): Promise<any[]> {
    try {
      const collection = this.getCollection('educational_modules');
      return await collection
        .find({ tier, isActive: true })
        .sort({ createdAt: 1 })
        .toArray();
    } catch (error) {
      logger.error('Error getting educational modules by tier:', { tier, error });
      throw error;
    }
  }

  public async getEducationalModulesByCategory(category: string): Promise<any[]> {
    try {
      const collection = this.getCollection('educational_modules');
      return await collection
        .find({ category, isActive: true })
        .sort({ createdAt: 1 })
        .toArray();
    } catch (error) {
      logger.error('Error getting educational modules by category:', { category, error });
      throw error;
    }
  }

  public async searchEducationalModules(searchTerm: string): Promise<any[]> {
    try {
      const collection = this.getCollection('educational_modules');
      return await collection
        .find({
          $and: [
            { isActive: true },
            {
              $or: [
                { title: { $regex: searchTerm, $options: 'i' } },
                { description: { $regex: searchTerm, $options: 'i' } },
                { tags: { $in: [new RegExp(searchTerm, 'i')] } }
              ]
            }
          ]
        })
        .sort({ createdAt: 1 })
        .toArray();
    } catch (error) {
      logger.error('Error searching educational modules:', { searchTerm, error });
      throw error;
    }
  }

  // Learning Paths operations
  public async getLearningPath(pathId: string): Promise<any | null> {
    try {
      const collection = this.getCollection('learning_paths');
      return await collection.findOne({ id: pathId, isActive: true });
    } catch (error) {
      logger.error('Error getting learning path:', { pathId, error });
      throw error;
    }
  }

  public async getLearningPathsByTier(tier: number): Promise<any[]> {
    try {
      const collection = this.getCollection('learning_paths');
      return await collection
        .find({ tier, isActive: true })
        .sort({ createdAt: 1 })
        .toArray();
    } catch (error) {
      logger.error('Error getting learning paths by tier:', { tier, error });
      throw error;
    }
  }

  // Content Analytics operations
  public async trackContentEvent(event: {
    contentId: string;
    contentType: string;
    userId: string;
    event: string;
    metadata?: any;
    sessionId?: string;
  }): Promise<void> {
    try {
      const collection = this.getCollection('content_analytics');
      await collection.insertOne({
        ...event,
        timestamp: new Date()
      });
    } catch (error) {
      logger.error('Error tracking content event:', { event, error });
      throw error;
    }
  }

  public async getContentAnalytics(contentId: string, timeframe?: { start: Date; end: Date }): Promise<any[]> {
    try {
      const collection = this.getCollection('content_analytics');
      const query: any = { contentId };
      
      if (timeframe) {
        query.timestamp = {
          $gte: timeframe.start,
          $lte: timeframe.end
        };
      }
      
      return await collection
        .find(query)
        .sort({ timestamp: -1 })
        .toArray();
    } catch (error) {
      logger.error('Error getting content analytics:', { contentId, timeframe, error });
      throw error;
    }
  }

  // User Bookmarks operations
  public async addBookmark(userId: string, contentId: string, contentType: string, notes?: string, tags?: string[]): Promise<void> {
    try {
      const collection = this.getCollection('user_bookmarks');
      await collection.updateOne(
        { userId, contentId },
        {
          $set: {
            userId,
            contentId,
            contentType,
            notes,
            tags,
            createdAt: new Date()
          }
        },
        { upsert: true }
      );
    } catch (error) {
      logger.error('Error adding bookmark:', { userId, contentId, contentType, error });
      throw error;
    }
  }

  public async removeBookmark(userId: string, contentId: string): Promise<void> {
    try {
      const collection = this.getCollection('user_bookmarks');
      await collection.deleteOne({ userId, contentId });
    } catch (error) {
      logger.error('Error removing bookmark:', { userId, contentId, error });
      throw error;
    }
  }

  public async getUserBookmarks(userId: string, contentType?: string): Promise<any[]> {
    try {
      const collection = this.getCollection('user_bookmarks');
      const query: any = { userId };
      
      if (contentType) {
        query.contentType = contentType;
      }
      
      return await collection
        .find(query)
        .sort({ createdAt: -1 })
        .toArray();
    } catch (error) {
      logger.error('Error getting user bookmarks:', { userId, contentType, error });
      throw error;
    }
  }

  // Generic CRUD operations
  public async insertOne(collectionName: string, document: any): Promise<any> {
    try {
      const collection = this.getCollection(collectionName);
      return await collection.insertOne(document);
    } catch (error) {
      logger.error('Error inserting document:', { collectionName, error });
      throw error;
    }
  }

  public async insertMany(collectionName: string, documents: any[]): Promise<any> {
    try {
      const collection = this.getCollection(collectionName);
      return await collection.insertMany(documents);
    } catch (error) {
      logger.error('Error inserting documents:', { collectionName, count: documents.length, error });
      throw error;
    }
  }

  public async findOne<T = any>(collectionName: string, query: any): Promise<T | null> {
    try {
      const collection = this.getCollection(collectionName);
      return await collection.findOne(query) as T | null;
    } catch (error) {
      logger.error('Error finding document:', { collectionName, query, error });
      throw error;
    }
  }

  public async find<T = any>(collectionName: string, query: any, options?: any): Promise<T[]> {
    try {
      const collection = this.getCollection(collectionName);
      const result = await collection.find(query, options).toArray();
      return result as T[];
    } catch (error) {
      logger.error('Error finding documents:', { collectionName, query, options, error });
      throw error;
    }
  }

  public async updateOne(collectionName: string, filter: any, update: any, options?: any): Promise<any> {
    try {
      const collection = this.getCollection(collectionName);
      return await collection.updateOne(filter, update, options);
    } catch (error) {
      logger.error('Error updating document:', { collectionName, filter, update, error });
      throw error;
    }
  }

  public async updateMany(collectionName: string, filter: any, update: any, options?: any): Promise<any> {
    try {
      const collection = this.getCollection(collectionName);
      return await collection.updateMany(filter, update, options);
    } catch (error) {
      logger.error('Error updating documents:', { collectionName, filter, update, error });
      throw error;
    }
  }

  public async deleteOne(collectionName: string, filter: any): Promise<any> {
    try {
      const collection = this.getCollection(collectionName);
      return await collection.deleteOne(filter);
    } catch (error) {
      logger.error('Error deleting document:', { collectionName, filter, error });
      throw error;
    }
  }

  public async deleteMany(collectionName: string, filter: any): Promise<any> {
    try {
      const collection = this.getCollection(collectionName);
      return await collection.deleteMany(filter);
    } catch (error) {
      logger.error('Error deleting documents:', { collectionName, filter, error });
      throw error;
    }
  }

  public async healthCheck(): Promise<{ status: string; timestamp: string; stats: any }> {
    try {
      if (!this.db) {
        throw new Error('Database not connected');
      }
      
      await this.db.admin().ping();
      const stats = await this.db.admin().serverStatus();
      
      return {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        stats: {
          uptime: stats.uptime,
          connections: stats.connections,
          memory: stats.mem
        }
      };
    } catch (error) {
      logger.error('MongoDB health check failed:', error);
      return {
        status: 'unhealthy',
        timestamp: new Date().toISOString(),
        stats: null
      };
    }
  }

  public get connected(): boolean {
    return this.isConnected;
  }

  public async close(): Promise<void> {
    try {
      await this.client.close();
      this.isConnected = false;
      this.db = null;
      logger.info('MongoDB connection closed');
    } catch (error) {
      logger.error('Error closing MongoDB connection:', error);
      throw error;
    }
  }
}

export function createMongoConnection(connectionUrl?: string): MongoConnection {
  const url = connectionUrl || process.env.MONGODB_URL || 'mongodb://localhost:27017';
  const dbName = process.env.MONGODB_DB || 'financial_kingdom';

  const config: MongoConfig = {
    url,
    dbName,
    options: {
      maxPoolSize: parseInt(process.env.MONGODB_MAX_POOL_SIZE || '10'),
      serverSelectionTimeoutMS: parseInt(process.env.MONGODB_SERVER_SELECTION_TIMEOUT || '5000'),
      socketTimeoutMS: parseInt(process.env.MONGODB_SOCKET_TIMEOUT || '45000')
    }
  };

  return new MongoConnection(config);
}