# Centralized Logging Guide with Grafana Loki

## Overview

This project uses Grafana Loki for centralized log aggregation, making it easy to search, filter, and analyze logs from all components in the system.

## Architecture

```
Application Pods → Promtail (DaemonSet) → Loki → Grafana
PostgreSQL Logs → Promtail (DaemonSet) → Loki → Grafana
K8s System Logs → Promtail (DaemonSet) → Loki → Grafana
```

## Components

### Grafana Loki
- **Purpose**: Log aggregation system inspired by Prometheus
- **Storage**: Filesystem-based (can be upgraded to S3/GCS)
- **Retention**: 7 days (168 hours)
- **Port**: 3100

### Promtail
- **Purpose**: Log shipper that pushes logs to Loki
- **Deployment**: DaemonSet (runs on every node)
- **Sources**: 
  - Container logs (`/var/log/pods`)
  - Docker logs (`/var/lib/docker/containers`)
  - System logs (`/var/log`)

## Accessing Logs in Grafana

### Step 1: Open Grafana
```bash
# Get minikube IP
minikube ip -p sre-portfolio

# Open in browser
open http://<minikube-ip>:30000
```

**Login:**
- Username: `admin`
- Password: Get from kubectl:
  ```bash
  kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode
  ```

### Step 2: Navigate to Explore
1. Click on the "Explore" icon (compass) in the left sidebar
2. Select "Loki" from the data source dropdown at the top

### Step 3: Query Logs
Use LogQL (Loki Query Language) to filter and search logs.

## LogQL Basics

### Log Stream Selectors

**View logs from a specific namespace:**
```logql
{namespace="hello-api"}
```

**View logs from a specific pod:**
```logql
{namespace="hello-api", pod="hello-api-blue-xxx"}
```

**View logs from a specific container:**
```logql
{namespace="hello-api", container="hello-api"}
```

**View database logs:**
```logql
{namespace="default", app="postgresql"}
```

### Log Line Filtering

**Filter logs containing "ERROR":**
```logql
{namespace="hello-api"} |= "ERROR"
```

**Filter logs NOT containing "health":**
```logql
{namespace="hello-api"} != "health"
```

**Use regex for complex patterns:**
```logql
{namespace="hello-api"} |~ "status_code\":5.."
```

**Chain filters:**
```logql
{namespace="hello-api"} |= "ERROR" |= "database"
```

### JSON Parsing

**Parse JSON logs:**
```logql
{namespace="hello-api"} | json
```

**Filter by JSON field:**
```logql
{namespace="hello-api"} | json | level="ERROR"
```

**Filter by multiple JSON fields:**
```logql
{namespace="hello-api"} | json | level="ERROR" | method="POST"
```

### Log Aggregation

**Count error logs:**
```logql
count_over_time({namespace="hello-api"} |= "ERROR" [5m])
```

**Rate of error logs per second:**
```logql
rate({namespace="hello-api"} |= "ERROR" [5m])
```

**Sum error logs over time:**
```logql
sum(rate({namespace="hello-api"} |= "ERROR" [5m]))
```

**Group by status code:**
```logql
sum by (status_code) (rate({namespace="hello-api"} | json [5m]))
```

## Common Use Cases

### 1. Debugging Application Errors

**Find all errors in the last hour:**
```logql
{namespace="hello-api"} |= "ERROR" 
```

**Find errors with stack traces:**
```logql
{namespace="hello-api"} |= "ERROR" |= "Traceback"
```

**Find specific error message:**
```logql
{namespace="hello-api"} |= "Database connection failed"
```

### 2. Monitoring API Requests

**View all API requests:**
```logql
{namespace="hello-api"} | json | path!=""
```

**Filter by endpoint:**
```logql
{namespace="hello-api"} | json | path="/api/stats"
```

**Find slow requests (>1000ms):**
```logql
{namespace="hello-api"} | json | duration_ms > 1000
```

**Find failed requests (status 5xx):**
```logql
{namespace="hello-api"} | json | status_code >= 500
```

### 3. Database Query Analysis

**View all database logs:**
```logql
{namespace="default", app="postgresql"}
```

**Find slow queries:**
```logql
{namespace="default", app="postgresql"} |= "duration:" |~ "duration: [0-9]{4,}"
```

**Find connection errors:**
```logql
{namespace="default", app="postgresql"} |= "connection" |= "error"
```

### 4. Security Monitoring

**Find authentication failures:**
```logql
{namespace="hello-api"} |= "authentication" |= "failed"
```

**Find suspicious activity:**
```logql
{namespace="hello-api"} | json | status_code=401 or status_code=403
```

**Monitor admin actions:**
```logql
{namespace="monitoring"} |= "admin" |= "action"
```

### 5. Performance Analysis

**Request rate by endpoint:**
```logql
sum by (path) (rate({namespace="hello-api"} | json [5m]))
```

**Average response time:**
```logql
avg(rate({namespace="hello-api"} | json | duration_ms > 0 [5m]))
```

**95th percentile response time:**
```logql
quantile_over_time(0.95, {namespace="hello-api"} | json | duration_ms [5m])
```

## Log Labels

Our application adds these labels to logs:

- `namespace`: Kubernetes namespace
- `pod`: Pod name  
- `container`: Container name
- `app`: Application name
- `timestamp`: Log timestamp
- `level`: Log level (INFO, WARNING, ERROR, etc.)
- `message`: Log message
- `method`: HTTP method (GET, POST, etc.)
- `path`: Request path
- `status_code`: HTTP status code
- `duration_ms`: Request duration in milliseconds
- `ip`: Client IP address
- `user_agent`: Client user agent

## Creating Log Dashboards

### Create a Dashboard in Grafana

1. Click "+" → "Create Dashboard"
2. Click "Add new panel"
3. Select "Loki" as data source
4. Enter your LogQL query
5. Choose visualization type
6. Click "Apply"

### Example Panels

**Error Rate Panel:**
```logql
sum(rate({namespace="hello-api"} |= "ERROR" [5m]))
```
Visualization: Graph (Time series)

**Top Error Messages:**
```logql
topk(10, sum by (message) (count_over_time({namespace="hello-api"} |= "ERROR" [1h])))
```
Visualization: Table

**Request Volume by Status Code:**
```logql
sum by (status_code) (rate({namespace="hello-api"} | json [5m]))
```
Visualization: Bar chart

## Structured Logging

The application uses JSON-formatted logs for better parsing and filtering.

**Example log entry:**
```json
{
  "timestamp": "2025-10-11T12:00:00.123456",
  "level": "INFO",
  "name": "__main__",
  "message": "Request completed",
  "method": "GET",
  "path": "/api/stats",
  "status_code": 200,
  "duration_ms": 12.5,
  "ip": "10.244.0.1",
  "user_agent": "curl/7.64.1"
}
```

**Advantages:**
- Easy to parse and filter
- Consistent structure
- Machine-readable
- Supports complex queries

## Log Retention

**Current Configuration:**
- Retention period: 7 days (168 hours)
- Ingestion rate limit: 10MB/s
- Burst limit: 20MB

**Adjust retention:**
Edit `monitoring/loki/loki-values.yaml`:
```yaml
limits_config:
  retention_period: 168h  # Change this value
```

## Best Practices

### 1. Use Structured Logging
Always log in JSON format with consistent fields.

**Good:**
```python
logger.info("Request completed", extra={
    "method": "GET",
    "path": "/api/stats",
    "status_code": 200,
    "duration_ms": 12.5
})
```

**Bad:**
```python
logger.info(f"GET /api/stats completed with status 200 in 12.5ms")
```

### 2. Add Context to Logs
Include relevant context like user IDs, request IDs, correlation IDs.

```python
logger.info("Database query", extra={
    "query_type": "SELECT",
    "table": "request_logs",
    "duration_ms": 5.2,
    "rows_returned": 100,
    "correlation_id": request_id
})
```

### 3. Use Appropriate Log Levels

- **DEBUG**: Detailed diagnostic information
- **INFO**: General informational messages
- **WARNING**: Warning messages (something unexpected but not an error)
- **ERROR**: Error messages (something failed)
- **CRITICAL**: Critical messages (system is unusable)

### 4. Don't Log Sensitive Data

**Never log:**
- Passwords
- API keys
- Credit card numbers
- Personal identification numbers (PINs)
- Session tokens

**Safe to log:**
- User IDs (not usernames/emails)
- Request IDs
- Timestamps
- Status codes
- Response times

### 5. Use Log Sampling for High-Volume Logs

For very high-volume logs, consider sampling:
```python
if random.random() < 0.1:  # 10% sampling
    logger.debug("High volume debug log")
```

## Troubleshooting

### Logs Not Appearing in Loki

**Check Promtail is running:**
```bash
kubectl get pods -n monitoring -l app.kubernetes.io/name=promtail
kubectl logs -n monitoring -l app.kubernetes.io/name=promtail
```

**Check Loki is running:**
```bash
kubectl get pods -n monitoring -l app.kubernetes.io/name=loki
kubectl logs -n monitoring -l app.kubernetes.io/name=loki
```

**Verify Promtail can reach Loki:**
```bash
kubectl exec -it -n monitoring <promtail-pod> -- wget -O- http://loki:3100/ready
```

### Slow Log Queries

**Optimize queries:**
- Use specific label selectors (namespace, pod, container)
- Limit time range (use `[5m]` instead of `[1h]` if possible)
- Use filters early in the query
- Avoid expensive operations on large log volumes

**Good:**
```logql
{namespace="hello-api", pod="hello-api-blue-xxx"} |= "ERROR" [5m]
```

**Slow:**
```logql
{namespace=~".*"} [1h] |= "ERROR"
```

### Loki Out of Memory

**Increase resource limits:**
Edit `monitoring/loki/loki-values.yaml`:
```yaml
resources:
  limits:
    memory: 1Gi  # Increase this
```

**Reduce retention:**
```yaml
limits_config:
  retention_period: 72h  # Reduce from 168h
```

## Interview Talking Points

When demonstrating logging to an interviewer:

1. **"I implemented centralized logging with Grafana Loki"**
   - Show log aggregation from multiple sources
   - Explain why Loki over ELK stack (simpler, more cost-effective)

2. **"All application logs are structured in JSON format"**
   - Show example log entry
   - Demonstrate JSON field filtering

3. **"I can search and filter logs in real-time"**
   - Show LogQL queries
   - Filter by endpoint, status code, error messages

4. **"Logs are retained for 7 days with automatic rotation"**
   - Explain retention policy
   - Show storage usage

5. **"Logs are correlated with metrics for complete observability"**
   - Show same timestamp in Loki logs and Grafana metrics
   - Demonstrate jumping from metric spike to relevant logs

6. **"I can create custom dashboards from log data"**
   - Show pre-built log dashboard
   - Explain common log visualization patterns

7. **"Log ingestion is rate-limited to prevent overload"**
   - Explain rate limiting configuration
   - Discuss log sampling strategies

8. **"Security: No sensitive data is logged"**
   - Show log sanitization
   - Explain compliance considerations (GDPR, PCI-DSS)

This demonstrates production-grade logging practices essential for SRE roles!
