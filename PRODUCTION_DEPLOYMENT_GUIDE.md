# Production Deployment Guide

## Overview

This guide covers deploying the Social Live app to production with real data, real services, and production-grade infrastructure.

## Prerequisites

### Required Services

1. **AWS Account**
   - S3 for video/image storage
   - CloudFront for CDN
   - RDS for PostgreSQL database
   - EC2 or ECS for hosting
   - MediaConvert for video transcoding

2. **Stripe Account**
   - Payment processing
   - Customer management
   - Subscription handling

3. **Domain & SSL**
   - Custom domain
   - SSL certificate (AWS Certificate Manager)

4. **Monitoring & Logging**
   - Sentry for error tracking
   - CloudWatch for logs
   - DataDog/New Relic (optional)

## Step 1: Database Setup

### Migrate from SQLite to PostgreSQL

```bash
# 1. Install PostgreSQL locally or use AWS RDS
# 2. Update DATABASE_URL in .env

DATABASE_URL="postgresql://username:password@host:5432/sociallive_prod"

# 3. Run migrations
cd social-live-mvp
npx prisma migrate deploy

# 4. Seed production data
npm run seed:production
```

### Database Schema Updates

```prisma
// Add to schema.prisma for production features

model Video {
  id              String   @id @default(cuid())
  userId          String
  title           String
  description     String
  originalUrl     String   // S3 URL
  hdUrl           String?  // 1080p
  sdUrl           String?  // 720p
  mobileUrl       String?  // 480p
  thumbnailUrl    String
  duration        Int
  fileSize        BigInt
  processingStatus String  @default("pending")
  moderationStatus String  @default("pending")
  views           Int      @default(0)
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt

  user User @relation(fields: [userId], references: [id])
  
  @@index([userId])
  @@index([processingStatus])
  @@index([moderationStatus])
  @@index([createdAt])
}
```

## Step 2: AWS S3 & CloudFront Setup

### Create S3 Buckets

```bash
# Create buckets
aws s3 mb s3://sociallive-videos-prod --region us-east-1
aws s3 mb s3://sociallive-images-prod --region us-east-1

# Set bucket policies
aws s3api put-bucket-policy --bucket sociallive-videos-prod --policy file://s3-policy.json

# Enable CORS
aws s3api put-bucket-cors --bucket sociallive-videos-prod --cors-configuration file://cors-config.json
```

### S3 Bucket Policy (s3-policy.json)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::sociallive-videos-prod/*"
    }
  ]
}
```

### CORS Configuration (cors-config.json)

```json
{
  "CORSRules": [
    {
      "AllowedOrigins": ["https://sociallive.app", "https://www.sociallive.app"],
      "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
      "AllowedHeaders": ["*"],
      "MaxAgeSeconds": 3000
    }
  ]
}
```

### CloudFront Distribution

```bash
# Create CloudFront distribution
aws cloudfront create-distribution --distribution-config file://cloudfront-config.json
```

### CloudFront Config (cloudfront-config.json)

```json
{
  "CallerReference": "sociallive-videos-2024",
  "Comment": "Social Live Video CDN",
  "Enabled": true,
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-sociallive-videos-prod",
        "DomainName": "sociallive-videos-prod.s3.amazonaws.com",
        "S3OriginConfig": {
          "OriginAccessIdentity": ""
        }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-sociallive-videos-prod",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 2,
      "Items": ["GET", "HEAD"]
    },
    "Compress": true,
    "MinTTL": 0,
    "DefaultTTL": 86400,
    "MaxTTL": 31536000
  }
}
```

## Step 3: Stripe Integration

### Setup Stripe

```bash
# Install Stripe CLI
brew install stripe/stripe-cli/stripe

# Login to Stripe
stripe login

# Get API keys
stripe keys list
```

### Environment Variables

```env
# Stripe Keys
STRIPE_SECRET_KEY=sk_live_xxxxxxxxxxxxx
STRIPE_PUBLISHABLE_KEY=pk_live_xxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx
```

### Webhook Setup

```bash
# Create webhook endpoint
stripe listen --forward-to localhost:3000/api/webhooks/stripe

# In production, set webhook URL in Stripe Dashboard:
# https://api.sociallive.app/api/webhooks/stripe
```

## Step 4: Video Transcoding with AWS MediaConvert

### Create MediaConvert Job Template

```typescript
// social-live-mvp/src/video/media-convert.service.ts

import { MediaConvert } from '@aws-sdk/client-mediaconvert';

export class MediaConvertService {
  private mediaConvert: MediaConvert;

  constructor() {
    this.mediaConvert = new MediaConvert({
      region: process.env.AWS_REGION,
      endpoint: process.env.MEDIACONVERT_ENDPOINT,
    });
  }

  async createTranscodingJob(inputKey: string, outputPrefix: string) {
    const params = {
      Role: process.env.MEDIACONVERT_ROLE_ARN,
      Settings: {
        Inputs: [
          {
            FileInput: `s3://sociallive-videos-prod/${inputKey}`,
          },
        ],
        OutputGroups: [
          {
            Name: 'File Group',
            OutputGroupSettings: {
              Type: 'FILE_GROUP_SETTINGS',
              FileGroupSettings: {
                Destination: `s3://sociallive-videos-prod/${outputPrefix}/`,
              },
            },
            Outputs: [
              // 1080p HD
              {
                VideoDescription: {
                  Width: 1080,
                  Height: 1920,
                  CodecSettings: {
                    Codec: 'H_264',
                    H264Settings: {
                      Bitrate: 2500000,
                    },
                  },
                },
                ContainerSettings: {
                  Container: 'MP4',
                },
                NameModifier: '_hd',
              },
              // 720p SD
              {
                VideoDescription: {
                  Width: 720,
                  Height: 1280,
                  CodecSettings: {
                    Codec: 'H_264',
                    H264Settings: {
                      Bitrate: 1500000,
                    },
                  },
                },
                ContainerSettings: {
                  Container: 'MP4',
                },
                NameModifier: '_sd',
              },
              // 480p Mobile
              {
                VideoDescription: {
                  Width: 480,
                  Height: 854,
                  CodecSettings: {
                    Codec: 'H_264',
                    H264Settings: {
                      Bitrate: 800000,
                    },
                  },
                },
                ContainerSettings: {
                  Container: 'MP4',
                },
                NameModifier: '_mobile',
              },
            ],
          },
        ],
      },
    };

    const job = await this.mediaConvert.createJob(params);
    return job.Job.Id;
  }
}
```

## Step 5: Content Moderation

### AWS Rekognition Integration

```typescript
// social-live-mvp/src/moderation/moderation.service.ts

import { Rekognition } from '@aws-sdk/client-rekognition';

export class ModerationService {
  private rekognition: Rekognition;

  constructor() {
    this.rekognition = new Rekognition({
      region: process.env.AWS_REGION,
    });
  }

  async moderateVideo(videoKey: string): Promise<boolean> {
    const params = {
      Video: {
        S3Object: {
          Bucket: 'sociallive-videos-prod',
          Name: videoKey,
        },
      },
      MinConfidence: 75,
    };

    const result = await this.rekognition.startContentModeration(params);
    
    // Poll for results
    const jobId = result.JobId;
    let jobStatus = 'IN_PROGRESS';
    
    while (jobStatus === 'IN_PROGRESS') {
      await new Promise(resolve => setTimeout(resolve, 5000));
      
      const status = await this.rekognition.getContentModeration({
        JobId: jobId,
      });
      
      jobStatus = status.JobStatus;
      
      if (jobStatus === 'SUCCEEDED') {
        const moderationLabels = status.ModerationLabels || [];
        
        // Check for inappropriate content
        const hasInappropriateContent = moderationLabels.some(
          label => label.ModerationLabel.Confidence > 75
        );
        
        return !hasInappropriateContent;
      }
    }
    
    return false;
  }
}
```

## Step 6: Environment Configuration

### Production .env File

```env
# Database
DATABASE_URL="postgresql://username:password@prod-db.amazonaws.com:5432/sociallive"

# AWS
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXXXXX
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
S3_BUCKET_NAME=sociallive-videos-prod
CLOUDFRONT_DOMAIN=cdn.sociallive.app
MEDIACONVERT_ENDPOINT=https://xxxxxxxx.mediaconvert.us-east-1.amazonaws.com
MEDIACONVERT_ROLE_ARN=arn:aws:iam::xxxxxxxxxxxx:role/MediaConvertRole

# Stripe
STRIPE_SECRET_KEY=sk_live_xxxxxxxxxxxxx
STRIPE_PUBLISHABLE_KEY=pk_live_xxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx

# App
NODE_ENV=production
PORT=3000
API_URL=https://api.sociallive.app
WEB_URL=https://sociallive.app

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=7d

# Redis (for caching)
REDIS_URL=redis://prod-redis.amazonaws.com:6379

# Sentry (error tracking)
SENTRY_DSN=https://xxxxxxxxxxxxx@sentry.io/xxxxxxxxxxxxx

# Email (SendGrid)
SENDGRID_API_KEY=SG.xxxxxxxxxxxxx
FROM_EMAIL=noreply@sociallive.app
```

## Step 7: Deploy Backend

### Docker Deployment

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npx prisma generate
RUN npm run build

EXPOSE 3000

CMD ["npm", "run", "start:prod"]
```

### Docker Compose (Production)

```yaml
version: '3.8'

services:
  api:
    build: ./social-live-mvp
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
      - STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}
    depends_on:
      - redis
    restart: always

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    restart: always

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - api
    restart: always

volumes:
  redis-data:
```

### Deploy to AWS ECS

```bash
# Build and push Docker image
docker build -t sociallive-api:latest ./social-live-mvp
docker tag sociallive-api:latest xxxxxxxxxxxx.dkr.ecr.us-east-1.amazonaws.com/sociallive-api:latest
docker push xxxxxxxxxxxx.dkr.ecr.us-east-1.amazonaws.com/sociallive-api:latest

# Update ECS service
aws ecs update-service --cluster sociallive-prod --service api --force-new-deployment
```

## Step 8: Deploy Flutter App

### Build for Production

```bash
cd social-live-flutter

# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Update API Endpoints

```dart
// lib/config/api_config.dart

class ApiConfig {
  static const String baseUrl = 'https://api.sociallive.app';
  static const String wsUrl = 'wss://api.sociallive.app';
  static const String cdnUrl = 'https://cdn.sociallive.app';
  
  static const String stripePublishableKey = 'pk_live_xxxxxxxxxxxxx';
}
```

## Step 9: Monitoring & Analytics

### Sentry Integration

```typescript
// social-live-mvp/src/main.ts

import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 1.0,
});
```

### CloudWatch Logs

```typescript
// social-live-mvp/src/logger/cloudwatch.logger.ts

import { CloudWatchLogs } from '@aws-sdk/client-cloudwatch-logs';

export class CloudWatchLogger {
  private cloudwatch: CloudWatchLogs;
  
  constructor() {
    this.cloudwatch = new CloudWatchLogs({
      region: process.env.AWS_REGION,
    });
  }
  
  async log(message: string, level: string) {
    await this.cloudwatch.putLogEvents({
      logGroupName: '/aws/sociallive/api',
      logStreamName: 'production',
      logEvents: [
        {
          message: JSON.stringify({ level, message, timestamp: Date.now() }),
          timestamp: Date.now(),
        },
      ],
    });
  }
}
```

## Step 10: Performance Optimization

### Enable Caching

```typescript
// social-live-mvp/src/cache/redis-cache.service.ts

import { Injectable } from '@nestjs/common';
import { Redis } from 'ioredis';

@Injectable()
export class RedisCacheService {
  private redis: Redis;

  constructor() {
    this.redis = new Redis(process.env.REDIS_URL);
  }

  async get<T>(key: string): Promise<T | null> {
    const data = await this.redis.get(key);
    return data ? JSON.parse(data) : null;
  }

  async set(key: string, value: any, ttl: number = 3600): Promise<void> {
    await this.redis.setex(key, ttl, JSON.stringify(value));
  }

  async del(key: string): Promise<void> {
    await this.redis.del(key);
  }
}
```

### CDN Configuration

- Enable gzip compression
- Set appropriate cache headers
- Use HTTP/2
- Enable CORS
- Configure SSL/TLS

## Step 11: Security Checklist

- [ ] Enable HTTPS everywhere
- [ ] Set up WAF (Web Application Firewall)
- [ ] Enable rate limiting
- [ ] Implement CORS properly
- [ ] Sanitize all user inputs
- [ ] Use parameterized queries (Prisma handles this)
- [ ] Enable SQL injection protection
- [ ] Set up DDoS protection (CloudFlare)
- [ ] Implement proper authentication
- [ ] Use secure password hashing (bcrypt)
- [ ] Enable 2FA for admin accounts
- [ ] Regular security audits
- [ ] Keep dependencies updated
- [ ] Implement proper error handling
- [ ] Don't expose sensitive data in errors

## Step 12: Launch Checklist

- [ ] Database migrated to PostgreSQL
- [ ] All environment variables configured
- [ ] AWS S3 and CloudFront set up
- [ ] Stripe integration tested
- [ ] Video transcoding working
- [ ] Content moderation enabled
- [ ] SSL certificates installed
- [ ] Domain configured
- [ ] Monitoring and logging active
- [ ] Error tracking (Sentry) configured
- [ ] Performance testing completed
- [ ] Security audit passed
- [ ] Backup strategy implemented
- [ ] Disaster recovery plan ready
- [ ] Documentation updated
- [ ] Team trained on production systems

## Maintenance

### Regular Tasks

1. **Daily**
   - Monitor error rates
   - Check system health
   - Review user feedback

2. **Weekly**
   - Review performance metrics
   - Check storage usage
   - Update dependencies

3. **Monthly**
   - Security audit
   - Cost optimization review
   - Backup verification

### Scaling Strategy

1. **Horizontal Scaling**
   - Add more API servers
   - Use load balancer
   - Implement auto-scaling

2. **Database Scaling**
   - Read replicas
   - Connection pooling
   - Query optimization

3. **CDN Optimization**
   - Multiple edge locations
   - Adaptive bitrate streaming
   - Image optimization

## Support

For production issues:
- Email: support@sociallive.app
- Slack: #production-alerts
- On-call: PagerDuty

## Conclusion

This production deployment ensures:
- ✅ Real data storage (PostgreSQL)
- ✅ Real video hosting (AWS S3/CloudFront)
- ✅ Real payments (Stripe)
- ✅ Real content moderation (AWS Rekognition)
- ✅ Production-grade security
- ✅ Scalable infrastructure
- ✅ Comprehensive monitoring
- ✅ Disaster recovery
