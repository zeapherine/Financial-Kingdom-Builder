# Financial Kingdom Builder - Database Architecture

## Overview

This directory contains the complete database architecture for the Financial Kingdom Builder application, implementing a multi-database system optimized for scalability, performance, and reliability.

## Database Stack

### PostgreSQL with TimescaleDB
- **Purpose**: User profiles, trading data, achievements, social connections
- **Features**: ACID compliance, complex queries, time-series optimization
- **Port**: 5432
- **Key Tables**: `users`, `kingdom_state`, `educational_progress`, `achievements`, `portfolio_snapshots`

### Redis
- **Purpose**: Session management, caching, leaderboards
- **Features**: In-memory performance, pub/sub, data structures
- **Port**: 6379
- **Use Cases**: User sessions, real-time leaderboards, API response caching

### MongoDB
- **Purpose**: Educational content, analytics, flexible data
- **Features**: Document storage, flexible schema, content management
- **Port**: 27017
- **Collections**: `educational_modules`, `learning_paths`, `content_analytics`

## Directory Structure

```
database/
├── README.md                    # This file
├── BACKUP_RECOVERY.md          # Comprehensive backup procedures
├── cli.ts                      # Database management CLI tool
├── test-connections.ts         # Connection testing suite
├── init/                       # Database initialization scripts
│   └── 01-init-database.sql   # PostgreSQL schema and data
├── migrations/                 # PostgreSQL migration files
│   └── 001_initial_schema.sql # Initial migration
└── mongodb-init/              # MongoDB initialization scripts
    └── 01-init-collections.js # Collections and sample data
```

## Quick Start

### 1. Start Database Services

```bash
# Start all databases with Docker Compose
cd /path/to/backend
docker-compose up postgres redis mongodb -d

# Wait for services to be ready
docker-compose logs -f postgres redis mongodb
```

### 2. Test Connections

```bash
# Run comprehensive connection tests
cd database
ts-node test-connections.ts
```

### 3. Run Migrations

```bash
# Check migration status
ts-node cli.ts migrate:status

# Run pending migrations
ts-node cli.ts migrate

# Check database health
ts-node cli.ts health
```

## Environment Variables

Set these environment variables for database connections:

```bash
# PostgreSQL
POSTGRES_URL=postgresql://financial_kingdom:financial_kingdom_password@localhost:5432/financial_kingdom

# Redis
REDIS_URL=redis://:financial_kingdom_redis_password@localhost:6379

# MongoDB
MONGODB_URL=mongodb://financial_kingdom:financial_kingdom_mongodb_password@localhost:27017/financial_kingdom?authSource=admin
```

## Database Schema

### PostgreSQL Tables

#### Core User Tables
- **`users`**: User authentication and basic profile information
- **`user_sessions`**: Session management with device tracking
- **`user_preferences`**: Application settings and preferences

#### Kingdom & Gamification
- **`kingdom_state`**: User progression, XP, tier levels, virtual/real balances
- **`achievements`**: Achievement definitions and rewards
- **`user_achievements`**: User-earned achievements with timestamps

#### Educational System
- **`educational_progress`**: Module completion tracking and scores
- **`portfolio_snapshots`**: TimescaleDB hypertable for time-series trading data

#### Trading & Social
- **`trading_accounts`**: Real trading account integration
- **`social_connections`**: Friend system and social network

### MongoDB Collections

#### Educational Content
- **`educational_modules`**: Rich educational content with quizzes
- **`learning_paths`**: Structured learning journeys by tier
- **`educational_content`**: Flexible content storage (articles, videos, etc.)

#### Analytics & Tracking
- **`content_analytics`**: User interaction tracking
- **`user_bookmarks`**: Saved content and user notes

### Redis Data Structures

#### Sessions
- **`session:{sessionId}`**: User session data (JSON)
- **`user_sessions:{userId}`**: Set of active sessions per user

#### Leaderboards
- **`leaderboard:xp`**: Sorted set of user XP rankings
- **`leaderboard:streak`**: Sorted set of learning streak rankings

#### Cache
- **`cache:{key}`**: General application caching
- **Prefixed keys**: All keys use `fkb:` prefix for namespace isolation

## Database Management

### CLI Commands

```bash
# Migration management
ts-node cli.ts migrate           # Run pending migrations
ts-node cli.ts migrate:status    # Show migration status
ts-node cli.ts migrate:rollback  # Rollback specific migration

# Health monitoring
ts-node cli.ts health           # Check database health

# Connection testing
ts-node test-connections.ts     # Comprehensive connection test
```

### Shared Database Package

The `@financial-kingdom/shared` package provides:

- **Connection management**: Centralized database connections
- **Health monitoring**: Real-time metrics and alerting
- **Migration system**: Version-controlled schema changes
- **Performance monitoring**: Database metrics collection

### Usage in Microservices

```typescript
import { 
  initializeDatabases, 
  getDatabaseManager,
  createHealthChecker 
} from '@financial-kingdom/shared';

// Initialize all database connections
await initializeDatabases();

// Get database connections
const { postgres, redis, mongodb } = getDatabaseManager().getConnections();

// Use databases
const user = await postgres.queryOne('SELECT * FROM users WHERE id = $1', [userId]);
await redis.set(`cache:user:${userId}`, JSON.stringify(user), 3600);
const modules = await mongodb.find('educational_modules', { tier: 1 });
```

## Performance Optimization

### PostgreSQL Optimizations
- **Connection pooling**: 20 connections per service
- **Shared buffers**: 256MB for improved caching
- **Work memory**: 64MB for complex queries
- **TimescaleDB**: Automatic partitioning for time-series data

### Redis Optimizations
- **Memory policy**: `allkeys-lru` with 512MB limit
- **Persistence**: RDB snapshots + AOF for durability
- **Key expiration**: Automatic cleanup of old sessions

### MongoDB Optimizations
- **Connection pooling**: 10 connections per service
- **Indexes**: Optimized for common query patterns
- **Aggregation**: Efficient content analytics pipelines

## Monitoring & Alerting

### Health Endpoints
- **`/health`**: Basic database connectivity
- **`/health/detailed`**: Performance metrics and recommendations
- **`/ready`**: Kubernetes readiness probe
- **`/live`**: Kubernetes liveness probe
- **`/metrics`**: Real-time database metrics
- **`/metrics/history`**: Historical performance data

### Key Metrics Tracked
- **Connection utilization**: Active vs. available connections
- **Query performance**: Average response times and slow queries
- **Memory usage**: Redis memory and PostgreSQL buffers
- **Storage growth**: Database and collection sizes
- **Error rates**: Failed queries and connection errors

### Alerting Thresholds
- **Connection pool > 80%**: Scale or optimize connections
- **Query time > 1000ms**: Review slow queries
- **Redis hit rate < 90%**: Improve caching strategy
- **Memory fragmentation > 1.5**: Consider Redis restart

## Security

### Authentication
- **PostgreSQL**: User-based authentication with restricted permissions
- **Redis**: Password authentication required
- **MongoDB**: Username/password with role-based access

### Data Protection
- **Encryption at rest**: All volumes encrypted
- **Password hashing**: bcrypt with salt for user passwords
- **API keys**: Environment variables only, never in code
- **Session security**: JWT tokens with refresh rotation

### Network Security
- **Internal networking**: Database services not exposed externally
- **Service authentication**: Internal service-to-service authentication
- **Input validation**: SQL injection and NoSQL injection prevention

## Backup & Recovery

See [BACKUP_RECOVERY.md](./BACKUP_RECOVERY.md) for comprehensive backup and disaster recovery procedures.

### Daily Backups
- **PostgreSQL**: Compressed dumps with WAL archiving
- **Redis**: RDB snapshots with AOF logs
- **MongoDB**: Compressed archives with oplog

### Recovery Testing
- **Monthly**: Automated recovery tests in staging environment
- **Procedures**: Documented step-by-step recovery processes
- **RTO/RPO**: < 4 hours recovery time, < 15 minutes data loss

## Development Workflow

### Local Development
1. Start databases: `docker-compose up postgres redis mongodb -d`
2. Run tests: `ts-node database/test-connections.ts`
3. Apply migrations: `ts-node database/cli.ts migrate`
4. Start services: `npm run dev`

### Schema Changes
1. Create migration file in `migrations/`
2. Test migration locally
3. Apply to staging environment
4. Review and approve changes
5. Apply to production during maintenance window

### Testing
- **Unit tests**: Database connection and query logic
- **Integration tests**: Full database stack testing
- **Performance tests**: Load testing with realistic data volumes
- **Recovery tests**: Backup and restore procedures

## Troubleshooting

### Common Issues

#### Connection Failures
```bash
# Check service status
docker-compose ps

# View service logs
docker-compose logs postgres redis mongodb

# Test individual connections
ts-node database/test-connections.ts
```

#### Performance Issues
```bash
# Check database metrics
ts-node database/cli.ts health

# View detailed performance
curl http://localhost:3000/health/detailed
```

#### Migration Problems
```bash
# Check migration status
ts-node database/cli.ts migrate:status

# Manual migration rollback
ts-node database/cli.ts migrate:rollback 001
```

### Log Locations
- **PostgreSQL**: Docker logs + `/var/log/postgresql/`
- **Redis**: Docker logs + `/var/log/redis/`
- **MongoDB**: Docker logs + `/var/log/mongodb/`
- **Application**: Service-specific log files

## Future Enhancements

### Planned Improvements
- **Read replicas**: PostgreSQL and MongoDB read scaling
- **Sharding**: MongoDB horizontal scaling for educational content
- **Multi-region**: Geographic distribution for global users
- **Analytics**: Dedicated analytics database (ClickHouse/BigQuery)

### Monitoring Enhancements
- **Grafana dashboards**: Visual monitoring and alerting
- **Prometheus metrics**: Time-series metrics collection
- **Custom alerts**: Business-specific monitoring rules
- **Automated scaling**: Dynamic resource allocation

## Support

For database-related issues:
1. Check this documentation
2. Review [BACKUP_RECOVERY.md](./BACKUP_RECOVERY.md)
3. Run diagnostic tests: `ts-node database/test-connections.ts`
4. Check service logs: `docker-compose logs [service]`
5. Contact the infrastructure team

---

**Last Updated**: 2025-06-27  
**Version**: 1.0.0  
**Maintainer**: Financial Kingdom Builder Infrastructure Team