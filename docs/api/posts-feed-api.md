# Posts & Feed API Documentation

## Overview
Complete API documentation for posts, feed management, and content discovery in the Social Live platform.

## Base URL
```
Production: https://api.sociallive.com
Staging: https://staging-api.sociallive.com
Development: http://localhost:3000
```

## Authentication
All endpoints require Bearer token authentication:
```http
Authorization: Bearer <access_token>
```

## Posts API

### Create Post
```http
POST /posts
Content-Type: application/json
Authorization: Bearer <access_token>

{
  "content": "This is my first post! #sociallive",
  "mediaUrl": "https://cdn.example.com/image.jpg",
  "mediaType": "IMAGE",
  "visibility": "PUBLIC",
  "tags": ["sociallive", "firstpost"],
  "location": "San Francisco, CA"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "post": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "userId": "user-uuid",
      "content": "This is my first post! #sociallive",
      "mediaUrl": "https://cdn.example.com/image.jpg",
      "mediaType": "IMAGE",
      "visibility": "PUBLIC",
      "likesCount": 0,
      "commentsCount": 0,
      "sharesCount": 0,
      "engagementScore": 0,
      "tags": ["sociallive", "firstpost"],
      "location": "San Francisco, CA",
      "createdAt": "2024-01-01T12:00:00Z",
      "updatedAt": "2024-01-01T12:00:00Z",
      "user": {
        "id": "user-uuid",
        "username": "johndoe",
        "fullName": "John Doe",
        "profilePicture": "https://cdn.example.com/profile.jpg"
      }
    }
  }
}
```

### Get Posts (Feed)
```http
GET /posts?page=1&limit=20&sort=recent
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20, max: 100)
- `sort` (optional): Sort order (`recent`, `popular`, `trending`)
- `userId` (optional): Filter by specific user
- `tags` (optional): Filter by tags (comma-separated)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": "post-uuid",
        "userId": "user-uuid",
        "content": "Amazing sunset today! 🌅",
        "mediaUrl": "https://cdn.example.com/sunset.jpg",
        "mediaType": "IMAGE",
        "visibility": "PUBLIC",
        "likesCount": 42,
        "commentsCount": 8,
        "sharesCount": 3,
        "engagementScore": 85.5,
        "tags": ["sunset", "nature"],
        "location": "Malibu, CA",
        "createdAt": "2024-01-01T18:30:00Z",
        "user": {
          "id": "user-uuid",
          "username": "photographer",
          "fullName": "Jane Smith",
          "profilePicture": "https://cdn.example.com/jane.jpg",
          "isVerified": true
        },
        "isLiked": false,
        "isSaved": false
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 150,
      "totalPages": 8,
      "hasNext": true,
      "hasPrev": false
    }
  }
}
```

### Get Single Post
```http
GET /posts/{postId}
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "post": {
      "id": "post-uuid",
      "userId": "user-uuid",
      "content": "Detailed post content...",
      "mediaUrl": "https://cdn.example.com/image.jpg",
      "mediaType": "IMAGE",
      "visibility": "PUBLIC",
      "likesCount": 42,
      "commentsCount": 8,
      "sharesCount": 3,
      "engagementScore": 85.5,
      "tags": ["tag1", "tag2"],
      "location": "Location",
      "createdAt": "2024-01-01T12:00:00Z",
      "updatedAt": "2024-01-01T12:00:00Z",
      "user": {
        "id": "user-uuid",
        "username": "johndoe",
        "fullName": "John Doe",
        "profilePicture": "https://cdn.example.com/profile.jpg",
        "isVerified": false
      },
      "isLiked": true,
      "isSaved": false,
      "comments": [
        {
          "id": "comment-uuid",
          "userId": "commenter-uuid",
          "content": "Great post!",
          "likesCount": 5,
          "createdAt": "2024-01-01T12:30:00Z",
          "user": {
            "username": "commenter",
            "profilePicture": "https://cdn.example.com/commenter.jpg"
          }
        }
      ]
    }
  }
}
```

### Update Post
```http
PUT /posts/{postId}
Content-Type: application/json
Authorization: Bearer <access_token>

{
  "content": "Updated post content",
  "visibility": "FOLLOWERS_ONLY",
  "tags": ["updated", "content"]
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "post": {
      "id": "post-uuid",
      "content": "Updated post content",
      "visibility": "FOLLOWERS_ONLY",
      "tags": ["updated", "content"],
      "updatedAt": "2024-01-01T13:00:00Z"
    }
  }
}
```

### Delete Post
```http
DELETE /posts/{postId}
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Post deleted successfully"
}
```

## Post Interactions

### Like Post
```http
POST /posts/{postId}/like
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "liked": true,
    "likesCount": 43
  }
}
```

### Unlike Post
```http
DELETE /posts/{postId}/like
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "liked": false,
    "likesCount": 42
  }
}
```

### Save Post
```http
POST /posts/{postId}/save
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "saved": true,
    "message": "Post saved to your collection"
  }
}
```

### Share Post
```http
POST /posts/{postId}/share
Content-Type: application/json
Authorization: Bearer <access_token>

{
  "platform": "twitter",
  "message": "Check out this amazing post!"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "shareUrl": "https://sociallive.com/posts/post-uuid",
    "sharesCount": 4
  }
}
```

## Comments API

### Get Comments
```http
GET /posts/{postId}/comments?page=1&limit=10
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "comments": [
      {
        "id": "comment-uuid",
        "postId": "post-uuid",
        "userId": "user-uuid",
        "content": "Great post! Love the content.",
        "likesCount": 5,
        "repliesCount": 2,
        "createdAt": "2024-01-01T12:30:00Z",
        "updatedAt": "2024-01-01T12:30:00Z",
        "user": {
          "id": "user-uuid",
          "username": "commenter",
          "fullName": "Comment Author",
          "profilePicture": "https://cdn.example.com/commenter.jpg"
        },
        "isLiked": false,
        "replies": [
          {
            "id": "reply-uuid",
            "content": "Thanks for the feedback!",
            "userId": "original-author-uuid",
            "createdAt": "2024-01-01T12:45:00Z",
            "user": {
              "username": "originalauthor",
              "profilePicture": "https://cdn.example.com/author.jpg"
            }
          }
        ]
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 25,
      "totalPages": 3,
      "hasNext": true,
      "hasPrev": false
    }
  }
}
```

### Create Comment
```http
POST /posts/{postId}/comments
Content-Type: application/json
Authorization: Bearer <access_token>

{
  "content": "This is an amazing post! Thanks for sharing.",
  "parentId": null
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "comment": {
      "id": "new-comment-uuid",
      "postId": "post-uuid",
      "userId": "user-uuid",
      "content": "This is an amazing post! Thanks for sharing.",
      "parentId": null,
      "likesCount": 0,
      "repliesCount": 0,
      "createdAt": "2024-01-01T13:00:00Z",
      "user": {
        "id": "user-uuid",
        "username": "commenter",
        "fullName": "Comment Author",
        "profilePicture": "https://cdn.example.com/commenter.jpg"
      }
    }
  }
}
```

### Reply to Comment
```http
POST /posts/{postId}/comments
Content-Type: application/json
Authorization: Bearer <access_token>

{
  "content": "Thanks for your comment!",
  "parentId": "parent-comment-uuid"
}
```

## Feed API

### Get Personalized Feed
```http
GET /feed?page=1&limit=20&algorithm=ml
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20, max: 50)
- `algorithm` (optional): Feed algorithm (`ml`, `chronological`, `popular`)
- `refresh` (optional): Force refresh feed cache

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "feedItems": [
      {
        "id": "feed-item-uuid",
        "postId": "post-uuid",
        "score": 95.5,
        "reason": "high_engagement",
        "post": {
          "id": "post-uuid",
          "userId": "user-uuid",
          "content": "Trending post content...",
          "mediaUrl": "https://cdn.example.com/trending.jpg",
          "mediaType": "IMAGE",
          "likesCount": 150,
          "commentsCount": 25,
          "sharesCount": 12,
          "engagementScore": 95.5,
          "createdAt": "2024-01-01T10:00:00Z",
          "user": {
            "id": "user-uuid",
            "username": "trendinguser",
            "fullName": "Trending User",
            "profilePicture": "https://cdn.example.com/trending-user.jpg",
            "isVerified": true
          },
          "isLiked": false,
          "isSaved": true
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "hasNext": true,
      "nextCursor": "eyJzY29yZSI6OTUuNSwiaWQiOiJwb3N0LXV1aWQifQ=="
    },
    "metadata": {
      "algorithm": "ml",
      "generatedAt": "2024-01-01T14:00:00Z",
      "totalItems": 500,
      "refreshedAt": "2024-01-01T14:00:00Z"
    }
  }
}
```

### Get Following Feed
```http
GET /feed/following?page=1&limit=20
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": "post-uuid",
        "userId": "following-user-uuid",
        "content": "Post from someone you follow...",
        "createdAt": "2024-01-01T12:00:00Z",
        "user": {
          "username": "followeduser",
          "fullName": "Followed User",
          "profilePicture": "https://cdn.example.com/followed.jpg"
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 50,
      "hasNext": true
    }
  }
}
```

### Get Trending Posts
```http
GET /feed/trending?timeframe=24h&category=all
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `timeframe`: `1h`, `6h`, `24h`, `7d` (default: 24h)
- `category`: `all`, `technology`, `sports`, `entertainment`, etc.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "trendingPosts": [
      {
        "id": "trending-post-uuid",
        "content": "Viral content that's trending...",
        "engagementScore": 98.7,
        "trendingRank": 1,
        "velocityScore": 85.2,
        "user": {
          "username": "viraluser",
          "isVerified": true
        }
      }
    ],
    "metadata": {
      "timeframe": "24h",
      "category": "all",
      "generatedAt": "2024-01-01T14:00:00Z"
    }
  }
}
```

## Search API

### Search Posts
```http
GET /search/posts?q=nature&page=1&limit=20&sort=relevance
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `q`: Search query (required)
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20, max: 50)
- `sort`: `relevance`, `recent`, `popular`
- `mediaType`: Filter by media type
- `dateRange`: `today`, `week`, `month`, `year`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": "search-result-uuid",
        "content": "Beautiful nature photography...",
        "relevanceScore": 0.95,
        "matchedTerms": ["nature", "photography"],
        "user": {
          "username": "naturelover",
          "profilePicture": "https://cdn.example.com/nature.jpg"
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 1250,
      "totalPages": 63
    },
    "metadata": {
      "query": "nature",
      "searchTime": "0.045s",
      "suggestions": ["nature photography", "natural beauty"]
    }
  }
}
```

### Search Users
```http
GET /search/users?q=john&page=1&limit=10
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "user-uuid",
        "username": "johndoe",
        "fullName": "John Doe",
        "bio": "Software developer and photographer",
        "profilePicture": "https://cdn.example.com/john.jpg",
        "followersCount": 1250,
        "postsCount": 89,
        "isVerified": false,
        "isFollowing": false
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 45
    }
  }
}
```

## Analytics API

### Get Post Analytics
```http
GET /posts/{postId}/analytics
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "analytics": {
      "postId": "post-uuid",
      "impressions": 5420,
      "reach": 4180,
      "engagements": 342,
      "engagementRate": 0.082,
      "likes": 245,
      "comments": 67,
      "shares": 30,
      "saves": 89,
      "clicks": 156,
      "demographics": {
        "ageGroups": {
          "18-24": 0.35,
          "25-34": 0.42,
          "35-44": 0.18,
          "45+": 0.05
        },
        "genders": {
          "male": 0.48,
          "female": 0.51,
          "other": 0.01
        }
      },
      "timeSeriesData": [
        {
          "timestamp": "2024-01-01T00:00:00Z",
          "impressions": 120,
          "engagements": 8
        }
      ]
    }
  }
}
```

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "error": "VALIDATION_ERROR",
  "message": "Invalid request data",
  "details": [
    {
      "field": "content",
      "message": "Content cannot be empty"
    },
    {
      "field": "mediaType",
      "message": "Invalid media type"
    }
  ]
}
```

### 403 Forbidden
```json
{
  "success": false,
  "error": "FORBIDDEN",
  "message": "You don't have permission to access this post"
}
```

### 404 Not Found
```json
{
  "success": false,
  "error": "NOT_FOUND",
  "message": "Post not found"
}
```

### 429 Too Many Requests
```json
{
  "success": false,
  "error": "RATE_LIMIT_EXCEEDED",
  "message": "Too many requests",
  "retryAfter": 60,
  "limit": 100,
  "remaining": 0,
  "resetTime": "2024-01-01T15:00:00Z"
}
```

## Rate Limits

### Post Creation
- **Limit**: 10 posts per hour per user
- **Burst**: 3 posts per minute

### Feed Requests
- **Limit**: 100 requests per hour per user
- **Burst**: 20 requests per minute

### Search Requests
- **Limit**: 50 requests per hour per user
- **Burst**: 10 requests per minute

## Webhooks

### Post Events
```http
POST https://your-app.com/webhooks/posts
Content-Type: application/json
X-Signature: sha256=...

{
  "event": "post.created",
  "timestamp": "2024-01-01T12:00:00Z",
  "data": {
    "postId": "post-uuid",
    "userId": "user-uuid",
    "content": "New post content..."
  }
}
```

**Available Events:**
- `post.created`
- `post.updated`
- `post.deleted`
- `post.liked`
- `post.commented`
- `post.shared`

## SDK Examples

### JavaScript/TypeScript
```typescript
import { SocialLiveAPI } from '@sociallive/sdk';

const api = new SocialLiveAPI({
  baseURL: 'https://api.sociallive.com',
  accessToken: 'your-access-token'
});

// Create post
const post = await api.posts.create({
  content: 'Hello, Social Live!',
  mediaUrl: 'https://example.com/image.jpg',
  mediaType: 'IMAGE'
});

// Get feed
const feed = await api.feed.get({
  page: 1,
  limit: 20,
  algorithm: 'ml'
});

// Like post
await api.posts.like(postId);
```

### Flutter/Dart
```dart
import 'package:social_live_sdk/social_live_sdk.dart';

final api = SocialLiveAPI(
  baseUrl: 'https://api.sociallive.com',
  accessToken: 'your-access-token',
);

// Create post
final post = await api.posts.create(CreatePostRequest(
  content: 'Hello from Flutter!',
  mediaUrl: 'https://example.com/image.jpg',
  mediaType: MediaType.image,
));

// Get feed
final feed = await api.feed.get(FeedRequest(
  page: 1,
  limit: 20,
  algorithm: FeedAlgorithm.ml,
));
```

## Testing

### Test Data
Use these test accounts for API testing:
```json
{
  "testUser1": {
    "email": "testuser1@example.com",
    "password": "TestPass123!",
    "userId": "test-user-1-uuid"
  },
  "testUser2": {
    "email": "testuser2@example.com",
    "password": "TestPass123!",
    "userId": "test-user-2-uuid"
  }
}
```

### Postman Collection
Download the complete API collection: [Posts & Feed API Collection](./assets/posts-feed-api.postman_collection.json)