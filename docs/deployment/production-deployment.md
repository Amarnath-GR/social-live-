# Production Deployment Guide

## Overview
Complete guide for deploying the Social Live platform to production with Kubernetes, monitoring, and security best practices.

## Prerequisites

### Infrastructure Requirements
- **Kubernetes Cluster**: v1.28+ (3+ nodes, 8GB RAM each)
- **Database**: PostgreSQL 15+ (managed service recommended)
- **Cache**: Redis 7+ (managed service recommended)
- **Storage**: S3-compatible object storage
- **Domain**: SSL certificate for HTTPS

### Tools Required
- `kubectl` v1.28+
- `docker` v24+
- `helm` v3.12+
- `git`

## Quick Production Setup

### 1. Clone Repository
```bash
git clone https://github.com/your-org/social-live-platform.git
cd social-live-platform
```

### 2. Configure Environment
```bash
# Copy production environment template
cp .env.production.example .env.production

# Edit production configuration
nano .env.production
```

**Required Environment Variables:**
```env
# Database
DATABASE_URL=postgresql://user:pass@prod-db:5432/sociallive
REDIS_URL=redis://prod-redis:6379

# Security
JWT_SECRET=your-super-secure-jwt-secret-256-bits
JWT_REFRESH_SECRET=your-refresh-secret-256-bits
ENCRYPTION_KEY=your-encryption-key-32-chars

# External Services
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
S3_BUCKET=your-s3-bucket

# Application
NODE_ENV=production
PORT=3000
API_URL=https://api.yourdomain.com
WEB_URL=https://app.yourdomain.com
```

### 3. Deploy to Kubernetes
```bash
# Create namespace
kubectl create namespace social-live-prod

# Create secrets
kubectl create secret generic app-secrets \
  --from-env-file=.env.production \
  -n social-live-prod

# Deploy application
kubectl apply -f k8s/overlays/production/ -n social-live-prod

# Verify deployment
kubectl get pods -n social-live-prod
```

### 4. Setup Monitoring
```bash
# Deploy monitoring stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --values monitoring/prometheus-values.yaml

# Install Grafana dashboards
kubectl apply -f monitoring/grafana/dashboards/ -n monitoring
```

## Detailed Deployment Steps

### Database Setup

#### PostgreSQL Configuration
```sql
-- Create production database
CREATE DATABASE sociallive_prod;
CREATE USER sociallive_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE sociallive_prod TO sociallive_user;

-- Performance tuning
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET wal_buffers = '16MB';
SELECT pg_reload_conf();
```

#### Database Migration
```bash
# Run migrations
npm run prisma:migrate:deploy

# Seed production data
npm run seed:production
```

### Redis Configuration
```redis
# redis.conf production settings
maxmemory 512mb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
appendonly yes
appendfsync everysec
```

### Application Deployment

#### Backend Service
```yaml
# k8s/overlays/production/backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: social-live-prod
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: sociallive/backend:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        envFrom:
        - secretRef:
            name: app-secrets
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

#### Frontend Service
```yaml
# k8s/overlays/production/frontend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: social-live-prod
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: sociallive/frontend:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: NEXT_PUBLIC_API_URL
          value: "https://api.yourdomain.com"
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "200m"
```

### Load Balancer & Ingress
```yaml
# k8s/overlays/production/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: social-live-ingress
  namespace: social-live-prod
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
spec:
  tls:
  - hosts:
    - api.yourdomain.com
    - app.yourdomain.com
    secretName: social-live-tls
  rules:
  - host: api.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 80
  - host: app.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
```

### Auto-scaling Configuration
```yaml
# k8s/overlays/production/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: social-live-prod
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 3
  maxReplicas: 50
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
```

## Security Configuration

### SSL/TLS Setup
```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Create cluster issuer
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@yourdomain.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

### Network Policies
```yaml
# k8s/overlays/production/network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: social-live-network-policy
  namespace: social-live-prod
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 3000
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 5432  # PostgreSQL
    - protocol: TCP
      port: 6379  # Redis
    - protocol: TCP
      port: 443   # HTTPS
    - protocol: TCP
      port: 53    # DNS
    - protocol: UDP
      port: 53    # DNS
```

## Monitoring & Alerting

### Prometheus Configuration
```yaml
# monitoring/prometheus-values.yaml
prometheus:
  prometheusSpec:
    retention: 30d
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: fast-ssd
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi
    additionalScrapeConfigs:
    - job_name: 'social-live-backend'
      static_configs:
      - targets: ['backend-service:3000']
      metrics_path: '/metrics'
      scrape_interval: 30s
```

### Grafana Dashboards
```bash
# Import pre-configured dashboards
kubectl apply -f monitoring/grafana/dashboards/
```

### Alert Rules
```yaml
# monitoring/alert-rules.yaml
groups:
- name: social-live-alerts
  rules:
  - alert: HighErrorRate
    expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High error rate detected"
      description: "Error rate is {{ $value }} errors per second"
  
  - alert: HighResponseTime
    expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High response time detected"
      description: "95th percentile response time is {{ $value }}s"
```

## Backup & Recovery

### Database Backup
```bash
#!/bin/bash
# scripts/backup-database.sh
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="sociallive_backup_${DATE}.sql"

pg_dump $DATABASE_URL > /backups/$BACKUP_FILE
gzip /backups/$BACKUP_FILE

# Upload to S3
aws s3 cp /backups/${BACKUP_FILE}.gz s3://your-backup-bucket/database/

# Cleanup old backups (keep 30 days)
find /backups -name "*.gz" -mtime +30 -delete
```

### Automated Backup CronJob
```yaml
# k8s/overlays/production/backup-cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: database-backup
  namespace: social-live-prod
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:15
            command:
            - /bin/bash
            - -c
            - |
              pg_dump $DATABASE_URL | gzip > /backup/backup_$(date +%Y%m%d_%H%M%S).sql.gz
              aws s3 cp /backup/*.gz s3://your-backup-bucket/database/
            env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: DATABASE_URL
            volumeMounts:
            - name: backup-storage
              mountPath: /backup
          volumes:
          - name: backup-storage
            emptyDir: {}
          restartPolicy: OnFailure
```

## Performance Optimization

### Database Optimization
```sql
-- Create indexes for performance
CREATE INDEX CONCURRENTLY idx_posts_user_id ON posts(user_id);
CREATE INDEX CONCURRENTLY idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX CONCURRENTLY idx_feed_user_id_created_at ON feed_items(user_id, created_at DESC);

-- Analyze tables
ANALYZE posts;
ANALYZE users;
ANALYZE feed_items;
```

### Redis Optimization
```bash
# Redis memory optimization
redis-cli CONFIG SET maxmemory-policy allkeys-lru
redis-cli CONFIG SET maxmemory 1gb
redis-cli CONFIG REWRITE
```

### CDN Configuration
```nginx
# nginx.conf for CDN
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    add_header Vary Accept-Encoding;
    gzip_static on;
}
```

## Health Checks & Monitoring

### Application Health Endpoints
```typescript
// Health check implementation
@Controller('health')
export class HealthController {
  @Get()
  async health() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      version: process.env.APP_VERSION
    };
  }

  @Get('ready')
  async ready() {
    // Check database connection
    await this.prisma.$queryRaw`SELECT 1`;
    
    // Check Redis connection
    await this.redis.ping();
    
    return { status: 'ready' };
  }
}
```

### Deployment Verification
```bash
#!/bin/bash
# scripts/verify-deployment.sh

echo "Verifying deployment..."

# Check pod status
kubectl get pods -n social-live-prod

# Check service endpoints
kubectl get endpoints -n social-live-prod

# Test health endpoints
curl -f https://api.yourdomain.com/health
curl -f https://app.yourdomain.com/

# Check metrics
curl -f https://api.yourdomain.com/metrics

echo "Deployment verification complete!"
```

## Rollback Procedures

### Quick Rollback
```bash
# Rollback to previous version
kubectl rollout undo deployment/backend -n social-live-prod
kubectl rollout undo deployment/frontend -n social-live-prod

# Check rollback status
kubectl rollout status deployment/backend -n social-live-prod
```

### Database Rollback
```bash
# Restore from backup
gunzip -c /backups/sociallive_backup_YYYYMMDD_HHMMSS.sql.gz | psql $DATABASE_URL
```

## Troubleshooting

### Common Issues
1. **Pod CrashLoopBackOff**: Check logs with `kubectl logs -f pod-name`
2. **Database Connection**: Verify DATABASE_URL and network policies
3. **High Memory Usage**: Check for memory leaks and adjust limits
4. **SSL Certificate Issues**: Verify cert-manager and DNS configuration

### Emergency Contacts
- **DevOps Team**: devops@yourdomain.com
- **On-call Engineer**: +1-555-0123
- **Incident Response**: incidents@yourdomain.com