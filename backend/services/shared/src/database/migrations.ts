import * as fs from 'fs';
import * as path from 'path';
import { PostgresConnection } from './postgres';
import { logger } from '../utils/logger-factory';

export interface Migration {
  version: string;
  description: string;
  sql: string;
  filename: string;
}

export class MigrationManager {
  private postgresConnection: PostgresConnection;
  private migrationsPath: string;

  constructor(postgresConnection: PostgresConnection, migrationsPath?: string) {
    this.postgresConnection = postgresConnection;
    this.migrationsPath = migrationsPath || path.join(process.cwd(), 'database', 'migrations');
  }

  public async ensureMigrationsTable(): Promise<void> {
    const sql = `
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version VARCHAR(255) PRIMARY KEY,
        description TEXT,
        applied_at TIMESTAMPTZ DEFAULT NOW()
      );
    `;
    
    await this.postgresConnection.query(sql);
    logger.info('Migrations table ensured');
  }

  public async getAppliedMigrations(): Promise<{ version: string; description: string; applied_at: Date }[]> {
    return await this.postgresConnection.query(`
      SELECT version, description, applied_at 
      FROM schema_migrations 
      ORDER BY version
    `);
  }

  public async getAvailableMigrations(): Promise<Migration[]> {
    try {
      if (!fs.existsSync(this.migrationsPath)) {
        logger.warn(`Migrations directory not found: ${this.migrationsPath}`);
        return [];
      }

      const files = fs.readdirSync(this.migrationsPath)
        .filter(file => file.endsWith('.sql'))
        .sort();

      const migrations: Migration[] = [];

      for (const filename of files) {
        const filePath = path.join(this.migrationsPath, filename);
        const sql = fs.readFileSync(filePath, 'utf8');
        
        // Extract version from filename (e.g., 001_initial_schema.sql -> 001)
        const versionMatch = filename.match(/^(\d+)/);
        if (!versionMatch) {
          logger.warn(`Skipping migration file with invalid name: ${filename}`);
          continue;
        }

        const version = versionMatch[1];
        
        // Extract description from SQL comments or filename
        const descriptionMatch = sql.match(/-- Description: (.+)/);
        const description = descriptionMatch 
          ? descriptionMatch[1].trim()
          : filename.replace(/^\d+_/, '').replace(/\.sql$/, '').replace(/_/g, ' ');

        migrations.push({
          version,
          description,
          sql,
          filename
        });
      }

      return migrations;
    } catch (error) {
      logger.error('Error reading migration files:', error);
      throw error;
    }
  }

  public async getPendingMigrations(): Promise<Migration[]> {
    const [applied, available] = await Promise.all([
      this.getAppliedMigrations(),
      this.getAvailableMigrations()
    ]);

    const appliedVersions = new Set(applied.map(m => m.version));
    
    return available.filter(migration => !appliedVersions.has(migration.version));
  }

  public async applyMigration(migration: Migration): Promise<void> {
    logger.info(`Applying migration ${migration.version}: ${migration.description}`);

    try {
      await this.postgresConnection.transaction(async (client) => {
        // Execute migration SQL
        await client.query(migration.sql);
        
        // Record migration as applied
        await client.query(
          'INSERT INTO schema_migrations (version, description) VALUES ($1, $2)',
          [migration.version, migration.description]
        );
      });

      logger.info(`Successfully applied migration ${migration.version}`);
    } catch (error) {
      logger.error(`Failed to apply migration ${migration.version}:`, error);
      throw error;
    }
  }

  public async runMigrations(): Promise<void> {
    try {
      await this.ensureMigrationsTable();
      
      const pendingMigrations = await this.getPendingMigrations();
      
      if (pendingMigrations.length === 0) {
        logger.info('No pending migrations to apply');
        return;
      }

      logger.info(`Found ${pendingMigrations.length} pending migrations`);

      for (const migration of pendingMigrations) {
        await this.applyMigration(migration);
      }

      logger.info('All migrations applied successfully');
    } catch (error) {
      logger.error('Migration run failed:', error);
      throw error;
    }
  }

  public async rollbackMigration(version: string): Promise<void> {
    logger.warn(`Rolling back migration ${version}`);
    
    try {
      // Check if rollback file exists
      const rollbackFile = path.join(this.migrationsPath, `${version}_rollback.sql`);
      
      if (!fs.existsSync(rollbackFile)) {
        throw new Error(`Rollback file not found: ${rollbackFile}`);
      }

      const rollbackSql = fs.readFileSync(rollbackFile, 'utf8');

      await this.postgresConnection.transaction(async (client) => {
        // Execute rollback SQL
        await client.query(rollbackSql);
        
        // Remove migration record
        await client.query(
          'DELETE FROM schema_migrations WHERE version = $1',
          [version]
        );
      });

      logger.info(`Successfully rolled back migration ${version}`);
    } catch (error) {
      logger.error(`Failed to rollback migration ${version}:`, error);
      throw error;
    }
  }

  public async getMigrationStatus(): Promise<{
    applied: { version: string; description: string; applied_at: Date }[];
    pending: Migration[];
    total_applied: number;
    total_pending: number;
  }> {
    const [applied, pending] = await Promise.all([
      this.getAppliedMigrations(),
      this.getPendingMigrations()
    ]);

    return {
      applied,
      pending,
      total_applied: applied.length,
      total_pending: pending.length
    };
  }
}

export function createMigrationManager(
  postgresConnection: PostgresConnection, 
  migrationsPath?: string
): MigrationManager {
  return new MigrationManager(postgresConnection, migrationsPath);
}