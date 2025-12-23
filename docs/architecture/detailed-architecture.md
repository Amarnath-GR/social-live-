# Architecture Documentation - Social Live Platform

## System Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                            │
├─────────────────┬─────────────────┬─────────────────────────────┤
│   Flutter App   │   Next.js Web   │     Admin Panel             │
│   (Mobile)      │   (Dashboard)   │     (Management)            │
└─────────┬───────┴─────────┬───────┴─────────┬───────────────────┘
          │                 │                 │
          └─────────────────┼─────────────────┘
                            │
┌───────────────────────────▼───────────────────────────────────────┐
│                    EDGE LAYER                                     │
├─────────────────┬─────────────────┬─────────────────────────────┤
│      CDN        │  Load Balancer  │        WAF                  │
│   (CloudFlare)  │    (Nginx)      │  (Security Filter)          │
└─────────┬───────┴─────────┬───────┴─────────┬───────────────────┘
          │                 │                 │
          └─────────────────┼─────────────────┘
                            │
┌───────────────────────────▼───────────────────────────────────────┐
│                   API GATEWAY LAYER                               │
├─────────────────┬─────────────────┬─────────────────────────────┤
│  Authentication │   Rate Limiting │    Request Routing          │
│     Service     │     Service     │       Service               │
└─────────┬───────┴─────────┬───────┴─────────┬───────────────────┘
          │                 │                 │
          └─────────────────┼─────────────────┘
                            │
┌───────────────────────────▼───────────────────────────────────────┐
│                  MICROSERVICES LAYER                              │
├──────────┬──────────┬──────────┬──────────┬──────────┬──────────┤
│   User   │Commerce  │Streaming │   AML    │   KYB    │  Ledger  │
│ Service  │ Service  │ Service  │ Service  │ Service  │ Service  │
└────┬─────┴────┬─────┴────┬─────┴────┬─────┴────┬─────┴────┬─────┘
     │          │          │          │          │          │
     └──────────┼──────────┼──────────┼──────────┼──────────┘
                │          │          │          │
┌───────────────▼──────────▼──────────▼──────────▼───────────────────┐
│                     DATA LAYER                                    │
├─────────────────┬─────────────────┬─────────────────────────────┤
│   PostgreSQL    │   Redis Cache   │    File Storage             │
│  (Primary DB)   │   (Sessions)    │   (Documents/Media)         │
└─────────────────┴─────────────────┴─────────────────────────────┘
```

### Technology Stack

#### Frontend Technologies
```yaml
Mobile Application:
  framework: Flutter 3.16+
  language: Dart 3.0+
  state_management: Provider + Riverpod
  ui_framework: Material Design 3
  platforms: [iOS, Android, Web, Desktop]

Web Application:
  framework: Next.js 14+
  language: TypeScript 5.0+
  state_management: Zustand
  ui_framework: Tailwind CSS + shadcn/ui
  deployment: Vercel/Static hosting

Admin Panel:
  framework: React 18+
  language: TypeScript 5.0+
  ui_framework: Ant Design
  charts: Chart.js + D3.js
```

#### Backend Technologies
```yaml
API Gateway:
  framework: NestJS 10+
  language: TypeScript 5.0+
  runtime: Node.js 18+
  authentication: JWT + Passport.js
  validation: class-validator + class-transformer

Microservices:
  auth_service:
    framework: NestJS
    database: PostgreSQL + Redis
    features: [JWT, OAuth2, MFA, Session Management]
  
  commerce_service:
    framework: NestJS
    database: PostgreSQL
    features: [Orders, Payments, Inventory, Marketplace]
  
  streaming_service:
    framework: NestJS
    database: PostgreSQL + Redis
    features: [Live Streaming, WebRTC, Chat, Gifts]
  
  compliance_services:
    aml_service:
      framework: NestJS
      database: PostgreSQL
      features: [Transaction Monitoring, Risk Scoring, SAR]
    
    kyb_service:
      framework: NestJS
      database: PostgreSQL
      features: [Document Verification, Identity Checks]
  
  ledger_service:
    framework: NestJS
    database: PostgreSQL
    features: [Double-Entry Accounting, Reconciliation]
```

#### Data Layer
```yaml
Primary Database:
  engine: PostgreSQL 15+
  features: [ACID, Row-Level Security, Encryption]
  backup: Continuous WAL-E + Daily snapshots
  scaling: Read replicas + Connection pooling

Cache Layer:
  engine: Redis 7+
  features: [Sessions, Rate Limiting, Real-time data]
  deployment: Redis Cluster
  persistence: RDB + AOF

File Storage:
  primary: AWS S3 / MinIO
  features: [Encryption at rest, Versioning, Lifecycle]
  cdn: CloudFlare / AWS CloudFront
  backup: Cross-region replication

Search Engine:
  engine: Elasticsearch 8+
  features: [Full-text search, Analytics, Logging]
  deployment: Elasticsearch cluster
```

#### Infrastructure
```yaml
Container Platform:
  orchestration: Kubernetes 1.28+
  runtime: Docker 24+
  service_mesh: Istio (optional)
  ingress: Nginx Ingress Controller

Cloud Platform:
  primary: AWS / Azure / GCP
  services:
    - EKS/AKS/GKE (Kubernetes)
    - RDS/Azure Database (PostgreSQL)
    - ElastiCache/Azure Cache (Redis)
    - S3/Blob Storage (Files)
    - CloudFront/CDN (Content Delivery)

Monitoring Stack:
  metrics: Prometheus + Grafana
  logging: ELK Stack (Elasticsearch, Logstash, Kibana)
  tracing: Jaeger / OpenTelemetry
  alerting: AlertManager + PagerDuty
```

## Detailed Component Architecture

### Authentication & Authorization

```typescript
// Authentication Flow Architecture
interface AuthenticationArchitecture {
  components: {
    authService: {
      responsibilities: [
        'User credential validation',
        'JWT token generation/validation',
        'Session management',
        'Multi-factor authentication',
        'OAuth2 integration'
      ];
      dependencies: ['UserService', 'RedisCache', 'AMLService'];
      apis: ['/auth/login', '/auth/refresh', '/auth/logout', '/auth/mfa'];
    };
    
    jwtStrategy: {
      algorithm: 'RS256';
      expiration: '15m';
      refreshExpiration: '7d';
      keyRotation: '90d';
    };
    
    sessionManagement: {
      storage: 'Redis';
      ttl: '24h';
      maxSessions: 5;
      concurrentSessions: true;
    };
  };
}
```

### Microservices Communication

```yaml
# Service Communication Patterns
communication_patterns:
  synchronous:
    protocol: HTTP/gRPC
    authentication: Service-to-service JWT
    timeout: 30s
    retry_policy: Exponential backoff
    circuit_breaker: Hystrix pattern
  
  asynchronous:
    message_broker: Redis Pub/Sub / Apache Kafka
    event_sourcing: Event Store
    saga_pattern: Choreography-based
    dead_letter_queue: Enabled
  
  data_consistency:
    pattern: Eventually consistent
    compensation: Saga pattern
    idempotency: UUID-based operation keys
```

### Data Architecture

#### Database Schema Design
```sql
-- Core User Management
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    profile JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP NULL
);

-- Compliance & Verification
CREATE TABLE compliance_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    type VARCHAR(50) NOT NULL, -- 'kyb', 'aml'
    status VARCHAR(50) NOT NULL,
    external_id VARCHAR(255),
    external_data JSONB,
    submitted_at TIMESTAMP,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Financial Ledger (Double-Entry)
CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id UUID NOT NULL,
    account_code VARCHAR(20) NOT NULL,
    debit_amount DECIMAL(15,2) DEFAULT 0,
    credit_amount DECIMAL(15,2) DEFAULT 0,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT check_debit_or_credit CHECK (
        (debit_amount > 0 AND credit_amount = 0) OR 
        (credit_amount > 0 AND debit_amount = 0)
    )
);

-- AML Transaction Monitoring
CREATE TABLE aml_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    transaction_id UUID,
    alert_type VARCHAR(100) NOT NULL,
    risk_score INTEGER NOT NULL,
    status VARCHAR(50) DEFAULT 'open',
    assigned_to UUID,
    created_at TIMESTAMP DEFAULT NOW(),
    resolved_at TIMESTAMP
);
```

#### Data Flow Patterns
```typescript
// Repository Pattern Implementation
export abstract class BaseRepository<T> {
  constructor(protected db: Database) {}
  
  async findById(id: string): Promise<T | null> {
    const result = await this.db.query(
      `SELECT * FROM ${this.tableName} WHERE id = $1 AND deleted_at IS NULL`,
      [id]
    );
    return result.rows[0] || null;
  }
  
  async create(data: Partial<T>): Promise<T> {
    const fields = Object.keys(data).join(', ');
    const values = Object.values(data);
    const placeholders = values.map((_, i) => `$${i + 1}`).join(', ');
    
    const result = await this.db.query(
      `INSERT INTO ${this.tableName} (${fields}) VALUES (${placeholders}) RETURNING *`,
      values
    );
    
    return result.rows[0];
  }
  
  protected abstract get tableName(): string;
}

// Event Sourcing Pattern
export class EventStore {
  async appendEvent(streamId: string, event: DomainEvent): Promise<void> {
    await this.db.query(
      `INSERT INTO event_store (stream_id, event_type, event_data, version, created_at)
       VALUES ($1, $2, $3, (SELECT COALESCE(MAX(version), 0) + 1 FROM event_store WHERE stream_id = $1), NOW())`,
      [streamId, event.type, JSON.stringify(event.data)]
    );
  }
  
  async getEvents(streamId: string, fromVersion?: number): Promise<DomainEvent[]> {
    const query = fromVersion 
      ? `SELECT * FROM event_store WHERE stream_id = $1 AND version >= $2 ORDER BY version`
      : `SELECT * FROM event_store WHERE stream_id = $1 ORDER BY version`;
    
    const params = fromVersion ? [streamId, fromVersion] : [streamId];
    const result = await this.db.query(query, params);
    
    return result.rows.map(row => ({
      type: row.event_type,
      data: JSON.parse(row.event_data),
      version: row.version,
      timestamp: row.created_at
    }));
  }
}
```

## Security Architecture

### Defense in Depth Strategy

```yaml
security_layers:
  layer_1_perimeter:
    components: [WAF, DDoS Protection, Geographic Filtering]
    technologies: [CloudFlare, AWS Shield, Fail2ban]
    
  layer_2_network:
    components: [Load Balancer, Network Segmentation, VPN]
    technologies: [Nginx, Kubernetes NetworkPolicies, WireGuard]
    
  layer_3_application:
    components: [Authentication, Authorization, Input Validation]
    technologies: [JWT, RBAC, class-validator]
    
  layer_4_data:
    components: [Encryption, Access Control, Audit Logging]
    technologies: [AES-256, Row-Level Security, Audit Triggers]
    
  layer_5_monitoring:
    components: [SIEM, Anomaly Detection, Incident Response]
    technologies: [ELK Stack, ML Models, PagerDuty]
```

### Encryption Strategy

```typescript
// Encryption Architecture
export class EncryptionService {
  private readonly algorithms = {
    symmetric: 'aes-256-gcm',
    asymmetric: 'rsa-4096',
    hashing: 'argon2id',
    signing: 'ed25519'
  };
  
  async encryptSensitiveData(data: string, context: string): Promise<EncryptedData> {
    const key = await this.getEncryptionKey(context);
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipher(this.algorithms.symmetric, key);
    
    cipher.setAAD(Buffer.from(context));
    
    let encrypted = cipher.update(data, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    const authTag = cipher.getAuthTag();
    
    return {
      encrypted,
      iv: iv.toString('hex'),
      authTag: authTag.toString('hex'),
      algorithm: this.algorithms.symmetric,
      keyVersion: await this.getKeyVersion(context)
    };
  }
  
  async decryptSensitiveData(encryptedData: EncryptedData, context: string): Promise<string> {
    const key = await this.getEncryptionKey(context, encryptedData.keyVersion);
    const decipher = crypto.createDecipher(encryptedData.algorithm, key);
    
    decipher.setAAD(Buffer.from(context));
    decipher.setAuthTag(Buffer.from(encryptedData.authTag, 'hex'));
    
    let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  }
}
```

## Performance Architecture

### Caching Strategy

```typescript
// Multi-Level Caching Architecture
export class CacheManager {
  private readonly cacheHierarchy = {
    l1: new Map<string, any>(), // In-memory cache
    l2: new RedisCache(),       // Distributed cache
    l3: new DatabaseCache()     // Database query cache
  };
  
  async get<T>(key: string, options?: CacheOptions): Promise<T | null> {
    // L1 Cache check
    if (this.cacheHierarchy.l1.has(key)) {
      return this.cacheHierarchy.l1.get(key);
    }
    
    // L2 Cache check
    const l2Result = await this.cacheHierarchy.l2.get(key);
    if (l2Result) {
      // Populate L1 cache
      this.cacheHierarchy.l1.set(key, l2Result);
      return l2Result;
    }
    
    // L3 Cache check (database)
    const l3Result = await this.cacheHierarchy.l3.get(key);
    if (l3Result) {
      // Populate L2 and L1 caches
      await this.cacheHierarchy.l2.set(key, l3Result, options?.ttl);
      this.cacheHierarchy.l1.set(key, l3Result);
      return l3Result;
    }
    
    return null;
  }
  
  async set<T>(key: string, value: T, options?: CacheOptions): Promise<void> {
    // Set in all cache levels
    this.cacheHierarchy.l1.set(key, value);
    await this.cacheHierarchy.l2.set(key, value, options?.ttl);
    
    if (options?.persistToDatabase) {
      await this.cacheHierarchy.l3.set(key, value);
    }
  }
}
```

### Database Optimization

```sql
-- Performance Optimization Indexes
CREATE INDEX CONCURRENTLY idx_users_email_active 
ON users(email) WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY idx_transactions_user_date 
ON transactions(user_id, created_at DESC) 
WHERE status = 'completed';

CREATE INDEX CONCURRENTLY idx_compliance_verifications_status 
ON compliance_verifications(user_id, type, status) 
WHERE status IN ('pending', 'in_progress');

-- Partitioning for large tables
CREATE TABLE audit_logs (
    id UUID DEFAULT gen_random_uuid(),
    user_id UUID,
    action VARCHAR(100),
    details JSONB,
    created_at TIMESTAMP DEFAULT NOW()
) PARTITION BY RANGE (created_at);

CREATE TABLE audit_logs_2024_01 PARTITION OF audit_logs
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- Materialized views for analytics
CREATE MATERIALIZED VIEW user_activity_summary AS
SELECT 
    user_id,
    DATE_TRUNC('day', created_at) as activity_date,
    COUNT(*) as action_count,
    COUNT(DISTINCT action) as unique_actions
FROM audit_logs
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY user_id, DATE_TRUNC('day', created_at);

CREATE UNIQUE INDEX ON user_activity_summary (user_id, activity_date);
```

## Scalability Architecture

### Horizontal Scaling Strategy

```yaml
# Kubernetes Horizontal Pod Autoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend-deployment
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

### Load Balancing Configuration

```nginx
# Nginx Load Balancer Configuration
upstream backend_servers {
    least_conn;
    server backend-1:3000 max_fails=3 fail_timeout=30s;
    server backend-2:3000 max_fails=3 fail_timeout=30s;
    server backend-3:3000 max_fails=3 fail_timeout=30s;
    
    # Health check
    keepalive 32;
}

server {
    listen 80;
    server_name api.sociallive.com;
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
    
    location / {
        proxy_pass http://backend_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # Health check
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
    }
}
```

## Monitoring & Observability Architecture

### Metrics Collection

```typescript
// Prometheus Metrics Integration
export class MetricsService {
  private readonly metrics = {
    httpRequests: new promClient.Counter({
      name: 'http_requests_total',
      help: 'Total number of HTTP requests',
      labelNames: ['method', 'route', 'status_code']
    }),
    
    httpDuration: new promClient.Histogram({
      name: 'http_request_duration_seconds',
      help: 'Duration of HTTP requests in seconds',
      labelNames: ['method', 'route'],
      buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
    }),
    
    databaseQueries: new promClient.Counter({
      name: 'database_queries_total',
      help: 'Total number of database queries',
      labelNames: ['operation', 'table']
    }),
    
    complianceEvents: new promClient.Counter({
      name: 'compliance_events_total',
      help: 'Total number of compliance events',
      labelNames: ['type', 'status']
    })
  };
  
  recordHttpRequest(method: string, route: string, statusCode: number, duration: number) {
    this.metrics.httpRequests.inc({ method, route, status_code: statusCode.toString() });
    this.metrics.httpDuration.observe({ method, route }, duration);
  }
  
  recordDatabaseQuery(operation: string, table: string) {
    this.metrics.databaseQueries.inc({ operation, table });
  }
  
  recordComplianceEvent(type: string, status: string) {
    this.metrics.complianceEvents.inc({ type, status });
  }
}
```

### Distributed Tracing

```typescript
// OpenTelemetry Tracing Setup
export class TracingService {
  private tracer: Tracer;
  
  constructor() {
    const provider = new NodeTracerProvider({
      resource: new Resource({
        [SemanticResourceAttributes.SERVICE_NAME]: 'social-live-api',
        [SemanticResourceAttributes.SERVICE_VERSION]: process.env.APP_VERSION || '1.0.0',
      }),
    });
    
    provider.addSpanProcessor(new BatchSpanProcessor(new JaegerExporter({
      endpoint: process.env.JAEGER_ENDPOINT || 'http://jaeger:14268/api/traces',
    })));
    
    provider.register();
    this.tracer = trace.getTracer('social-live-api');
  }
  
  async traceAsyncOperation<T>(
    name: string, 
    operation: (span: Span) => Promise<T>,
    attributes?: Record<string, string | number | boolean>
  ): Promise<T> {
    return this.tracer.startActiveSpan(name, async (span) => {
      try {
        if (attributes) {
          span.setAttributes(attributes);
        }
        
        const result = await operation(span);
        span.setStatus({ code: SpanStatusCode.OK });
        return result;
      } catch (error) {
        span.recordException(error as Error);
        span.setStatus({ 
          code: SpanStatusCode.ERROR, 
          message: (error as Error).message 
        });
        throw error;
      } finally {
        span.end();
      }
    });
  }
}
```

## Deployment Architecture

### CI/CD Pipeline

```yaml
# GitHub Actions Workflow
name: CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm run test:coverage
      
      - name: Run security audit
        run: npm audit --audit-level high
      
      - name: Run compliance checks
        run: npm run compliance:check
  
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build Docker image
        run: |
          docker build -t sociallive/backend:${{ github.sha }} .
          docker build -t sociallive/backend:latest .
      
      - name: Security scan
        run: |
          docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy image sociallive/backend:${{ github.sha }}
      
      - name: Push to registry
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker push sociallive/backend:${{ github.sha }}
          docker push sociallive/backend:latest
  
  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to Kubernetes
        run: |
          kubectl set image deployment/backend backend=sociallive/backend:${{ github.sha }}
          kubectl rollout status deployment/backend
```

### Infrastructure as Code

```terraform
# Terraform Infrastructure Configuration
provider "aws" {
  region = var.aws_region
}

# EKS Cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  
  cluster_name    = "social-live-cluster"
  cluster_version = "1.28"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  node_groups = {
    main = {
      desired_capacity = 3
      max_capacity     = 10
      min_capacity     = 3
      
      instance_types = ["t3.medium"]
      
      k8s_labels = {
        Environment = var.environment
        Application = "social-live"
      }
    }
  }
}

# RDS PostgreSQL
resource "aws_db_instance" "main" {
  identifier = "social-live-db"
  
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"
  
  allocated_storage     = 100
  max_allocated_storage = 1000
  storage_encrypted     = true
  
  db_name  = "sociallive"
  username = var.db_username
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = false
  final_snapshot_identifier = "social-live-db-final-snapshot"
  
  tags = {
    Name        = "social-live-db"
    Environment = var.environment
  }
}

# ElastiCache Redis
resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "social-live-redis"
  description                = "Redis cluster for Social Live"
  
  node_type                  = "cache.t3.micro"
  port                       = 6379
  parameter_group_name       = "default.redis7"
  
  num_cache_clusters         = 2
  automatic_failover_enabled = true
  multi_az_enabled          = true
  
  subnet_group_name = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]
  
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  
  tags = {
    Name        = "social-live-redis"
    Environment = var.environment
  }
}
```

This comprehensive architecture documentation provides detailed technical specifications, implementation patterns, and deployment strategies for the Social Live platform, ensuring scalability, security, and compliance across all system components.