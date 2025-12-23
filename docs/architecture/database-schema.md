# Database Schema Documentation

## Overview
PostgreSQL database schema for the Social Live platform with comprehensive user management, content system, and analytics tracking.

## Entity Relationship Diagram

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    Users    │    │    Posts    │    │  Comments   │
│             │    │             │    │             │
│ id (PK)     │◄──┤ user_id (FK)│◄──┤ post_id (FK)│
│ email       │    │ id (PK)     │    │ user_id (FK)│
│ username    │    │ content     │    │ content     │
│ role        │    │ media_url   │    │ created_at  │
│ created_at  │    │ created_at  │    └─────────────┘
└─────────────┘    └─────────────┘           │
       │                   │                │
       │                   │                │
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Followers  │    │ Feed_Items  │    │ User_Engage │
│             │    │             │    │             │
│ follower_id │    │ user_id (FK)│    │ user_id (FK)│
│ following_id│    │ post_id (FK)│    │ post_id (FK)│
│ created_at  │    │ score       │    │ type        │
└─────────────┘    │ created_at  │    │ created_at  │
                   └─────────────┘    └─────────────┘
```

## Core Tables

### Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    bio TEXT,
    profile_picture VARCHAR(500),
    role user_role DEFAULT 'USER',
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    posts_count INTEGER DEFAULT 0,
    last_login_at TIMESTAMP,
    email_verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_active ON users(is_active) WHERE is_active = TRUE;
```

**Field Descriptions:**
- `id`: Unique identifier (UUID)
- `email`: User's email address (unique, required)
- `username`: Display username (unique, required)
- `password_hash`: bcrypt hashed password
- `role`: User role (USER, CREATOR, ADMIN)
- `is_verified`: Email verification status
- `followers_count`: Cached follower count
- `posts_count`: Cached post count

### Posts Table
```sql
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    media_url VARCHAR(500),
    media_type media_type_enum,
    visibility visibility_enum DEFAULT 'PUBLIC',
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    engagement_score DECIMAL(10,2) DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    tags TEXT[],
    location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Indexes
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_posts_engagement ON posts(engagement_score DESC);
CREATE INDEX idx_posts_visibility ON posts(visibility);
CREATE INDEX idx_posts_featured ON posts(is_featured) WHERE is_featured = TRUE;
CREATE INDEX idx_posts_tags ON posts USING GIN(tags);
```

**Field Descriptions:**
- `id`: Unique post identifier
- `user_id`: Reference to post author
- `content`: Post text content
- `media_url`: URL to attached media
- `media_type`: IMAGE, VIDEO, AUDIO
- `visibility`: PUBLIC, PRIVATE, FOLLOWERS_ONLY
- `engagement_score`: ML-calculated engagement score

### Comments Table
```sql
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    likes_count INTEGER DEFAULT 0,
    replies_count INTEGER DEFAULT 0,
    is_edited BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Indexes
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_comments_parent_id ON comments(parent_id);
CREATE INDEX idx_comments_created_at ON comments(created_at DESC);
```

### User Relationships (Followers)
```sql
CREATE TABLE user_followers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(follower_id, following_id),
    CHECK (follower_id != following_id)
);

-- Indexes
CREATE INDEX idx_followers_follower_id ON user_followers(follower_id);
CREATE INDEX idx_followers_following_id ON user_followers(following_id);
CREATE UNIQUE INDEX idx_followers_unique ON user_followers(follower_id, following_id);
```

## Engagement & Analytics

### User Engagement Table
```sql
CREATE TABLE user_engagement (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    engagement_type engagement_type_enum NOT NULL,
    value DECIMAL(5,2) DEFAULT 1.0,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, post_id, engagement_type)
);

-- Indexes
CREATE INDEX idx_engagement_user_id ON user_engagement(user_id);
CREATE INDEX idx_engagement_post_id ON user_engagement(post_id);
CREATE INDEX idx_engagement_type ON user_engagement(engagement_type);
CREATE INDEX idx_engagement_created_at ON user_engagement(created_at);
CREATE INDEX idx_engagement_metadata ON user_engagement USING GIN(metadata);
```

**Engagement Types:**
- `LIKE`: User liked the post
- `SHARE`: User shared the post
- `COMMENT`: User commented on the post
- `VIEW`: User viewed the post
- `CLICK`: User clicked on post media
- `SAVE`: User saved the post

### Feed Items Table
```sql
CREATE TABLE feed_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    score DECIMAL(10,4) NOT NULL,
    reason VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    UNIQUE(user_id, post_id)
);

-- Indexes
CREATE INDEX idx_feed_user_score ON feed_items(user_id, score DESC);
CREATE INDEX idx_feed_created_at ON feed_items(created_at DESC);
CREATE INDEX idx_feed_expires_at ON feed_items(expires_at);
```

## Authentication & Sessions

### User Sessions Table
```sql
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    refresh_token_hash VARCHAR(255) NOT NULL,
    device_info JSONB,
    ip_address INET,
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_sessions_token_hash ON user_sessions(refresh_token_hash);
CREATE INDEX idx_sessions_expires_at ON user_sessions(expires_at);
CREATE INDEX idx_sessions_active ON user_sessions(is_active) WHERE is_active = TRUE;
```

### Password Reset Tokens
```sql
CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_reset_tokens_user_id ON password_reset_tokens(user_id);
CREATE INDEX idx_reset_tokens_hash ON password_reset_tokens(token_hash);
CREATE INDEX idx_reset_tokens_expires ON password_reset_tokens(expires_at);
```

## Content Management

### Media Files Table
```sql
CREATE TABLE media_files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    original_name VARCHAR(255),
    mime_type VARCHAR(100),
    file_size BIGINT,
    width INTEGER,
    height INTEGER,
    duration INTEGER, -- for videos/audio in seconds
    storage_path VARCHAR(500) NOT NULL,
    cdn_url VARCHAR(500),
    processing_status processing_status_enum DEFAULT 'PENDING',
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_media_user_id ON media_files(user_id);
CREATE INDEX idx_media_status ON media_files(processing_status);
CREATE INDEX idx_media_created_at ON media_files(created_at DESC);
```

### Content Moderation
```sql
CREATE TABLE content_moderation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_type content_type_enum NOT NULL,
    content_id UUID NOT NULL,
    moderator_id UUID REFERENCES users(id),
    status moderation_status_enum DEFAULT 'PENDING',
    reason TEXT,
    automated_score DECIMAL(3,2),
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_moderation_content ON content_moderation(content_type, content_id);
CREATE INDEX idx_moderation_status ON content_moderation(status);
CREATE INDEX idx_moderation_moderator ON content_moderation(moderator_id);
```

## Analytics & Reporting

### User Analytics Table
```sql
CREATE TABLE user_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    profile_views INTEGER DEFAULT 0,
    post_impressions INTEGER DEFAULT 0,
    post_engagements INTEGER DEFAULT 0,
    followers_gained INTEGER DEFAULT 0,
    followers_lost INTEGER DEFAULT 0,
    total_likes INTEGER DEFAULT 0,
    total_comments INTEGER DEFAULT 0,
    total_shares INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, date)
);

-- Indexes
CREATE INDEX idx_analytics_user_date ON user_analytics(user_id, date DESC);
CREATE INDEX idx_analytics_date ON user_analytics(date);
```

### System Metrics Table
```sql
CREATE TABLE system_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15,4) NOT NULL,
    tags JSONB,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_metrics_name_time ON system_metrics(metric_name, timestamp DESC);
CREATE INDEX idx_metrics_tags ON system_metrics USING GIN(tags);
```

## Enums and Custom Types

### User Role Enum
```sql
CREATE TYPE user_role AS ENUM ('USER', 'CREATOR', 'MODERATOR', 'ADMIN');
```

### Media Type Enum
```sql
CREATE TYPE media_type_enum AS ENUM ('IMAGE', 'VIDEO', 'AUDIO', 'DOCUMENT');
```

### Visibility Enum
```sql
CREATE TYPE visibility_enum AS ENUM ('PUBLIC', 'PRIVATE', 'FOLLOWERS_ONLY', 'UNLISTED');
```

### Engagement Type Enum
```sql
CREATE TYPE engagement_type_enum AS ENUM ('LIKE', 'SHARE', 'COMMENT', 'VIEW', 'CLICK', 'SAVE');
```

### Processing Status Enum
```sql
CREATE TYPE processing_status_enum AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED');
```

### Moderation Status Enum
```sql
CREATE TYPE moderation_status_enum AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'FLAGGED');
```

### Content Type Enum
```sql
CREATE TYPE content_type_enum AS ENUM ('POST', 'COMMENT', 'USER_PROFILE', 'MEDIA');
```

## Database Functions & Triggers

### Update Timestamps Trigger
```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Update Counter Triggers
```sql
-- Update post counts when posts are created/deleted
CREATE OR REPLACE FUNCTION update_user_posts_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE users SET posts_count = posts_count + 1 WHERE id = NEW.user_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE users SET posts_count = posts_count - 1 WHERE id = OLD.user_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER posts_count_trigger
    AFTER INSERT OR DELETE ON posts
    FOR EACH ROW EXECUTE FUNCTION update_user_posts_count();
```

### Follower Count Triggers
```sql
CREATE OR REPLACE FUNCTION update_follower_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE users SET followers_count = followers_count + 1 WHERE id = NEW.following_id;
        UPDATE users SET following_count = following_count + 1 WHERE id = NEW.follower_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE users SET followers_count = followers_count - 1 WHERE id = OLD.following_id;
        UPDATE users SET following_count = following_count - 1 WHERE id = OLD.follower_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER follower_count_trigger
    AFTER INSERT OR DELETE ON user_followers
    FOR EACH ROW EXECUTE FUNCTION update_follower_counts();
```

## Performance Optimization

### Partitioning Strategy
```sql
-- Partition user_engagement by month
CREATE TABLE user_engagement_2024_01 PARTITION OF user_engagement
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE user_engagement_2024_02 PARTITION OF user_engagement
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
```

### Materialized Views
```sql
-- Popular posts view
CREATE MATERIALIZED VIEW popular_posts AS
SELECT 
    p.id,
    p.user_id,
    p.content,
    p.likes_count,
    p.comments_count,
    p.engagement_score,
    u.username,
    u.profile_picture
FROM posts p
JOIN users u ON p.user_id = u.id
WHERE p.created_at > CURRENT_DATE - INTERVAL '7 days'
    AND p.visibility = 'PUBLIC'
    AND p.deleted_at IS NULL
ORDER BY p.engagement_score DESC
LIMIT 1000;

-- Refresh schedule
CREATE INDEX idx_popular_posts_score ON popular_posts(engagement_score DESC);
```

## Data Retention Policies

### Cleanup Procedures
```sql
-- Clean up old sessions (older than 30 days)
DELETE FROM user_sessions 
WHERE expires_at < CURRENT_TIMESTAMP - INTERVAL '30 days';

-- Archive old engagement data (older than 1 year)
INSERT INTO user_engagement_archive 
SELECT * FROM user_engagement 
WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '1 year';

DELETE FROM user_engagement 
WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '1 year';
```

## Backup & Recovery

### Backup Strategy
```bash
# Full backup
pg_dump -h localhost -U postgres -d sociallive_prod > backup_full_$(date +%Y%m%d).sql

# Schema-only backup
pg_dump -h localhost -U postgres -d sociallive_prod --schema-only > backup_schema_$(date +%Y%m%d).sql

# Data-only backup
pg_dump -h localhost -U postgres -d sociallive_prod --data-only > backup_data_$(date +%Y%m%d).sql
```

### Point-in-Time Recovery
```bash
# Restore to specific timestamp
pg_restore -h localhost -U postgres -d sociallive_prod_restore \
    --clean --if-exists backup_full_20240101.sql
```

## Security Considerations

### Row Level Security
```sql
-- Enable RLS on sensitive tables
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;

-- Users can only see their own sessions
CREATE POLICY user_sessions_policy ON user_sessions
    FOR ALL TO authenticated_users
    USING (user_id = current_user_id());
```

### Data Encryption
- **Passwords**: bcrypt with salt rounds 12
- **Tokens**: SHA-256 hashed before storage
- **PII**: Consider encryption at rest for sensitive fields
- **Database**: Enable TLS for all connections

### Audit Trail
```sql
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(50) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    user_id UUID,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```