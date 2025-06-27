# Database Backup and Recovery Procedures

## Overview

This document outlines the backup and recovery procedures for the Financial Kingdom Builder database infrastructure, which consists of:

- **PostgreSQL with TimescaleDB**: User profiles, trading data, achievements
- **Redis**: Sessions, cache, leaderboards  
- **MongoDB**: Educational content, analytics

## Backup Strategies

### PostgreSQL Backup

#### Daily Automated Backups

```bash
# Create daily backup with compression
pg_dump -h postgres -U financial_kingdom -d financial_kingdom | gzip > /backups/postgres/financial_kingdom_$(date +%Y%m%d_%H%M%S).sql.gz

# Backup with custom format (recommended for large databases)
pg_dump -h postgres -U financial_kingdom -d financial_kingdom -Fc -f /backups/postgres/financial_kingdom_$(date +%Y%m%d_%H%M%S).dump
```

#### Point-in-Time Recovery Setup

```bash
# Enable WAL archiving in postgresql.conf
wal_level = replica
archive_mode = on
archive_command = 'cp %p /backups/postgres/wal/%f'
max_wal_senders = 3
```

#### TimescaleDB-specific Backup

```sql
-- Backup time-series data with compression
SELECT * FROM timescaledb_pre_restore();
pg_dump -h postgres -U financial_kingdom -d financial_kingdom -t portfolio_snapshots | gzip > /backups/timescale/portfolio_snapshots_$(date +%Y%m%d).sql.gz
SELECT * FROM timescaledb_post_restore();
```

### Redis Backup

#### Automated RDB Snapshots

```bash
# Configure automatic snapshots in redis.conf
save 900 1      # Save if at least 1 key changed in 900 seconds
save 300 10     # Save if at least 10 keys changed in 300 seconds  
save 60 10000   # Save if at least 10000 keys changed in 60 seconds

# Manual backup
redis-cli --rdb /backups/redis/dump_$(date +%Y%m%d_%H%M%S).rdb

# Backup with compression
redis-cli --rdb - | gzip > /backups/redis/dump_$(date +%Y%m%d_%H%M%S).rdb.gz
```

#### AOF (Append Only File) Backup

```bash
# Enable AOF in redis.conf
appendonly yes
appendfilename "appendonly.aof"
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

# Backup AOF file
cp /data/appendonly.aof /backups/redis/appendonly_$(date +%Y%m%d_%H%M%S).aof
```

### MongoDB Backup

#### Database Dump

```bash
# Full database backup
mongodump --host mongodb:27017 --username financial_kingdom --password financial_kingdom_mongodb_password --authenticationDatabase admin --db financial_kingdom --out /backups/mongodb/$(date +%Y%m%d_%H%M%S)

# Compressed backup
mongodump --host mongodb:27017 --username financial_kingdom --password financial_kingdom_mongodb_password --authenticationDatabase admin --db financial_kingdom --gzip --archive=/backups/mongodb/financial_kingdom_$(date +%Y%m%d_%H%M%S).gz

# Specific collection backup
mongodump --host mongodb:27017 --username financial_kingdom --password financial_kingdom_mongodb_password --authenticationDatabase admin --db financial_kingdom --collection educational_modules --out /backups/mongodb/educational_modules_$(date +%Y%m%d_%H%M%S)
```

#### GridFS Backup (if used for file storage)

```bash
mongofiles --host mongodb:27017 --username financial_kingdom --password financial_kingdom_mongodb_password --authenticationDatabase admin --db financial_kingdom list
# Export all files from GridFS
```

## Automated Backup Scripts

### Daily Backup Script

```bash
#!/bin/bash
# /scripts/daily_backup.sh

set -e

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
RETENTION_DAYS=30

echo "Starting daily backup at $(date)"

# PostgreSQL Backup
echo "Backing up PostgreSQL..."
docker exec financial-kingdom-postgres pg_dump -U financial_kingdom -d financial_kingdom -Fc > $BACKUP_DIR/postgres/financial_kingdom_$BACKUP_DATE.dump

# Redis Backup  
echo "Backing up Redis..."
docker exec financial-kingdom-redis redis-cli --rdb - | gzip > $BACKUP_DIR/redis/dump_$BACKUP_DATE.rdb.gz

# MongoDB Backup
echo "Backing up MongoDB..."
docker exec financial-kingdom-mongodb mongodump --username financial_kingdom --password financial_kingdom_mongodb_password --authenticationDatabase admin --db financial_kingdom --gzip --archive > $BACKUP_DIR/mongodb/financial_kingdom_$BACKUP_DATE.gz

# Cleanup old backups
echo "Cleaning up old backups..."
find $BACKUP_DIR/postgres -name "*.dump" -mtime +$RETENTION_DAYS -delete
find $BACKUP_DIR/redis -name "*.rdb.gz" -mtime +$RETENTION_DAYS -delete  
find $BACKUP_DIR/mongodb -name "*.gz" -mtime +$RETENTION_DAYS -delete

echo "Daily backup completed at $(date)"
```

### Weekly Full Backup Script

```bash
#!/bin/bash
# /scripts/weekly_backup.sh

set -e

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
WEEKLY_BACKUP_DIR="/backups/weekly"

echo "Starting weekly full backup at $(date)"

# Create weekly backup directory
mkdir -p $WEEKLY_BACKUP_DIR

# PostgreSQL with all databases
docker exec financial-kingdom-postgres pg_dumpall -U financial_kingdom > $WEEKLY_BACKUP_DIR/all_databases_$BACKUP_DATE.sql

# Compress the backup
gzip $WEEKLY_BACKUP_DIR/all_databases_$BACKUP_DATE.sql

# Copy Redis data directory
docker exec financial-kingdom-redis tar czf - /data > $WEEKLY_BACKUP_DIR/redis_data_$BACKUP_DATE.tar.gz

# MongoDB with oplog
docker exec financial-kingdom-mongodb mongodump --username financial_kingdom --password financial_kingdom_mongodb_password --authenticationDatabase admin --oplog --gzip --archive > $WEEKLY_BACKUP_DIR/mongodb_with_oplog_$BACKUP_DATE.gz

echo "Weekly backup completed at $(date)"
```

## Recovery Procedures

### PostgreSQL Recovery

#### Full Database Restore

```bash
# Stop application services
docker-compose stop api-gateway trading-service gamification-service education-service social-service notification-service

# Restore from custom format dump
docker exec -i financial-kingdom-postgres pg_restore -U financial_kingdom -d financial_kingdom -c --if-exists /path/to/backup.dump

# Restore from SQL dump
gunzip -c /backups/postgres/financial_kingdom_20231227_120000.sql.gz | docker exec -i financial-kingdom-postgres psql -U financial_kingdom -d financial_kingdom

# Restart services
docker-compose start
```

#### Point-in-Time Recovery

```bash
# Stop PostgreSQL
docker-compose stop postgres

# Restore base backup
tar -xzf /backups/postgres/base_backup.tar.gz -C /var/lib/postgresql/data

# Create recovery.conf
echo "restore_command = 'cp /backups/postgres/wal/%f %p'" > /var/lib/postgresql/data/recovery.conf
echo "recovery_target_time = '2023-12-27 12:00:00'" >> /var/lib/postgresql/data/recovery.conf

# Start PostgreSQL
docker-compose start postgres
```

#### Specific Table Recovery

```bash
# Extract specific table from backup
pg_restore -U financial_kingdom -d financial_kingdom -t users /path/to/backup.dump

# Or restore specific table from SQL dump
gunzip -c backup.sql.gz | grep -A 10000 "CREATE TABLE users" | head -n $(grep -n "CREATE TABLE" backup.sql | head -2 | tail -1 | cut -d: -f1) | docker exec -i financial-kingdom-postgres psql -U financial_kingdom -d financial_kingdom
```

### Redis Recovery

#### RDB Restore

```bash
# Stop Redis
docker-compose stop redis

# Copy backup file to Redis data directory
cp /backups/redis/dump_20231227_120000.rdb /var/lib/redis/dump.rdb

# Set correct permissions
chown redis:redis /var/lib/redis/dump.rdb

# Start Redis
docker-compose start redis
```

#### AOF Restore

```bash
# Stop Redis
docker-compose stop redis

# Copy AOF backup
cp /backups/redis/appendonly_20231227_120000.aof /var/lib/redis/appendonly.aof

# Fix AOF file if corrupted
redis-check-aof --fix /var/lib/redis/appendonly.aof

# Start Redis
docker-compose start redis
```

### MongoDB Recovery

#### Full Database Restore

```bash
# Stop services using MongoDB
docker-compose stop education-service

# Drop existing database (if needed)
docker exec financial-kingdom-mongodb mongo --username financial_kingdom --password financial_kingdom_mongodb_password --authenticationDatabase admin --eval "db.getSiblingDB('financial_kingdom').dropDatabase()"

# Restore from compressed archive
docker exec -i financial-kingdom-mongodb mongorestore --username financial_kingdom --password financial_kingdom_mongodb_password --authenticationDatabase admin --gzip --archive < /backups/mongodb/financial_kingdom_20231227_120000.gz

# Restart services
docker-compose start education-service
```

#### Collection-specific Restore

```bash
# Restore specific collection
docker exec financial-kingdom-mongodb mongorestore --username financial_kingdom --password financial_kingdom_mongodb_password --authenticationDatabase admin --db financial_kingdom --collection educational_modules /backups/mongodb/educational_modules_backup
```

#### Point-in-Time Recovery with Oplog

```bash
# Restore base backup first
docker exec -i financial-kingdom-mongodb mongorestore --username financial_kingdom --password financial_kingdom_mongodb_password --authenticationDatabase admin --gzip --archive < /backups/mongodb/base_backup.gz

# Apply oplog to specific time
docker exec financial-kingdom-mongodb mongorestore --username financial_kingdom --password financial_kingdom_mongodb_password --authenticationDatabase admin --oplogReplay --oplogLimit "1703678400:1" /path/to/oplog/dump
```

## Disaster Recovery Planning

### Recovery Time Objectives (RTO)

- **Critical Data Loss**: < 1 hour
- **Service Restoration**: < 4 hours  
- **Full System Recovery**: < 24 hours

### Recovery Point Objectives (RPO)

- **PostgreSQL**: < 15 minutes (with WAL archiving)
- **Redis**: < 1 hour (session data acceptable loss)
- **MongoDB**: < 1 hour (educational content)

### Recovery Testing

#### Monthly Recovery Tests

```bash
#!/bin/bash
# /scripts/recovery_test.sh

# Create test environment
docker-compose -f docker-compose.test.yml up -d

# Restore latest backups to test environment
./restore_latest_backups.sh test

# Run application tests against restored data
npm run test:integration

# Cleanup test environment
docker-compose -f docker-compose.test.yml down -v
```

### Cross-Region Backup

#### S3 Backup Sync

```bash
# Sync backups to S3
aws s3 sync /backups s3://financial-kingdom-backups/$(date +%Y/%m/%d) --delete

# Sync to secondary region
aws s3 sync s3://financial-kingdom-backups s3://financial-kingdom-backups-west --delete
```

## Monitoring and Alerting

### Backup Monitoring

```bash
# Check backup freshness
find /backups -name "*.dump" -mtime +1 -exec echo "PostgreSQL backup is older than 1 day" \;
find /backups -name "*.rdb.gz" -mtime +1 -exec echo "Redis backup is older than 1 day" \;
find /backups -name "*.gz" -path "*/mongodb/*" -mtime +1 -exec echo "MongoDB backup is older than 1 day" \;
```

### Database Health Monitoring

```javascript
// Health check endpoint
app.get('/health/database', async (req, res) => {
  const health = await databaseManager.healthCheck();
  
  if (health.overall === 'healthy') {
    res.status(200).json(health);
  } else {
    res.status(503).json(health);
  }
});
```

## Security Considerations

### Backup Encryption

```bash
# Encrypt sensitive backups
gpg --cipher-algo AES256 --compress-algo 1 --s2k-mode 3 --s2k-digest-algo SHA512 --s2k-count 65536 --symmetric --output financial_kingdom_encrypted.dump.gpg financial_kingdom.dump

# Decrypt backup
gpg --decrypt financial_kingdom_encrypted.dump.gpg > financial_kingdom.dump
```

### Access Control

- Backup directories: 750 permissions, backup user only
- Database credentials: Environment variables, never in scripts
- S3 buckets: IAM roles with minimal required permissions
- Encryption at rest: Enable for all storage volumes

## Cron Schedule

```bash
# /etc/crontab

# Daily backups at 2 AM
0 2 * * * /scripts/daily_backup.sh >> /var/log/backup.log 2>&1

# Weekly backups on Sunday at 1 AM  
0 1 * * 0 /scripts/weekly_backup.sh >> /var/log/backup.log 2>&1

# Monthly recovery tests on first Saturday at 3 AM
0 3 1-7 * 6 /scripts/recovery_test.sh >> /var/log/recovery_test.log 2>&1

# Backup cleanup daily at 4 AM
0 4 * * * find /backups -name "*.dump" -mtime +30 -delete
```

## Emergency Contacts

- **Primary DBA**: [Contact Information]
- **Infrastructure Team**: [Contact Information]  
- **Cloud Provider Support**: [Contact Information]
- **Escalation Manager**: [Contact Information]

## Documentation Updates

This document should be reviewed and updated:
- After any infrastructure changes
- Following disaster recovery tests
- When backup procedures are modified
- Quarterly as part of operational review