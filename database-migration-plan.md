# Database Migration Plan: SQLite → Polyglot Persistence

## Current State
- Single SQLite database handling all data types
- No horizontal scaling capability
- All services compete for same connection pool

## Target Architecture (Per Your Proposal)
- **PostgreSQL**: Transactional data (users, orders, payments, wallet)
- **MongoDB**: Social data (posts, videos, engagements, feeds)
- **Redis**: Caching (sessions, like counts, trending data)

## Migration Strategy

### Phase 1: Add Redis Caching (Immediate)
```typescript
// Implement comprehensive caching
await redis.setex(`user:${userId}:session`, 3600, sessionData);
await redis.setex(`post:${postId}:likes`, 300, likeCount);
await redis.setex(`trending:products`, 900, trendingData);
```

### Phase 2: Split Social Data to MongoDB
```typescript
// Move posts, engagements, feeds to MongoDB
const socialDB = new MongoClient(process.env.MONGODB_URL);
await socialDB.collection('posts').createIndex({ userId: 1, createdAt: -1 });
await socialDB.collection('engagements').createIndex({ postId: 1, timestamp: -1 });
```

### Phase 3: Keep Financial Data in PostgreSQL
```typescript
// Keep wallet, payments, orders in PostgreSQL for ACID compliance
const financialDB = new Pool({ connectionString: process.env.POSTGRESQL_URL });
```

## Performance Impact
- **Before**: 1 database handling 10M+ operations/day
- **After**: 3 specialized databases, each optimized for its data type
- **Expected**: 10x performance improvement