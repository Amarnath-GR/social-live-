# Operations Runbook

## Overview
Comprehensive operational procedures for managing the Social Live platform in production, including monitoring, incident response, and maintenance tasks.

## System Overview

### Production Environment
- **Kubernetes Cluster**: 3-node cluster with auto-scaling
- **Backend Services**: NestJS API (3-50 pods)
- **Frontend Services**: Next.js web app (2 pods)
- **Database**: PostgreSQL 15 (managed service)
- **Cache**: Redis 7 (managed service)
- **Monitoring**: Prometheus + Grafana stack

### Key Metrics Dashboard
```
┌─────────────────────────────────────────────────────────────┐
│                    Social Live Platform                     │
├─────────────────┬─────────────────┬─────────────────────────┤
│ Active Users    │ Response Time   │ Error Rate              │
│ 1,247          │ 156ms          │ 0.02%                   │
├─────────────────┼─────────────────┼─────────────────────────┤
│ API Requests    │ Database Conn   │ Memory Usage            │
│ 2,341/min      │ 45/100         │ 68%                     │
└─────────────────┴─────────────────┴─────────────────────────┘
```

## Daily Operations

### Morning Checklist (9:00 AM)
```bash
#!/bin/bash
# scripts/morning-checklist.sh

echo "=== Social Live Platform - Morning Health Check ==="

# 1. Check overall system status
kubectl get nodes
kubectl get pods -n social-live-prod

# 2. Verify critical services
curl -f https://api.yourdomain.com/health
curl -f https://app.yourdomain.com/

# 3. Check overnight alerts
echo "Checking Grafana for overnight alerts..."
# Review Grafana dashboard: https://grafana.yourdomain.com

# 4. Database health
psql $DATABASE_URL -c "SELECT COUNT(*) FROM users;"
psql $DATABASE_URL -c "SELECT COUNT(*) FROM posts WHERE created_at > NOW() - INTERVAL '24 hours';"

# 5. Redis health
redis-cli ping
redis-cli info memory

# 6. Check backup status
aws s3 ls s3://your-backup-bucket/database/ | tail -5

echo "Morning health check complete!"
```

### Evening Checklist (6:00 PM)
```bash
#!/bin/bash
# scripts/evening-checklist.sh

echo "=== Social Live Platform - Evening Review ==="

# 1. Review daily metrics
echo "Daily active users: $(psql $DATABASE_URL -t -c "SELECT COUNT(DISTINCT user_id) FROM user_sessions WHERE created_at > CURRENT_DATE;")"
echo "Posts created today: $(psql $DATABASE_URL -t -c "SELECT COUNT(*) FROM posts WHERE created_at > CURRENT_DATE;")"

# 2. Check resource utilization
kubectl top nodes
kubectl top pods -n social-live-prod

# 3. Review error logs
kubectl logs -l app=backend -n social-live-prod --since=24h | grep ERROR | wc -l

# 4. Verify auto-scaling
kubectl get hpa -n social-live-prod

echo "Evening review complete!"
```

## Monitoring & Alerting

### Critical Alerts (Immediate Response)

#### High Error Rate Alert
**Trigger**: Error rate > 5% for 5 minutes
**Response Time**: < 5 minutes

**Investigation Steps:**
1. Check Grafana error dashboard
2. Review application logs:
   ```bash
   kubectl logs -l app=backend -n social-live-prod --tail=100
   ```
3. Check database connectivity:
   ```bash
   psql $DATABASE_URL -c "SELECT 1;"
   ```
4. Verify Redis connectivity:
   ```bash
   redis-cli ping
   ```

**Resolution Actions:**
- If database issue: Check connection pool, restart if needed
- If application issue: Review recent deployments, consider rollback
- If external service issue: Check third-party service status

#### Service Down Alert
**Trigger**: Health check fails for 2 minutes
**Response Time**: < 2 minutes

**Investigation Steps:**
1. Check pod status:
   ```bash
   kubectl get pods -n social-live-prod
   kubectl describe pod <failing-pod>
   ```
2. Review pod logs:
   ```bash
   kubectl logs <failing-pod> -n social-live-prod
   ```
3. Check resource limits:
   ```bash
   kubectl top pods -n social-live-prod
   ```

**Resolution Actions:**
- Restart failing pods: `kubectl delete pod <pod-name> -n social-live-prod`
- Scale up if resource constrained: `kubectl scale deployment backend --replicas=5`
- Check for recent configuration changes

### Warning Alerts (Response within 30 minutes)

#### High Response Time Alert
**Trigger**: 95th percentile > 1 second for 10 minutes

**Investigation Steps:**
1. Check database performance:
   ```sql
   SELECT query, mean_exec_time, calls 
   FROM pg_stat_statements 
   ORDER BY mean_exec_time DESC 
   LIMIT 10;
   ```
2. Review slow queries:
   ```bash
   tail -f /var/log/postgresql/postgresql.log | grep "slow query"
   ```
3. Check Redis performance:
   ```bash
   redis-cli --latency-history
   ```

**Resolution Actions:**
- Optimize slow queries
- Scale up backend pods
- Clear Redis cache if needed
- Review recent code changes

#### High Memory Usage Alert
**Trigger**: Memory usage > 85% for 15 minutes

**Investigation Steps:**
1. Check memory usage by pod:
   ```bash
   kubectl top pods -n social-live-prod --sort-by=memory
   ```
2. Review memory leaks:
   ```bash
   kubectl exec -it <pod-name> -- node --inspect /app/dist/main.js
   ```

**Resolution Actions:**
- Restart high-memory pods
- Scale up if needed
- Review application for memory leaks

## Incident Response

### Severity Levels

#### Severity 1 (Critical)
- **Definition**: Complete service outage or data loss
- **Response Time**: < 15 minutes
- **Escalation**: Immediate notification to on-call engineer

#### Severity 2 (High)
- **Definition**: Significant feature degradation affecting >50% users
- **Response Time**: < 1 hour
- **Escalation**: Notification to engineering team

#### Severity 3 (Medium)
- **Definition**: Minor feature issues affecting <10% users
- **Response Time**: < 4 hours
- **Escalation**: Standard ticket queue

### Incident Response Process

#### 1. Detection & Acknowledgment
```bash
# Acknowledge alert in monitoring system
curl -X POST "https://grafana.yourdomain.com/api/alerts/1/acknowledge" \
  -H "Authorization: Bearer $GRAFANA_TOKEN"

# Create incident channel
# Slack: #incident-YYYY-MM-DD-HHMMSS
```

#### 2. Initial Assessment
```bash
# Quick system overview
kubectl get pods -n social-live-prod
kubectl get services -n social-live-prod
kubectl get ingress -n social-live-prod

# Check external dependencies
curl -f https://api.external-service.com/health
```

#### 3. Communication Template
```
🚨 INCIDENT ALERT 🚨
Severity: [1/2/3]
Service: Social Live Platform
Issue: [Brief description]
Impact: [User impact description]
ETA: [Estimated resolution time]
Incident Commander: [Name]
Status Page: https://status.yourdomain.com
```

#### 4. Resolution & Post-Mortem
```markdown
# Incident Post-Mortem Template

## Incident Summary
- **Date**: YYYY-MM-DD
- **Duration**: X hours Y minutes
- **Severity**: [1/2/3]
- **Root Cause**: [Technical root cause]

## Timeline
- HH:MM - Issue detected
- HH:MM - Investigation started
- HH:MM - Root cause identified
- HH:MM - Fix implemented
- HH:MM - Service restored

## Impact
- **Users Affected**: X users
- **Revenue Impact**: $X
- **SLA Breach**: Yes/No

## Root Cause Analysis
[Detailed technical analysis]

## Action Items
1. [ ] Immediate fix (Owner: Name, Due: Date)
2. [ ] Long-term prevention (Owner: Name, Due: Date)
3. [ ] Monitoring improvement (Owner: Name, Due: Date)
```

## Maintenance Procedures

### Weekly Maintenance (Sundays 2:00 AM UTC)

#### Database Maintenance
```bash
#!/bin/bash
# scripts/weekly-db-maintenance.sh

echo "Starting weekly database maintenance..."

# 1. Update statistics
psql $DATABASE_URL -c "ANALYZE;"

# 2. Reindex if needed
psql $DATABASE_URL -c "REINDEX INDEX CONCURRENTLY idx_posts_created_at;"

# 3. Clean up old sessions
psql $DATABASE_URL -c "DELETE FROM user_sessions WHERE expires_at < NOW() - INTERVAL '7 days';"

# 4. Vacuum analyze
psql $DATABASE_URL -c "VACUUM ANALYZE;"

echo "Database maintenance complete!"
```

#### Application Maintenance
```bash
#!/bin/bash
# scripts/weekly-app-maintenance.sh

echo "Starting weekly application maintenance..."

# 1. Clear old logs
kubectl delete pods -l app=backend -n social-live-prod --field-selector=status.phase=Succeeded

# 2. Update container images (if available)
kubectl set image deployment/backend backend=sociallive/backend:latest -n social-live-prod
kubectl rollout status deployment/backend -n social-live-prod

# 3. Clean up unused resources
kubectl delete configmap --field-selector metadata.name!=active-config -n social-live-prod

echo "Application maintenance complete!"
```

### Monthly Maintenance (First Sunday of month)

#### Security Updates
```bash
#!/bin/bash
# scripts/monthly-security-maintenance.sh

echo "Starting monthly security maintenance..."

# 1. Update base images
docker pull node:18-alpine
docker pull postgres:15
docker pull redis:7-alpine

# 2. Scan for vulnerabilities
trivy image sociallive/backend:latest
trivy image sociallive/frontend:latest

# 3. Update SSL certificates (if needed)
kubectl get certificates -n social-live-prod

# 4. Review access logs
kubectl logs -l app=nginx-ingress --since=720h | grep "401\|403" | wc -l

echo "Security maintenance complete!"
```

## Performance Optimization

### Database Performance Tuning

#### Query Optimization
```sql
-- Find slow queries
SELECT query, mean_exec_time, calls, total_exec_time
FROM pg_stat_statements
WHERE mean_exec_time > 100
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Check index usage
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM pg_stats
WHERE schemaname = 'public'
ORDER BY n_distinct DESC;

-- Monitor connection usage
SELECT count(*), state
FROM pg_stat_activity
GROUP BY state;
```

#### Index Management
```sql
-- Create performance indexes
CREATE INDEX CONCURRENTLY idx_posts_user_created 
ON posts(user_id, created_at DESC) 
WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY idx_feed_recommendations 
ON feed_items(user_id, score DESC, created_at DESC);

-- Monitor index usage
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

### Application Performance

#### Memory Optimization
```typescript
// Memory monitoring middleware
export class MemoryMonitoringMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const memUsage = process.memoryUsage();
    
    if (memUsage.heapUsed > 500 * 1024 * 1024) { // 500MB
      console.warn('High memory usage detected:', memUsage);
    }
    
    next();
  }
}
```

#### Cache Optimization
```bash
# Redis memory analysis
redis-cli --bigkeys

# Cache hit rate monitoring
redis-cli info stats | grep keyspace_hits
redis-cli info stats | grep keyspace_misses

# Optimize cache expiration
redis-cli CONFIG SET maxmemory-policy allkeys-lru
```

## Backup & Recovery

### Automated Backup Verification
```bash
#!/bin/bash
# scripts/verify-backups.sh

echo "Verifying backup integrity..."

# 1. Check latest backup exists
LATEST_BACKUP=$(aws s3 ls s3://your-backup-bucket/database/ | sort | tail -n 1 | awk '{print $4}')
echo "Latest backup: $LATEST_BACKUP"

# 2. Download and test restore
aws s3 cp s3://your-backup-bucket/database/$LATEST_BACKUP /tmp/
gunzip /tmp/$LATEST_BACKUP

# 3. Test restore to temporary database
createdb test_restore_$(date +%s)
psql test_restore_$(date +%s) < /tmp/${LATEST_BACKUP%.gz}

echo "Backup verification complete!"
```

### Disaster Recovery Procedures

#### Complete System Recovery
```bash
#!/bin/bash
# scripts/disaster-recovery.sh

echo "Starting disaster recovery procedure..."

# 1. Restore database from backup
BACKUP_DATE="2024-01-01_020000"
aws s3 cp s3://your-backup-bucket/database/sociallive_backup_${BACKUP_DATE}.sql.gz /tmp/
gunzip /tmp/sociallive_backup_${BACKUP_DATE}.sql.gz
psql $DATABASE_URL < /tmp/sociallive_backup_${BACKUP_DATE}.sql

# 2. Deploy application
kubectl apply -f k8s/overlays/production/ -n social-live-prod

# 3. Verify services
kubectl wait --for=condition=ready pod -l app=backend -n social-live-prod --timeout=300s
curl -f https://api.yourdomain.com/health

echo "Disaster recovery complete!"
```

## Capacity Planning

### Resource Monitoring
```bash
#!/bin/bash
# scripts/capacity-monitoring.sh

echo "=== Capacity Planning Report ==="

# CPU and Memory trends
kubectl top nodes
kubectl top pods -n social-live-prod

# Database growth
DB_SIZE=$(psql $DATABASE_URL -t -c "SELECT pg_size_pretty(pg_database_size('sociallive_prod'));")
echo "Database size: $DB_SIZE"

# Storage usage
df -h /var/lib/postgresql/data

# Network usage
kubectl get --raw /api/v1/nodes/node-1/proxy/stats/summary | jq '.network'

echo "Capacity monitoring complete!"
```

### Scaling Triggers
- **CPU Usage > 70%**: Scale up backend pods
- **Memory Usage > 80%**: Scale up backend pods
- **Database Connections > 80%**: Increase connection pool
- **Response Time > 500ms**: Investigate and scale if needed

## Contact Information

### On-Call Rotation
- **Primary**: engineer1@yourdomain.com (+1-555-0101)
- **Secondary**: engineer2@yourdomain.com (+1-555-0102)
- **Escalation**: manager@yourdomain.com (+1-555-0103)

### Emergency Procedures
1. **Immediate**: Call on-call engineer
2. **No Response (15 min)**: Call secondary engineer
3. **Critical Issue**: Call escalation manager
4. **External Dependencies**: Contact vendor support

### Communication Channels
- **Slack**: #social-live-ops
- **Email**: ops@yourdomain.com
- **Status Page**: https://status.yourdomain.com
- **Incident Management**: https://incidents.yourdomain.com