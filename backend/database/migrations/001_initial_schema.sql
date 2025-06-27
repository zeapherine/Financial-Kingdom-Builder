-- Migration: 001_initial_schema.sql
-- Description: Create initial database schema
-- Date: 2025-06-27

-- Create migrations tracking table
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(255) PRIMARY KEY,
    description TEXT,
    applied_at TIMESTAMPTZ DEFAULT NOW()
);

-- Record this migration
INSERT INTO schema_migrations (version, description) 
VALUES ('001', 'Initial database schema creation')
ON CONFLICT (version) DO NOTHING;

-- All tables are created in the init script
-- This migration just tracks that the initial schema has been applied