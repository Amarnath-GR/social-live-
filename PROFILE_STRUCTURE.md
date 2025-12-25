# Profile Screen Structure

## Visual Layout

```
┌─────────────────────────────────────┐
│  Profile                      [≡]   │  ← App Bar
├─────────────────────────────────────┤
│                                     │
│          ┌─────────┐                │
│          │   👤    │                │  ← Avatar
│          └─────────┘                │
│                                     │
│         @username ✓                 │  ← Username + Verified Badge
│      Content Creator                │  ← Bio
│                                     │
│   Following  Followers   Likes      │  ← Stats Row
│     234       12.5K      456K       │
│                                     │
│  ┌──────────────┐  ┌──────┐        │
│  │ Edit Profile │  │  📤  │        │  ← Action Buttons
│  └──────────────┘  └──────┘        │
│                                     │
│  ┌──────────────┐  ┌──────────────┐│
│  │ 📤 Upload    │  │ 📹 Go Live   ││  ← Upload/Live Buttons
│  └──────────────┘  └──────────────┘│
│                                     │
├─────────────────────────────────────┤
│  [Feed]  [Videos]  [Liked]          │  ← Tab Bar (Sticky)
├─────────────────────────────────────┤
│                                     │
│  ┌─────┐ ┌─────┐ ┌─────┐           │
│  │ 🎬  │ │ 🎬  │ │ 🎬  │           │  ← Video Grid
│  │ ▶️  │ │ ▶️  │ │ ▶️  │           │    (3 columns)
│  │1.2K │ │ 856 │ │2.5K │           │
│  └─────┘ └─────┘ └─────┘           │
│                                     │
│  ┌─────┐ ┌─────┐ ┌─────┐           │
│  │ 🎬  │ │ 🎬  │ │ 🎬  │           │
│  │ ▶️  │ │ ▶️  │ │ ▶️  │           │
│  │ 945 │ │3.1K │ │ 678 │           │
│  └─────┘ └─────┘ └─────┘           │
│                                     │
│         [Loading more...]           │  ← Infinite Scroll
│                                     │
└─────────────────────────────────────┘
```

## Video Thumbnail Detail

```
┌─────────────────┐
│ [0:30]          │  ← Duration badge (top-right)
│                 │
│   ┌─────────┐   │
│   │         │   │
│   │    ▶️   │   │  ← Play icon (centered)
│   │         │   │
│   └─────────┘   │
│                 │
│ 👁️ 1.2K  ❤️ 45 │  ← Views & Likes (bottom)
└─────────────────┘
```

## Component Hierarchy

```
EnhancedProfileScreen
├── AppBar
│   ├── Title (Username)
│   └── Menu Button
│
├── RefreshIndicator (Pull to refresh)
│   └── CustomScrollView
│       ├── SliverToBoxAdapter (Profile Header)
│       │   ├── Avatar
│       │   ├── Username + Verified Badge
│       │   ├── Bio
│       │   ├── Stats Row
│       │   │   ├── Following
│       │   │   ├── Followers
│       │   │   └── Likes
│       │   └── Action Buttons
│       │       ├── Edit Profile
│       │       ├── Share Profile
│       │       ├── Upload Video
│       │       └── Go Live
│       │
│       ├── SliverPersistentHeader (Sticky Tab Bar)
│       │   └── TabBar
│       │       ├── Feed Tab
│       │       ├── Videos Tab
│       │       └── Liked Tab
│       │
│       └── SliverFillRemaining (Tab Content)
│           └── TabBarView
│               ├── Feed Grid
│               │   └── VideoThumbnail (x N)
│               ├── Videos Grid
│               │   └── VideoThumbnail (x N)
│               └── Liked Grid
│                   └── VideoThumbnail (x N)
```

## Data Flow

```
┌─────────────────────────────────────────────┐
│           EnhancedProfileScreen             │
└─────────────────┬───────────────────────────┘
                  │
                  ├─── Load User Profile
                  │    └─→ GET /api/users/me
                  │
                  ├─── Load Feed Videos
                  │    └─→ GET /api/videos/feed
                  │
                  ├─── Load User Videos
                  │    └─→ GET /api/videos/my-videos
                  │
                  └─── Load Liked Videos
                       └─→ GET /api/videos/liked
                       
┌─────────────────────────────────────────────┐
│              Backend Response               │
└─────────────────┬───────────────────────────┘
                  │
                  ├─→ Parse JSON
                  │
                  ├─→ Create VideoModel objects
                  │
                  ├─→ Update State
                  │
                  └─→ Render Grid with Thumbnails
```

## State Management

```
State Variables:
├── userProfile: Map<String, dynamic>?
├── followingCount: int
├── followersCount: int
├── likesCount: int
├── feedVideos: List<VideoModel>
├── userVideos: List<VideoModel>
├── likedVideos: List<VideoModel>
├── isLoadingFeed: bool
├── isLoadingVideos: bool
├── isLoadingLiked: bool
├── feedPage: int
├── videosPage: int
└── likedPage: int
```

## User Interactions

```
User Action                  → Handler Method
─────────────────────────────────────────────
Tap Profile Tab              → Navigate to Profile
Switch Tab                   → TabController.animateTo()
Tap Video Thumbnail          → _playVideo()
Long Press Thumbnail         → _showVideoOptions()
Pull Down                    → _refreshProfile()
Scroll to Bottom             → _loadMore[Feed|Videos|Liked]()
Tap Edit Profile             → _showEditProfileDialog()
Tap Share                    → Share Profile
Tap Upload                   → Navigate to Camera
Tap Go Live                  → Navigate to Live Camera
Tap Menu                     → _showSettingsMenu()
```

## Tab Content States

### Empty State
```
┌─────────────────────────────────────┐
│                                     │
│           📹                        │
│                                     │
│       No videos yet                 │
│                                     │
│  Start creating content to          │
│       see it here                   │
│                                     │
└─────────────────────────────────────┘
```

### Loading State
```
┌─────────────────────────────────────┐
│                                     │
│  ┌─────┐ ┌─────┐ ┌─────┐           │
│  │ ... │ │ ... │ │ ... │           │
│  └─────┘ └─────┘ └─────┘           │
│                                     │
│           ⏳ Loading...             │
│                                     │
└─────────────────────────────────────┘
```

### Content State
```
┌─────────────────────────────────────┐
│  ┌─────┐ ┌─────┐ ┌─────┐           │
│  │ 🎬  │ │ 🎬  │ │ 🎬  │           │
│  │ ▶️  │ │ ▶️  │ │ ▶️  │           │
│  └─────┘ └─────┘ └─────┘           │
│                                     │
│  ┌─────┐ ┌─────┐ ┌─────┐           │
│  │ 🎬  │ │ 🎬  │ │ 🎬  │           │
│  │ ▶️  │ │ ▶️  │ │ ▶️  │           │
│  └─────┘ └─────┘ └─────┘           │
└─────────────────────────────────────┘
```

## Video Options Menu

```
┌─────────────────────────────────────┐
│                                     │
│  🗑️  Delete Video                   │
│                                     │
│  📤  Share                          │
│                                     │
│  ✏️  Edit Caption                   │
│                                     │
└─────────────────────────────────────┘
```

## Settings Menu

```
┌─────────────────────────────────────┐
│                                     │
│  ⚙️  Settings                       │
│                                     │
│  🔒  Privacy                        │
│                                     │
│  ❓  Help                           │
│                                     │
│  🚪  Logout                         │
│                                     │
└─────────────────────────────────────┘
```

## API Integration Points

### 1. Profile Load
```dart
GET /api/users/me
Headers: { Authorization: Bearer <token> }

Response: {
  id, username, name, avatar, verified, ...
}
```

### 2. Feed Videos
```dart
GET /api/videos/feed?page=1&limit=20
Headers: { Authorization: Bearer <token> }

Response: [
  { id, videoUrl, thumbnailUrl, duration, stats, ... }
]
```

### 3. User Videos
```dart
GET /api/videos/my-videos?page=1&limit=20
Headers: { Authorization: Bearer <token> }

Response: [
  { id, videoUrl, thumbnailUrl, duration, stats, ... }
]
```

### 4. Liked Videos
```dart
GET /api/videos/liked?page=1&limit=20
Headers: { Authorization: Bearer <token> }

Response: [
  { id, videoUrl, thumbnailUrl, duration, stats, ... }
]
```

## Performance Considerations

### Image Loading
- Uses `CachedNetworkImage` for efficient caching
- Placeholder shown during load
- Error widget for failed loads
- Images cached in memory and disk

### Pagination
- Loads 20 videos per page
- Automatic load on scroll to bottom
- Prevents duplicate loads with loading flags
- Smooth infinite scroll experience

### Memory Management
- Old images released from cache
- Video controllers disposed properly
- State cleaned up on dispose
- Efficient list rendering with GridView.builder

## Theme Colors

```dart
Primary:     Colors.purple
Accent:      Colors.deepPurple
Background:  Colors.black
Text:        Colors.white
Secondary:   Colors.grey[400]
Border:      Colors.grey[800]
```

## Responsive Design

### Grid Layout
- **Mobile**: 3 columns
- **Tablet**: Could be 4-5 columns
- **Desktop**: Could be 6+ columns

### Aspect Ratios
- **Video Thumbnails**: 0.6 (portrait)
- **Avatar**: 1.0 (square)
- **Buttons**: Auto height

## Accessibility

- Semantic labels on all interactive elements
- High contrast text on backgrounds
- Touch targets minimum 44x44 pixels
- Screen reader support
- Keyboard navigation support

## Summary

The profile screen is a complex, multi-layered component that:
- Displays user information and stats
- Shows three tabs of video content
- Loads thumbnails efficiently
- Supports infinite scrolling
- Integrates with backend APIs
- Provides rich user interactions
- Maintains good performance

All components work together to create a smooth, TikTok-style profile experience! 🎉
