# Analytics Service - Event Tracking System

## Overview
Comprehensive event tracking system that captures user interactions, dwell time, engagement metrics, and business events across the Social Live platform.

## Features

### Event Types
- **View Events**: Content views with dwell time tracking
- **Engagement Events**: Likes, shares, comments, follows
- **Purchase Events**: E-commerce transactions and revenue tracking
- **Stream Events**: Live streaming interactions and metrics
- **Session Events**: User session management and analytics

### Schema Versioning
- **v1.0.0**: Basic event structure with core fields
- **v1.1.0**: Enhanced with metadata, duration, and device info
- Backward compatibility maintained across versions

### Analytics Capabilities
- Real-time event ingestion
- Batch event processing
- Automated hourly aggregations
- Dashboard metrics and reporting
- Funnel analysis and cohort tracking
- Retention analysis

## API Endpoints

### Event Tracking
```bash
# Track single event
POST /analytics/events/track
{
  "eventType": "view",
  "data": {
    "contentType": "post",
    "contentId": "post-123",
    "viewDuration": 45
  }
}

# Track batch events
POST /analytics/events/batch
{
  "events": [...]
}

# Convenience endpoints
POST /analytics/events/view
POST /analytics/events/engagement
POST /analytics/events/purchase
POST /analytics/events/stream
POST /analytics/events/session
```

### Analytics & Reporting
```bash
# Dashboard metrics
GET /analytics/dashboard?timeframe=7d

# Event queries
GET /analytics/events?eventType=view&timeframe=24h

# Funnel analysis
GET /analytics/funnel?steps=[...]

# Cohort analysis
GET /analytics/cohort?timeframe=30d

# Retention analysis
GET /analytics/retention?timeframe=30d
```

## Client Integration

### Flutter Mobile App
```dart
import 'package:analytics_service.dart';

// Initialize analytics
AnalyticsService.initialize();

// Track events
AnalyticsService.trackPostView('post-123');
AnalyticsService.trackPostLike('post-123');
AnalyticsService.trackPurchase(
  productId: 'product-456',
  orderId: 'order-789',
  amount: 29.99,
  paymentMethod: 'wallet',
);

// Automatic dwell time tracking
AnalyticsService.startDwellTracking('post', 'post-123');
AnalyticsService.stopDwellTracking('post', 'post-123');
```

### React Web Portal
```typescript
import { AnalyticsDashboard } from './components/AnalyticsDashboard';

// Track events
const trackEvent = async (eventType: string, data: any) => {
  await fetch('/api/analytics/events/track', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ eventType, data }),
  });
};

// Use analytics dashboard
<AnalyticsDashboard />
```

### Service Integration
```typescript
import { AnalyticsHelper } from './shared/analytics.helper';

// Track from other microservices
AnalyticsHelper.trackView(userId, 'post', postId);
AnalyticsHelper.trackEngagement(userId, 'like', 'post', postId);
AnalyticsHelper.trackPurchase(userId, purchaseData);
```

## Database Schema

### Analytics Events Table
```sql
CREATE TABLE analytics_events (
  id VARCHAR PRIMARY KEY,
  event_id VARCHAR UNIQUE,
  event_type VARCHAR,
  user_id VARCHAR,
  session_id VARCHAR,
  timestamp TIMESTAMP,
  schema_version VARCHAR,
  platform VARCHAR,
  user_agent VARCHAR,
  ip_address VARCHAR,
  event_data JSONB
);

-- Indexes for performance
CREATE INDEX idx_analytics_events_type_time ON analytics_events(event_type, timestamp);
CREATE INDEX idx_analytics_events_user_time ON analytics_events(user_id, timestamp);
```

### Aggregations Table
```sql
CREATE TABLE analytics_aggregations (
  id VARCHAR PRIMARY KEY,
  timeframe VARCHAR, -- hour, day, week, month
  event_type VARCHAR,
  timestamp TIMESTAMP,
  count INTEGER,
  metadata JSONB
);
```

## Event Schema Examples

### View Event
```json
{
  "eventId": "uuid",
  "eventType": "view",
  "userId": "user-123",
  "sessionId": "session-456",
  "timestamp": "2024-01-01T12:00:00Z",
  "schemaVersion": "1.1.0",
  "platform": "mobile",
  "data": {
    "contentType": "post",
    "contentId": "post-123",
    "viewDuration": 45,
    "scrollDepth": 0.8,
    "referrer": "feed"
  }
}
```

### Engagement Event
```json
{
  "eventType": "engagement",
  "data": {
    "action": "like",
    "targetType": "post",
    "targetId": "post-123",
    "metadata": {
      "previousState": "unliked",
      "source": "feed"
    }
  }
}
```

### Purchase Event
```json
{
  "eventType": "purchase",
  "data": {
    "productId": "product-456",
    "orderId": "order-789",
    "amount": 29.99,
    "currency": "USD",
    "quantity": 1,
    "paymentMethod": "wallet",
    "conversionPath": ["view", "add_to_cart", "purchase"]
  }
}
```

## Performance & Scalability

### Batch Processing
- Events queued in memory (10 events or 30 seconds)
- Batch inserts for improved database performance
- Automatic retry on failure

### Aggregations
- Hourly cron job for metric aggregation
- Pre-computed metrics for dashboard performance
- Time-series data optimization

### Data Retention
- Raw events: 90 days
- Hourly aggregations: 1 year
- Daily aggregations: 5 years

## Monitoring

### Health Checks
```bash
curl http://localhost:3006/events/health
```

### Metrics
- Event ingestion rate
- Processing latency
- Error rates
- Storage usage

### Alerts
- High error rates (>5%)
- Processing delays (>1 minute)
- Storage capacity (>80%)

## Deployment

### Docker
```bash
cd microservices
docker-compose up analytics-service
```

### Environment Variables
```env
PORT=3006
DATABASE_URL=postgresql://user:pass@postgres:5432/db
ANALYTICS_BATCH_SIZE=10
ANALYTICS_BATCH_INTERVAL=30000
```

### Service URLs
- **Analytics Service**: http://localhost:3006
- **Via API Gateway**: http://localhost:8080/analytics

## Schema Migration

### Version Compatibility
```typescript
const SCHEMA_VERSIONS = {
  '1.0.0': {
    view: ['contentType', 'contentId'],
    engagement: ['action', 'targetType', 'targetId'],
  },
  '1.1.0': {
    view: ['contentType', 'contentId', 'viewDuration', 'scrollDepth'],
    engagement: ['action', 'targetType', 'targetId', 'metadata'],
  },
};
```

### Migration Strategy
1. Deploy new schema version
2. Update client SDKs gradually
3. Maintain backward compatibility
4. Deprecate old versions after 90 days

## Privacy & Compliance

### Data Protection
- IP address hashing for privacy
- User consent tracking
- GDPR compliance features
- Data anonymization options

### Retention Policies
- Automatic data purging
- User data deletion on request
- Audit trail maintenance