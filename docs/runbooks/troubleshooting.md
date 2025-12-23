# Troubleshooting Guide

## Overview
Comprehensive troubleshooting guide for the Social Live platform covering common issues, diagnostic procedures, and resolution steps.

## Quick Diagnostic Commands

### System Health Check
```bash
#!/bin/bash
# Quick health check script
echo "=== Social Live Platform Health Check ==="

# 1. Kubernetes cluster status
echo "Cluster Status:"
kubectl get nodes
kubectl get pods -n social-live-prod

# 2. Service endpoints
echo "Service Health:"
curl -f https://api.yourdomain.com/health || echo "❌ Backend API down"
curl -f https://app.yourdomain.com/ || echo "❌ Frontend down"

# 3. Database connectivity
echo "Database Status:"
psql $DATABASE_URL -c "SELECT 1;" || echo "❌ Database connection failed"

# 4. Redis connectivity
echo "Redis Status:"
redis-cli ping || echo "❌ Redis connection failed"

# 5. Resource usage
echo "Resource Usage:"
kubectl top nodes
kubectl top pods -n social-live-prod
```

## Common Issues & Solutions

### 1. Application Won't Start

#### Symptoms
- Pods in `CrashLoopBackOff` state
- Health checks failing
- Application logs show startup errors

#### Diagnostic Steps
```bash
# Check pod status
kubectl get pods -n social-live-prod

# Describe failing pod
kubectl describe pod <pod-name> -n social-live-prod

# Check logs
kubectl logs <pod-name> -n social-live-prod --previous
kubectl logs <pod-name> -n social-live-prod --tail=100
```

#### Common Causes & Solutions

**Database Connection Issues**
```bash
# Check database connectivity
kubectl exec -it <pod-name> -n social-live-prod -- psql $DATABASE_URL -c "SELECT 1;"

# Verify environment variables
kubectl exec -it <pod-name> -n social-live-prod -- env | grep DATABASE

# Solution: Update database URL or check network policies
kubectl edit secret app-secrets -n social-live-prod
```

**Missing Environment Variables**
```bash
# Check secret exists
kubectl get secrets -n social-live-prod

# Verify secret content
kubectl get secret app-secrets -n social-live-prod -o yaml

# Solution: Create or update secrets
kubectl create secret generic app-secrets \
  --from-env-file=.env.production \
  -n social-live-prod
```

**Resource Limits**
```bash
# Check resource usage
kubectl describe pod <pod-name> -n social-live-prod | grep -A 5 "Limits\|Requests"

# Solution: Increase resource limits
kubectl patch deployment backend -n social-live-prod -p '
{
  "spec": {
    "template": {
      "spec": {
        "containers": [{
          "name": "backend",
          "resources": {
            "limits": {"memory": "2Gi", "cpu": "1000m"},
            "requests": {"memory": "1Gi", "cpu": "500m"}
          }
        }]
      }
    }
  }
}'
```

### 2. High Response Times

#### Symptoms
- API responses > 1 second
- User complaints about slow loading
- High 95th percentile response times in monitoring

#### Diagnostic Steps
```bash
# Check application metrics
curl https://api.yourdomain.com/metrics | grep http_request_duration

# Monitor database performance
psql $DATABASE_URL -c "
SELECT query, mean_exec_time, calls, total_exec_time
FROM pg_stat_statements
WHERE mean_exec_time > 100
ORDER BY mean_exec_time DESC
LIMIT 10;"

# Check Redis performance
redis-cli --latency-history -i 1
```

#### Solutions

**Database Optimization**
```sql
-- Find slow queries
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
WHERE mean_exec_time > 100
ORDER BY mean_exec_time DESC;

-- Check missing indexes
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM pg_stats
WHERE schemaname = 'public' AND n_distinct > 100;

-- Add indexes for slow queries
CREATE INDEX CONCURRENTLY idx_posts_user_created 
ON posts(user_id, created_at DESC);
```

**Application Scaling**
```bash
# Scale up backend pods
kubectl scale deployment backend --replicas=10 -n social-live-prod

# Check HPA status
kubectl get hpa -n social-live-prod

# Adjust HPA targets
kubectl patch hpa backend-hpa -n social-live-prod -p '
{
  "spec": {
    "metrics": [{
      "type": "Resource",
      "resource": {
        "name": "cpu",
        "target": {"type": "Utilization", "averageUtilization": 50}
      }
    }]
  }
}'
```

**Cache Optimization**
```bash
# Check Redis memory usage
redis-cli info memory

# Clear cache if needed
redis-cli FLUSHDB

# Optimize cache configuration
redis-cli CONFIG SET maxmemory-policy allkeys-lru
redis-cli CONFIG SET maxmemory 1gb
```

### 3. Database Connection Issues

#### Symptoms
- "Connection timeout" errors
- "Too many connections" errors
- Database queries failing intermittently

#### Diagnostic Steps
```bash
# Check active connections
psql $DATABASE_URL -c "
SELECT count(*), state, usename
FROM pg_stat_activity
GROUP BY state, usename
ORDER BY count DESC;"

# Check connection pool status
kubectl logs -l app=backend -n social-live-prod | grep "connection pool"

# Monitor connection usage
watch -n 5 'psql $DATABASE_URL -c "SELECT count(*) FROM pg_stat_activity;"'
```

#### Solutions

**Connection Pool Tuning**
```typescript
// Update Prisma connection pool
const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
  // Increase connection pool size
  __internal: {
    engine: {
      connectionLimit: 50,
    },
  },
});
```

**Database Configuration**
```sql
-- Increase max connections
ALTER SYSTEM SET max_connections = 200;
SELECT pg_reload_conf();

-- Optimize connection settings
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
SELECT pg_reload_conf();
```

**Application-level Fixes**
```bash
# Restart pods to reset connections
kubectl rollout restart deployment/backend -n social-live-prod

# Check for connection leaks in code
kubectl logs -l app=backend -n social-live-prod | grep -i "connection\|pool"
```

### 4. Memory Issues

#### Symptoms
- Pods being killed (OOMKilled)
- High memory usage alerts
- Application becoming unresponsive

#### Diagnostic Steps
```bash
# Check memory usage
kubectl top pods -n social-live-prod --sort-by=memory

# Check pod events
kubectl get events -n social-live-prod --sort-by='.lastTimestamp'

# Monitor memory over time
kubectl exec -it <pod-name> -n social-live-prod -- cat /proc/meminfo
```

#### Solutions

**Increase Memory Limits**
```bash
# Update deployment with higher memory limits
kubectl patch deployment backend -n social-live-prod -p '
{
  "spec": {
    "template": {
      "spec": {
        "containers": [{
          "name": "backend",
          "resources": {
            "limits": {"memory": "2Gi"},
            "requests": {"memory": "1Gi"}
          }
        }]
      }
    }
  }
}'
```

**Memory Leak Detection**
```typescript
// Add memory monitoring middleware
export class MemoryMonitorMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const memUsage = process.memoryUsage();
    
    if (memUsage.heapUsed > 500 * 1024 * 1024) { // 500MB
      console.warn('High memory usage:', {
        heapUsed: Math.round(memUsage.heapUsed / 1024 / 1024) + 'MB',
        heapTotal: Math.round(memUsage.heapTotal / 1024 / 1024) + 'MB',
        external: Math.round(memUsage.external / 1024 / 1024) + 'MB'
      });
    }
    
    next();
  }
}
```

**Garbage Collection Tuning**
```bash
# Add Node.js GC flags to deployment
kubectl patch deployment backend -n social-live-prod -p '
{
  "spec": {
    "template": {
      "spec": {
        "containers": [{
          "name": "backend",
          "env": [{
            "name": "NODE_OPTIONS",
            "value": "--max-old-space-size=1024 --gc-interval=100"
          }]
        }]
      }
    }
  }
}'
```

### 5. SSL/TLS Certificate Issues

#### Symptoms
- HTTPS connections failing
- Certificate expired warnings
- Browser security errors

#### Diagnostic Steps
```bash
# Check certificate status
kubectl get certificates -n social-live-prod

# Describe certificate
kubectl describe certificate social-live-tls -n social-live-prod

# Check cert-manager logs
kubectl logs -n cert-manager -l app=cert-manager

# Test SSL connection
openssl s_client -connect api.yourdomain.com:443 -servername api.yourdomain.com
```

#### Solutions

**Certificate Renewal**
```bash
# Force certificate renewal
kubectl delete certificate social-live-tls -n social-live-prod
kubectl apply -f k8s/overlays/production/certificate.yaml

# Check renewal status
kubectl get certificaterequests -n social-live-prod
```

**DNS Issues**
```bash
# Verify DNS resolution
nslookup api.yourdomain.com
dig api.yourdomain.com

# Check ingress configuration
kubectl get ingress -n social-live-prod -o yaml
```

### 6. Load Balancer Issues

#### Symptoms
- Intermittent connection failures
- Uneven load distribution
- Some pods not receiving traffic

#### Diagnostic Steps
```bash
# Check service endpoints
kubectl get endpoints -n social-live-prod

# Check ingress status
kubectl get ingress -n social-live-prod

# Test load balancing
for i in {1..10}; do
  curl -s https://api.yourdomain.com/health | jq .hostname
done
```

#### Solutions

**Service Configuration**
```bash
# Check service selector
kubectl get service backend-service -n social-live-prod -o yaml

# Verify pod labels
kubectl get pods -n social-live-prod --show-labels

# Update service if needed
kubectl patch service backend-service -n social-live-prod -p '
{
  "spec": {
    "selector": {
      "app": "backend"
    }
  }
}'
```

**Ingress Controller Issues**
```bash
# Check ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx

# Restart ingress controller
kubectl rollout restart deployment/ingress-nginx-controller -n ingress-nginx
```

### 7. Redis Connection Issues

#### Symptoms
- Cache misses increasing
- Redis connection timeouts
- Session management failures

#### Diagnostic Steps
```bash
# Test Redis connectivity
redis-cli ping

# Check Redis info
redis-cli info server
redis-cli info clients

# Monitor Redis commands
redis-cli monitor
```

#### Solutions

**Connection Pool Issues**
```typescript
// Update Redis configuration
const redis = new Redis({
  host: process.env.REDIS_HOST,
  port: parseInt(process.env.REDIS_PORT),
  maxRetriesPerRequest: 3,
  retryDelayOnFailover: 100,
  lazyConnect: true,
  keepAlive: 30000,
});
```

**Redis Memory Issues**
```bash
# Check Redis memory usage
redis-cli info memory

# Clear cache if needed
redis-cli FLUSHDB

# Optimize memory settings
redis-cli CONFIG SET maxmemory 512mb
redis-cli CONFIG SET maxmemory-policy allkeys-lru
```

## Performance Troubleshooting

### Slow API Responses

#### Investigation Checklist
1. **Application Performance**
   ```bash
   # Check response times
   curl -w "@curl-format.txt" -o /dev/null -s https://api.yourdomain.com/posts
   
   # Monitor application metrics
   kubectl port-forward svc/backend-service 3000:80 -n social-live-prod
   curl http://localhost:3000/metrics | grep http_request_duration
   ```

2. **Database Performance**
   ```sql
   -- Check slow queries
   SELECT query, mean_exec_time, calls
   FROM pg_stat_statements
   WHERE mean_exec_time > 100
   ORDER BY mean_exec_time DESC
   LIMIT 10;
   
   -- Check lock waits
   SELECT * FROM pg_stat_activity WHERE wait_event IS NOT NULL;
   ```

3. **Network Issues**
   ```bash
   # Test network latency
   kubectl exec -it <pod-name> -n social-live-prod -- ping google.com
   
   # Check DNS resolution
   kubectl exec -it <pod-name> -n social-live-prod -- nslookup api.yourdomain.com
   ```

### High CPU Usage

#### Investigation Steps
```bash
# Check CPU usage by pod
kubectl top pods -n social-live-prod --sort-by=cpu

# Profile application
kubectl exec -it <pod-name> -n social-live-prod -- node --prof /app/dist/main.js

# Check for CPU-intensive queries
psql $DATABASE_URL -c "
SELECT query, total_exec_time, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;"
```

## Monitoring & Alerting Issues

### Missing Metrics

#### Diagnostic Steps
```bash
# Check Prometheus targets
kubectl port-forward svc/prometheus-server 9090:80 -n monitoring
# Visit http://localhost:9090/targets

# Check application metrics endpoint
curl https://api.yourdomain.com/metrics

# Verify service monitor
kubectl get servicemonitor -n social-live-prod
```

#### Solutions
```yaml
# Create service monitor
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: backend-metrics
  namespace: social-live-prod
spec:
  selector:
    matchLabels:
      app: backend
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
```

### Alert Fatigue

#### Common Issues
1. **Too many alerts**: Adjust thresholds
2. **False positives**: Improve alert conditions
3. **Missing context**: Add better descriptions

#### Solutions
```yaml
# Improved alert rule
- alert: HighErrorRate
  expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
  for: 10m  # Increased duration to reduce noise
  labels:
    severity: warning
  annotations:
    summary: "High error rate on {{ $labels.instance }}"
    description: "Error rate is {{ $value | humanizePercentage }} for the last 10 minutes"
    runbook_url: "https://docs.yourdomain.com/runbooks/high-error-rate"
```

## Emergency Procedures

### Complete System Outage

#### Immediate Actions (0-5 minutes)
1. **Acknowledge incident**
   ```bash
   # Post in incident channel
   echo "🚨 INCIDENT: Complete system outage detected at $(date)"
   ```

2. **Quick health check**
   ```bash
   kubectl get nodes
   kubectl get pods -n social-live-prod
   curl -f https://api.yourdomain.com/health
   ```

3. **Check external dependencies**
   ```bash
   # Database
   psql $DATABASE_URL -c "SELECT 1;"
   
   # Redis
   redis-cli ping
   
   # External APIs
   curl -f https://external-api.com/health
   ```

#### Investigation Phase (5-15 minutes)
1. **Review recent changes**
   ```bash
   kubectl rollout history deployment/backend -n social-live-prod
   git log --oneline --since="2 hours ago"
   ```

2. **Check resource usage**
   ```bash
   kubectl top nodes
   kubectl describe nodes
   ```

3. **Review logs**
   ```bash
   kubectl logs -l app=backend -n social-live-prod --since=1h
   ```

#### Recovery Actions (15+ minutes)
1. **Rollback if needed**
   ```bash
   kubectl rollout undo deployment/backend -n social-live-prod
   kubectl rollout status deployment/backend -n social-live-prod
   ```

2. **Scale up resources**
   ```bash
   kubectl scale deployment backend --replicas=10 -n social-live-prod
   ```

3. **Database recovery**
   ```bash
   # If database issues, restore from backup
   gunzip -c /backups/latest_backup.sql.gz | psql $DATABASE_URL
   ```

### Data Loss Prevention

#### Immediate Backup
```bash
#!/bin/bash
# Emergency backup script
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Database backup
pg_dump $DATABASE_URL > /tmp/emergency_backup_${TIMESTAMP}.sql
gzip /tmp/emergency_backup_${TIMESTAMP}.sql

# Upload to S3
aws s3 cp /tmp/emergency_backup_${TIMESTAMP}.sql.gz \
  s3://your-backup-bucket/emergency/

echo "Emergency backup completed: emergency_backup_${TIMESTAMP}.sql.gz"
```

## Preventive Measures

### Regular Health Checks
```bash
#!/bin/bash
# Weekly health check script
echo "=== Weekly Health Check ==="

# 1. Check certificate expiration
kubectl get certificates -n social-live-prod -o custom-columns=NAME:.metadata.name,READY:.status.conditions[0].status,EXPIRY:.status.notAfter

# 2. Database maintenance
psql $DATABASE_URL -c "VACUUM ANALYZE;"

# 3. Clean up old data
psql $DATABASE_URL -c "DELETE FROM user_sessions WHERE expires_at < NOW() - INTERVAL '30 days';"

# 4. Check backup integrity
aws s3 ls s3://your-backup-bucket/database/ | tail -5

echo "Weekly health check completed!"
```

### Capacity Planning
```bash
#!/bin/bash
# Monthly capacity review
echo "=== Capacity Planning Report ==="

# Resource usage trends
kubectl top nodes
kubectl top pods -n social-live-prod

# Database growth
DB_SIZE=$(psql $DATABASE_URL -t -c "SELECT pg_size_pretty(pg_database_size('sociallive_prod'));")
echo "Database size: $DB_SIZE"

# User growth
USER_COUNT=$(psql $DATABASE_URL -t -c "SELECT COUNT(*) FROM users;")
echo "Total users: $USER_COUNT"

# Storage usage
df -h /var/lib/postgresql/data

echo "Capacity planning report completed!"
```

## Contact & Escalation

### Emergency Contacts
- **Primary On-call**: +1-555-0101
- **Secondary On-call**: +1-555-0102
- **Engineering Manager**: +1-555-0103
- **DevOps Lead**: +1-555-0104

### Escalation Matrix
1. **Severity 1**: Immediate call to primary on-call
2. **No response (15 min)**: Call secondary on-call
3. **No response (30 min)**: Call engineering manager
4. **Major incident**: Conference bridge: +1-555-0199

### Communication Channels
- **Slack**: #social-live-incidents
- **Email**: incidents@yourdomain.com
- **Status Page**: https://status.yourdomain.com