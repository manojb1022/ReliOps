# Database Operations Guide

## Overview

This SRE Portfolio project now includes a complete database stack with PostgreSQL, pgAdmin for administration, full observability, centralized logging, and automated backups.

## Architecture

```
Application (Flask)
    ↓
SQLAlchemy ORM
    ↓
Connection Pool (10-30 connections)
    ↓
PostgreSQL 15
    ↓
├─ Persistent Volume (5GB)
├─ Prometheus Exporter (Metrics)
├─ pgAdmin (Admin UI)
└─ Automated Backups (Daily)
```

## Database Schema

### Tables

#### `request_logs`
Stores HTTP request logs for analysis and debugging.

```sql
CREATE TABLE request_logs (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL,
    method VARCHAR(10) NOT NULL,
    path VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    status_code INTEGER,
    response_time_ms FLOAT,
    error_message TEXT
);

CREATE INDEX idx_timestamp_status ON request_logs(timestamp, status_code);
CREATE INDEX idx_method_path ON request_logs(method, path);
```

#### `api_stats`
Aggregated API usage statistics.

```sql
CREATE TABLE api_stats (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL,
    endpoint VARCHAR(255) NOT NULL,
    total_requests INTEGER DEFAULT 0,
    successful_requests INTEGER DEFAULT 0,
    failed_requests INTEGER DEFAULT 0,
    avg_response_time_ms FLOAT DEFAULT 0.0,
    max_response_time_ms FLOAT DEFAULT 0.0,
    min_response_time_ms FLOAT DEFAULT 0.0
);

CREATE INDEX idx_endpoint_timestamp ON api_stats(endpoint, timestamp);
```

#### `health_checks`
Periodic health check results for trend analysis.

```sql
CREATE TABLE health_checks (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL,
    service_name VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    uptime_seconds FLOAT,
    memory_usage_bytes BIGINT,
    cpu_usage_percent FLOAT,
    details TEXT
);

CREATE INDEX idx_service_timestamp ON health_checks(service_name, timestamp);
```

## API Endpoints

### GET `/api/requests`
Get recent request logs from the database.

**Parameters:**
- `limit` (int, default=100): Number of records to return
- `offset` (int, default=0): Offset for pagination

**Example:**
```bash
curl http://localhost:8080/api/requests?limit=10
```

**Response:**
```json
{
  "count": 10,
  "limit": 10,
  "offset": 0,
  "requests": [
    {
      "id": 1,
      "timestamp": "2025-10-11T12:00:00",
      "method": "GET",
      "path": "/health",
      "status_code": 200,
      "response_time_ms": 5.2
    }
  ]
}
```

### GET `/api/stats`
Get API usage statistics.

**Parameters:**
- `hours` (int, default=24): Time window in hours

**Example:**
```bash
curl http://localhost:8080/api/stats?hours=24
```

**Response:**
```json
{
  "period_hours": 24,
  "total_requests": 1542,
  "successful_requests": 1498,
  "success_rate": 97.15,
  "avg_response_time_ms": 12.5,
  "top_endpoints": [
    {"path": "/health", "count": 856},
    {"path": "/metrics", "count": 423}
  ],
  "by_status_code": [
    {"status_code": 200, "count": 1498},
    {"status_code": 404, "count": 32}
  ]
}
```

### GET `/api/database/health`
Get detailed database health information.

**Example:**
```bash
curl http://localhost:8080/api/database/health
```

**Response:**
```json
{
  "status": "healthy",
  "version": "PostgreSQL 15.3",
  "pool": {
    "size": 10,
    "checked_in": 8,
    "checked_out": 2,
    "overflow": 0,
    "total": 10
  }
}
```

## Accessing pgAdmin

pgAdmin is a web-based administration tool for PostgreSQL.

**Access URL:** `http://<minikube-ip>:30100`

**Credentials:**
- Email: `admin@reliops.com`
- Password: `admin123`

**Pre-configured Server:**
- Name: ReliOps PostgreSQL
- Host: `postgres-postgresql.default.svc.cluster.local`
- Port: 5432
- Database: `reliops_db`
- Username: `reliops`
- Password: `reliops123`

### Common pgAdmin Tasks

#### 1. View Table Data
1. Expand Servers → ReliOps PostgreSQL → Databases → reliops_db
2. Expand Schemas → public → Tables
3. Right-click on a table → View/Edit Data → All Rows

#### 2. Run Custom Queries
1. Click Tools → Query Tool
2. Write your SQL query
3. Click Execute (F5)

**Example Queries:**
```sql
-- Get request count by status code
SELECT status_code, COUNT(*) as count
FROM request_logs
GROUP BY status_code
ORDER BY count DESC;

-- Get average response time by endpoint
SELECT path, AVG(response_time_ms) as avg_time
FROM request_logs
WHERE timestamp > NOW() - INTERVAL '1 hour'
GROUP BY path
ORDER BY avg_time DESC;

-- Get error rate over time
SELECT 
    DATE_TRUNC('minute', timestamp) as minute,
    COUNT(*) FILTER (WHERE status_code >= 400) * 100.0 / COUNT(*) as error_rate
FROM request_logs
WHERE timestamp > NOW() - INTERVAL '1 hour'
GROUP BY minute
ORDER BY minute;
```

## Database Backups

### Automated Backups

Backups run automatically every day at 2 AM via a Kubernetes CronJob.

**View backup status:**
```bash
kubectl get cronjobs -n default
kubectl get jobs -n default | grep postgres-backup
```

**View backup logs:**
```bash
kubectl logs -n default -l app=postgres-backup --tail=100
```

### Manual Backup

```bash
./scripts/backup-db.sh
```

This creates a backup file in `/tmp/backups/` with format:
`reliops_db_YYYYMMDD_HHMMSS.sql`

### Restore from Backup

```bash
./scripts/restore-db.sh /tmp/backups/reliops_db_20251011_020000.sql
```

**⚠️ WARNING:** This will replace ALL current data!

## Database Monitoring

### Grafana Dashboard

Access the PostgreSQL dashboard in Grafana:
1. Open Grafana: `http://<minikube-ip>:30000`
2. Go to Dashboards → PostgreSQL - SRE Portfolio Dashboard

**Metrics shown:**
- Active database connections
- Transaction rate (commits/rollbacks per second)
- Cache hit ratio (should be >95%)
- Tuple operations (inserts/updates/deletes)
- Connection pool status
- Database operation rates

### Prometheus Metrics

Database metrics are exposed to Prometheus:

```
# Connection pool metrics
db_connection_pool_size{state="checked_in"}
db_connection_pool_size{state="checked_out"}
db_connection_pool_size{state="total"}

# Operation metrics
db_requests_total{operation="insert", status="success"}
db_requests_total{operation="select", status="success"}
db_requests_total{operation="insert", status="error"}

# PostgreSQL metrics (from postgres-exporter)
pg_stat_database_numbackends{datname="reliops_db"}
pg_stat_database_xact_commit{datname="reliops_db"}
pg_stat_database_xact_rollback{datname="reliops_db"}
pg_stat_database_blks_hit{datname="reliops_db"}
pg_stat_database_blks_read{datname="reliops_db"}
```

### Alert Rules

The following alerts are configured:

1. **High Database Error Rate**
   - Triggers when DB operation error rate > 5%
   - Duration: 2 minutes

2. **Low Cache Hit Ratio**
   - Triggers when cache hit ratio < 90%
   - Duration: 5 minutes

3. **Connection Pool Exhaustion**
   - Triggers when checked-out connections > 90% of pool size
   - Duration: 2 minutes

4. **Database Unavailable**
   - Triggers when database health check fails
   - Duration: 1 minute

## Centralized Logging with Loki

### Accessing Logs in Grafana

1. Open Grafana: `http://<minikube-ip>:30000`
2. Go to Explore
3. Select "Loki" as the data source
4. Use LogQL to query logs

### LogQL Query Examples

**View application logs:**
```logql
{namespace="hello-api"}
```

**View database logs:**
```logql
{namespace="default", app="postgresql"}
```

**Filter by log level:**
```logql
{namespace="hello-api"} |= "ERROR"
```

**Filter by specific endpoint:**
```logql
{namespace="hello-api"} | json | path="/api/stats"
```

**Count errors over time:**
```logql
sum(rate({namespace="hello-api"} |= "ERROR" [5m]))
```

## Troubleshooting

### Database Connection Issues

**Check if PostgreSQL is running:**
```bash
kubectl get pods -n default -l app.kubernetes.io/name=postgresql
kubectl logs -n default -l app.kubernetes.io/name=postgresql
```

**Test database connectivity:**
```bash
kubectl exec -it -n default postgres-postgresql-0 -- psql -U reliops -d reliops_db -c "SELECT version();"
```

### High Database Load

**Check active queries:**
```sql
SELECT pid, now() - query_start as duration, state, query
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY duration DESC;
```

**Kill a specific query:**
```sql
SELECT pg_terminate_backend(pid);
```

### Slow Queries

**Enable slow query logging:** (already enabled, logs queries >1000ms)

**View slow queries in logs:**
```bash
kubectl logs -n default -l app.kubernetes.io/name=postgresql | grep "duration:"
```

### Connection Pool Issues

**Check pool status:**
```bash
curl http://localhost:8080/api/database/health
```

**View pool metrics in Grafana:**
- Open PostgreSQL dashboard
- Check "Connection Pool Status" panel

## Performance Tuning

### Connection Pool Sizing

Current configuration: 10 connections, max overflow 20

**Adjust in `app/db_utils.py`:**
```python
engine = create_engine(
    DATABASE_URL,
    pool_size=10,        # Base pool size
    max_overflow=20,     # Additional connections allowed
    pool_recycle=3600    # Recycle after 1 hour
)
```

### Database Tuning

Key PostgreSQL settings (configured in `helm/postgres/values.yaml`):

```yaml
max_connections: 100
shared_buffers: 128MB
effective_cache_size: 256MB
work_mem: 1310kB
```

**Monitor and adjust based on:**
- Cache hit ratio (aim for >95%)
- Connection usage (should not hit max_connections)
- Query performance (check slow query logs)

## Best Practices

1. **Always use connection pooling** - Already implemented with SQLAlchemy
2. **Close connections properly** - Using context managers (`with get_db_session()`)
3. **Use transactions** - Wrapped in session context
4. **Monitor cache hit ratio** - Should be >95%
5. **Regular backups** - Automated daily at 2 AM
6. **Test restores** - Periodically verify backup integrity
7. **Index frequently queried columns** - Already indexed on timestamp, status_code
8. **Vacuum regularly** - PostgreSQL auto-vacuum is enabled
9. **Monitor connection pool** - Check Grafana dashboard
10. **Log slow queries** - Enabled for queries >1000ms

## Interview Talking Points

When demonstrating this to an interviewer:

1. **"I implemented full database persistence with PostgreSQL"**
   - Show the database schema and relationships
   - Explain why PostgreSQL over other options

2. **"All HTTP requests are logged to the database for analysis"**
   - Show the `/api/requests` endpoint
   - Query recent logs in pgAdmin

3. **"I can show you database metrics in real-time"**
   - Open Grafana PostgreSQL dashboard
   - Explain cache hit ratio, connection pool metrics

4. **"The database has automated daily backups with point-in-time recovery"**
   - Show the CronJob configuration
   - Demonstrate backup and restore scripts

5. **"I use pgAdmin for professional database administration"**
   - Show pgAdmin interface
   - Run a custom SQL query

6. **"All logs are centralized in Grafana Loki"**
   - Show log querying with LogQL
   - Filter by application, error level, etc.

7. **"Connection pooling prevents database overload"**
   - Explain SQLAlchemy connection pool
   - Show pool metrics in Grafana

8. **"I monitor database health with Prometheus alerts"**
   - Show alert rules for connection exhaustion, cache hit ratio
   - Explain how alerts integrate with incident response

This demonstrates production-grade database management, observability, and SRE best practices!
