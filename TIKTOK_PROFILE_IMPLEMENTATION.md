# TikTok-Like User Profile Implementation

## Features Added

### 1. Enhanced User Model
- Added `bio` field for user biography
- Added `followersCount` and `followingCount` fields
- Added `isFollowing` field to track follow status
- Extended UserStats to include followers and following counts

### 2. Follow System
- Follow/Unfollow functionality
- Followers list
- Following list
- Follow counts displayed on profile

### 3. Profile Screen Enhancements
**Main Profile Screen (Current User)**
- TikTok-style header with avatar and username
- Stats row: Posts, Followers, Following, Likes
- Edit Profile and Share Profile buttons
- Tabbed interface:
  - Posts Grid: 3-column grid of user's posts
  - Menu Tab: Wallet, Verifications, Settings, Orders, Transactions

**User Profile Screen (Other Users)**
- Same layout as main profile
- Follow/Unfollow button instead of Edit Profile
- Message button
- View user's posts in grid format

### 4. Backend Endpoints

#### User Profile
- `GET /api/v1/users/me` - Get current user profile
- `GET /api/v1/users/:id` - Get user by ID
- `PUT /api/v1/users/me` - Update profile (name, username, bio, avatar)

#### Follow System
- `POST /api/v1/users/:id/follow` - Follow a user
- `POST /api/v1/users/:id/unfollow` - Unfollow a user
- `GET /api/v1/users/:id/followers` - Get user's followers (paginated)
- `GET /api/v1/users/:id/following` - Get users being followed (paginated)

#### Posts
- `GET /api/v1/posts/user/:userId` - Get user's posts (paginated)

### 5. Database Schema Updates

Added Follow model:
```prisma
model Follow {
  id          String   @id @default(cuid())
  followerId  String
  followingId String
  createdAt   DateTime @default(now())

  follower  User @relation("UserFollowing", fields: [followerId], references: [id])
  following User @relation("UserFollowers", fields: [followingId], references: [id])

  @@unique([followerId, followingId])
  @@index([followerId])
  @@index([followingId])
}
```

Updated User model:
- Added `bio` field
- Added `followers` and `following` relations

## Files Created/Modified

### Flutter (Client)
1. **Created**: `lib/screens/user_profile_screen.dart` - TikTok-like profile for viewing other users
2. **Modified**: `lib/screens/profile_screen.dart` - Enhanced with tabs and posts grid
3. **Modified**: `lib/models/user_models.dart` - Added bio, followers, following fields
4. **Modified**: `lib/services/profile_service.dart` - Added follow/unfollow, followers/following methods

### Backend (Server)
1. **Modified**: `src/users/users.controller.ts` - Added follow endpoints
2. **Modified**: `src/users/users.service.ts` - Added follow/unfollow logic
3. **Modified**: `prisma/schema.prisma` - Added Follow model and bio field

## Migration Required

Run the following command to apply database changes:
```bash
cd social-live-mvp
npx prisma migrate dev --name add_follow_system
npx prisma generate
```

## Usage

### View Current User Profile
Navigate to Profile tab in the app - shows your own profile with edit options.

### View Another User's Profile
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => UserProfileScreen(
      userId: 'user-id',
      isCurrentUser: false,
    ),
  ),
);
```

### Follow/Unfollow
Click the Follow/Following button on any user's profile.

### View Followers/Following
Tap on the Followers or Following count to see the list.

## UI Components

### Profile Header
- Circular avatar (45px radius)
- Username as title
- Name and bio below avatar
- Stats row with Posts, Followers, Following, Likes

### Action Buttons
**Current User:**
- Edit Profile
- Share Profile

**Other Users:**
- Follow/Following (toggles)
- Message

### Tabs
1. **Posts Tab**: 3-column grid of video thumbnails
2. **Menu Tab** (current user only): Settings, wallet, orders, etc.

## API Response Formats

### User Profile
```json
{
  "success": true,
  "data": {
    "id": "user-id",
    "username": "username",
    "name": "User Name",
    "avatar": "url",
    "bio": "User bio",
    "followersCount": 100,
    "followingCount": 50,
    "isFollowing": false,
    "_count": {
      "posts": 25,
      "likes": 500,
      "comments": 150
    }
  }
}
```

### Followers/Following List
```json
{
  "success": true,
  "data": {
    "users": [...],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "pages": 5
    }
  }
}
```
