# System Architecture

## Overview
The Social Live platform follows a microservices architecture with clear separation of concerns, horizontal scalability, and comprehensive monitoring.

## High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Next.js Web   │    │   Admin Panel   │
│   (Mobile)      │    │   (Dashboard)   │    │   (Management)  │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │     Load Balancer       │
                    │     (Nginx/K8s)        │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │     NestJS Backend      │
                    │     (API Gateway)       │
                    └────────────┬────────────┘
                                 │
        ┌────────────────────────┼────────────────────────┐
        │                       │                        │
┌───────▼───────┐    ┌─────────▼─────────┐    ┌─────────▼─────────┐
│     Redis     │    │   PostgreSQL      │    │   ML Service     │
│   (Cache)     │    │   (Primary DB)    │    │ (Recommendations) │
└───────────────┘    └───────────────────┘    └───────────────────┘
```

## Component Architecture

### Frontend Layer
- **Flutter Mobile App**: Cross-platform mobile client
- **Next.js Web Portal**: Creator dashboard and admin interface
- **Responsive Design**: Optimized for all screen sizes

### API Gateway Layer
- **NestJS Backend**: RESTful API with GraphQL support
- **Authentication**: JWT-based with refresh tokens
- **Rate Limiting**: Redis-backed request throttling
- **API Versioning**: Backward-compatible versioning

### Service Layer
```
┌─────────────────────────────────────────────────────────────┐
│                    NestJS Backend Services                  │
├─────────────┬─────────────┬─────────────┬─────────────────┤
│ Auth Service│ Post Service│ Feed Service│ User Service    │
├─────────────┼─────────────┼─────────────┼─────────────────┤
│ ML Service  │ Cache Svc   │ Admin Svc   │ Monitor Service │
└─────────────┴─────────────┴─────────────┴─────────────────┘
```

### Data Layer
- **PostgreSQL**: Primary relational database
- **Redis**: Caching and session management
- **File Storage**: Local/S3-compatible storage

### Infrastructure Layer
- **Kubernetes**: Container orchestration
- **Docker**: Containerization
- **Prometheus**: Metrics collection
- **Grafana**: Monitoring dashboards

## Data Flow Architecture

### User Authentication Flow
```
Mobile/Web → API Gateway → Auth Service → JWT Token → Redis Cache
                ↓
         Database Validation → User Session → Response
```

### Content Feed Flow
```
User Request → Feed Service → Cache Check → ML Recommendations
                ↓                ↓              ↓
         Database Query ← Cache Miss ← Personalization
                ↓
         Response + Cache Update → User Feed
```

### Real-time Features
```
User Action → WebSocket → Event Bus → Real-time Updates
                ↓            ↓            ↓
         Database → Cache → Push Notifications
```

## Scalability Design

### Horizontal Scaling
- **Stateless Services**: All services are stateless for easy scaling
- **Load Balancing**: Nginx/K8s ingress with round-robin
- **Auto-scaling**: HPA based on CPU/memory metrics

### Caching Strategy
- **L1 Cache**: Application-level caching
- **L2 Cache**: Redis distributed cache
- **CDN**: Static asset delivery

### Database Scaling
- **Read Replicas**: For read-heavy operations
- **Connection Pooling**: Efficient database connections
- **Query Optimization**: Indexed queries and pagination

## Security Architecture

### Authentication & Authorization
- **JWT Tokens**: Stateless authentication
- **Role-based Access**: User, Creator, Admin roles
- **Token Refresh**: Secure token rotation

### Data Protection
- **Input Validation**: Comprehensive request validation
- **SQL Injection Prevention**: Parameterized queries
- **XSS Protection**: Content sanitization
- **CORS Configuration**: Secure cross-origin requests

### Infrastructure Security
- **HTTPS Only**: TLS encryption for all communications
- **Rate Limiting**: DDoS protection
- **Security Headers**: HSTS, CSP, X-Frame-Options
- **Environment Isolation**: Separate dev/staging/prod

## Performance Characteristics

### Response Times
- **Authentication**: < 100ms
- **Feed Loading**: < 200ms
- **Post Creation**: < 150ms
- **Search**: < 300ms

### Throughput
- **Concurrent Users**: 500+ supported
- **API Requests**: 1000+ req/sec
- **Database Queries**: 5000+ queries/sec

### Availability
- **Uptime Target**: 99.9%
- **Recovery Time**: < 5 minutes
- **Backup Frequency**: Daily automated backups

## Technology Stack

### Backend
- **Runtime**: Node.js 18+
- **Framework**: NestJS 10+
- **Database**: PostgreSQL 15+
- **Cache**: Redis 7+
- **ORM**: Prisma 5+

### Frontend
- **Mobile**: Flutter 3.16+
- **Web**: Next.js 14+
- **State Management**: Provider/Zustand
- **UI Framework**: Material Design/Tailwind CSS

### Infrastructure
- **Containerization**: Docker 24+
- **Orchestration**: Kubernetes 1.28+
- **Monitoring**: Prometheus + Grafana
- **CI/CD**: GitHub Actions

## Deployment Architecture

### Production Environment
```
Internet → CDN → Load Balancer → K8s Cluster
                                      ↓
                              ┌───────────────┐
                              │   Namespace   │
                              │   Production  │
                              └───────┬───────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
            ┌───────▼───────┐ ┌──────▼──────┐ ┌───────▼───────┐
            │   Backend     │ │   Frontend  │ │   Monitoring  │
            │   Pods (3-50) │ │   Pods (2)  │ │   Stack       │
            └───────────────┘ └─────────────┘ └───────────────┘
```

### Development Environment
- **Local Development**: Docker Compose
- **Staging**: Kubernetes staging namespace
- **Testing**: Automated CI/CD pipeline

## Monitoring & Observability

### Metrics Collection
- **Application Metrics**: Custom business metrics
- **Infrastructure Metrics**: CPU, memory, disk, network
- **Database Metrics**: Query performance, connections

### Logging
- **Structured Logging**: JSON format with correlation IDs
- **Log Levels**: Error, Warn, Info, Debug
- **Log Aggregation**: Centralized logging system

### Alerting
- **Performance Alerts**: Response time degradation
- **Error Alerts**: High error rates
- **Infrastructure Alerts**: Resource exhaustion
- **Business Alerts**: User engagement metrics