#!/usr/bin/env ts-node

import * as dotenv from 'dotenv';
import { 
  createPostgresConnection, 
  createRedisConnection, 
  createMongoConnection,
  createMigrationManager,
  createDatabaseMonitor
} from '../services/shared/src/database';

// Load environment variables
dotenv.config();

async function testPostgreSQL(): Promise<boolean> {
  console.log('\n🔍 Testing PostgreSQL connection...');
  
  try {
    const postgres = createPostgresConnection();
    await postgres.connect();
    
    // Test basic query
    const result = await postgres.query('SELECT NOW() as timestamp, version() as version');
    console.log('✅ PostgreSQL connected successfully');
    console.log(`   Timestamp: ${result[0].timestamp}`);
    console.log(`   Version: ${result[0].version.split(' ')[0]} ${result[0].version.split(' ')[1]}`);
    
    // Test health check
    const health = await postgres.healthCheck();
    console.log(`   Health: ${health.status}`);
    console.log(`   Connections: ${health.connectionCount}`);
    
    await postgres.close();
    return true;
  } catch (error) {
    console.error('❌ PostgreSQL connection failed:', error.message);
    return false;
  }
}

async function testRedis(): Promise<boolean> {
  console.log('\n🔍 Testing Redis connection...');
  
  try {
    const redis = createRedisConnection();
    await redis.connect();
    
    // Test basic operations
    await redis.set('test:connection', 'success', 10);
    const result = await redis.get('test:connection');
    
    if (result === 'success') {
      console.log('✅ Redis connected successfully');
      
      // Test health check
      const health = await redis.healthCheck();
      console.log(`   Health: ${health.status}`);
      console.log(`   Memory: ${JSON.stringify(health.memory)}`);
      
      // Cleanup
      await redis.del('test:connection');
    } else {
      throw new Error('Redis test operation failed');
    }
    
    await redis.close();
    return true;
  } catch (error) {
    console.error('❌ Redis connection failed:', error.message);
    return false;
  }
}

async function testMongoDB(): Promise<boolean> {
  console.log('\n🔍 Testing MongoDB connection...');
  
  try {
    const mongodb = createMongoConnection();
    await mongodb.connect();
    
    // Test basic operations
    const testDoc = { test: 'connection', timestamp: new Date() };
    await mongodb.insertOne('test_collection', testDoc);
    
    const result = await mongodb.findOne('test_collection', { test: 'connection' });
    
    if (result && result.test === 'connection') {
      console.log('✅ MongoDB connected successfully');
      
      // Test health check
      const health = await mongodb.healthCheck();
      console.log(`   Health: ${health.status}`);
      console.log(`   Collections: ${health.stats?.connections?.current || 'N/A'}`);
      
      // Cleanup
      await mongodb.deleteOne('test_collection', { test: 'connection' });
    } else {
      throw new Error('MongoDB test operation failed');
    }
    
    await mongodb.close();
    return true;
  } catch (error) {
    console.error('❌ MongoDB connection failed:', error.message);
    return false;
  }
}

async function testMigrations(): Promise<boolean> {
  console.log('\n🔍 Testing Migration system...');
  
  try {
    const postgres = createPostgresConnection();
    await postgres.connect();
    
    const migrationManager = createMigrationManager(postgres, './migrations');
    
    // Check migration status
    const status = await migrationManager.getMigrationStatus();
    console.log('✅ Migration system working');
    console.log(`   Applied migrations: ${status.total_applied}`);
    console.log(`   Pending migrations: ${status.total_pending}`);
    
    if (status.pending.length > 0) {
      console.log('   Pending migrations:');
      status.pending.forEach(migration => {
        console.log(`     - ${migration.version}: ${migration.description}`);
      });
    }
    
    await postgres.close();
    return true;
  } catch (error) {
    console.error('❌ Migration system failed:', error.message);
    return false;
  }
}

async function testMonitoring(): Promise<boolean> {
  console.log('\n🔍 Testing Database monitoring...');
  
  try {
    const postgres = createPostgresConnection();
    const redis = createRedisConnection();
    const mongodb = createMongoConnection();
    
    await Promise.all([
      postgres.connect(),
      redis.connect(),
      mongodb.connect()
    ]);
    
    const monitor = createDatabaseMonitor(postgres, redis, mongodb);
    
    // Collect metrics
    const metrics = await monitor.collectMetrics();
    console.log('✅ Database monitoring working');
    console.log(`   PostgreSQL: ${metrics.postgres.connections.total} connections`);
    console.log(`   Redis: ${(metrics.redis.memory.used / (1024 * 1024)).toFixed(1)}MB memory`);
    console.log(`   MongoDB: ${metrics.mongodb.connections.current} connections`);
    
    // Generate performance report
    const report = await monitor.generatePerformanceReport();
    console.log(`   Alerts: ${report.alerts.length}`);
    console.log(`   Recommendations: ${report.recommendations.length}`);
    
    await Promise.all([
      postgres.close(),
      redis.close(),
      mongodb.close()
    ]);
    
    return true;
  } catch (error) {
    console.error('❌ Database monitoring failed:', error.message);
    return false;
  }
}

async function testDatabaseSchema(): Promise<boolean> {
  console.log('\n🔍 Testing Database schema...');
  
  try {
    const postgres = createPostgresConnection();
    await postgres.connect();
    
    // Check if main tables exist
    const tables = await postgres.query(`
      SELECT tablename 
      FROM pg_tables 
      WHERE schemaname = 'public' 
      ORDER BY tablename
    `);
    
    const requiredTables = [
      'users', 'kingdom_state', 'educational_progress', 
      'achievements', 'user_achievements', 'portfolio_snapshots'
    ];
    
    const existingTables = tables.map(t => t.tablename);
    const missingTables = requiredTables.filter(table => !existingTables.includes(table));
    
    if (missingTables.length === 0) {
      console.log('✅ Database schema is complete');
      console.log(`   Tables found: ${existingTables.length}`);
      
      // Check TimescaleDB hypertables
      const hypertables = await postgres.query(`
        SELECT hypertable_name 
        FROM timescaledb_information.hypertables
      `);
      
      if (hypertables.length > 0) {
        console.log(`   TimescaleDB hypertables: ${hypertables.map(h => h.hypertable_name).join(', ')}`);
      }
      
    } else {
      console.error(`❌ Missing tables: ${missingTables.join(', ')}`);
      await postgres.close();
      return false;
    }
    
    await postgres.close();
    return true;
  } catch (error) {
    console.error('❌ Database schema test failed:', error.message);
    return false;
  }
}

async function testMongoCollections(): Promise<boolean> {
  console.log('\n🔍 Testing MongoDB collections...');
  
  try {
    const mongodb = createMongoConnection();
    await mongodb.connect();
    
    // Check if collections exist
    const collections = await mongodb.getDatabase().listCollections().toArray();
    const collectionNames = collections.map(c => c.name);
    
    const requiredCollections = [
      'educational_modules', 'educational_content', 'learning_paths', 'content_analytics'
    ];
    
    const missingCollections = requiredCollections.filter(
      collection => !collectionNames.includes(collection)
    );
    
    if (missingCollections.length === 0) {
      console.log('✅ MongoDB collections are complete');
      console.log(`   Collections found: ${collectionNames.length}`);
      
      // Check sample data
      const moduleCount = await mongodb.getDatabase()
        .collection('educational_modules')
        .countDocuments();
      
      if (moduleCount > 0) {
        console.log(`   Sample educational modules: ${moduleCount}`);
      }
      
    } else {
      console.error(`❌ Missing collections: ${missingCollections.join(', ')}`);
      await mongodb.close();
      return false;
    }
    
    await mongodb.close();
    return true;
  } catch (error) {
    console.error('❌ MongoDB collections test failed:', error.message);
    return false;
  }
}

async function main(): Promise<void> {
  console.log('🚀 Financial Kingdom Builder - Database Connection Test');
  console.log('================================================');
  
  const tests = [
    { name: 'PostgreSQL', test: testPostgreSQL },
    { name: 'Redis', test: testRedis },
    { name: 'MongoDB', test: testMongoDB },
    { name: 'Database Schema', test: testDatabaseSchema },
    { name: 'MongoDB Collections', test: testMongoCollections },
    { name: 'Migrations', test: testMigrations },
    { name: 'Monitoring', test: testMonitoring }
  ];
  
  const results: { name: string; success: boolean }[] = [];
  
  for (const { name, test } of tests) {
    try {
      const success = await test();
      results.push({ name, success });
    } catch (error) {
      console.error(`❌ ${name} test crashed:`, error.message);
      results.push({ name, success: false });
    }
  }
  
  console.log('\n📊 Test Results Summary');
  console.log('====================');
  
  let allPassed = true;
  results.forEach(({ name, success }) => {
    const status = success ? '✅ PASS' : '❌ FAIL';
    console.log(`${status} ${name}`);
    if (!success) allPassed = false;
  });
  
  const passedCount = results.filter(r => r.success).length;
  const totalCount = results.length;
  
  console.log(`\n📈 Overall: ${passedCount}/${totalCount} tests passed`);
  
  if (allPassed) {
    console.log('🎉 All database tests passed! The system is ready.');
    process.exit(0);
  } else {
    console.log('⚠️  Some tests failed. Please check the configuration.');
    process.exit(1);
  }
}

if (require.main === module) {
  main().catch(error => {
    console.error('💥 Test suite crashed:', error);
    process.exit(1);
  });
}

export { main };