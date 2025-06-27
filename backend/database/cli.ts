#!/usr/bin/env ts-node

import * as dotenv from 'dotenv';
import { createPostgresConnection, createMigrationManager } from '../services/shared/src/database';

// Load environment variables
dotenv.config();

interface CliArgs {
  command: string;
  args: string[];
}

function parseArgs(): CliArgs {
  const args = process.argv.slice(2);
  const command = args[0] || 'help';
  return { command, args: args.slice(1) };
}

function printUsage(): void {
  console.log(`
Database Management CLI

Usage: ts-node cli.ts <command> [options]

Commands:
  migrate         Run pending migrations
  migrate:status  Show migration status
  migrate:rollback <version>  Rollback specific migration
  health          Check database health
  help            Show this help message

Examples:
  ts-node cli.ts migrate
  ts-node cli.ts migrate:status
  ts-node cli.ts migrate:rollback 001
  ts-node cli.ts health
  `);
}

async function runMigrations(): Promise<void> {
  const postgres = createPostgresConnection();
  const migrationManager = createMigrationManager(postgres, './migrations');

  try {
    await postgres.connect();
    console.log('✅ Connected to PostgreSQL');
    
    await migrationManager.runMigrations();
    console.log('✅ Migrations completed successfully');
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  } finally {
    await postgres.close();
  }
}

async function showMigrationStatus(): Promise<void> {
  const postgres = createPostgresConnection();
  const migrationManager = createMigrationManager(postgres, './migrations');

  try {
    await postgres.connect();
    console.log('✅ Connected to PostgreSQL');
    
    const status = await migrationManager.getMigrationStatus();
    
    console.log('\n📊 Migration Status:');
    console.log(`Applied: ${status.total_applied}`);
    console.log(`Pending: ${status.total_pending}`);
    
    if (status.applied.length > 0) {
      console.log('\n✅ Applied Migrations:');
      status.applied.forEach(migration => {
        console.log(`  ${migration.version}: ${migration.description} (${migration.applied_at.toISOString()})`);
      });
    }
    
    if (status.pending.length > 0) {
      console.log('\n⏳ Pending Migrations:');
      status.pending.forEach(migration => {
        console.log(`  ${migration.version}: ${migration.description}`);
      });
    } else {
      console.log('\n✅ All migrations are up to date');
    }
  } catch (error) {
    console.error('❌ Failed to get migration status:', error);
    process.exit(1);
  } finally {
    await postgres.close();
  }
}

async function rollbackMigration(version: string): Promise<void> {
  if (!version) {
    console.error('❌ Please specify a migration version to rollback');
    process.exit(1);
  }

  const postgres = createPostgresConnection();
  const migrationManager = createMigrationManager(postgres, './migrations');

  try {
    await postgres.connect();
    console.log('✅ Connected to PostgreSQL');
    
    await migrationManager.rollbackMigration(version);
    console.log(`✅ Migration ${version} rolled back successfully`);
  } catch (error) {
    console.error(`❌ Rollback failed:`, error);
    process.exit(1);
  } finally {
    await postgres.close();
  }
}

async function checkHealth(): Promise<void> {
  const postgres = createPostgresConnection();

  try {
    await postgres.connect();
    const health = await postgres.healthCheck();
    
    console.log('🏥 Database Health Check:');
    console.log(`Status: ${health.status}`);
    console.log(`Timestamp: ${health.timestamp}`);
    console.log(`Connections: ${health.connectionCount}`);
    
    if (health.status === 'healthy') {
      console.log('✅ Database is healthy');
    } else {
      console.log('❌ Database is unhealthy');
      process.exit(1);
    }
  } catch (error) {
    console.error('❌ Health check failed:', error);
    process.exit(1);
  } finally {
    await postgres.close();
  }
}

async function main(): Promise<void> {
  const { command, args } = parseArgs();

  switch (command) {
    case 'migrate':
      await runMigrations();
      break;
    case 'migrate:status':
      await showMigrationStatus();
      break;
    case 'migrate:rollback':
      await rollbackMigration(args[0]);
      break;
    case 'health':
      await checkHealth();
      break;
    case 'help':
    default:
      printUsage();
      break;
  }
}

if (require.main === module) {
  main().catch(error => {
    console.error('❌ CLI error:', error);
    process.exit(1);
  });
}

export { main };