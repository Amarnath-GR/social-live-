# TikTok-Style Video Platform - AWS Architecture

## 1. AWS Architecture

### Core Services

```
┌─────────────────────────────────────────────────────────────┐
│                     CloudFront CDN                          │
│  (Global content delivery for videos & thumbnails)         │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway (REST/GraphQL)               │
│  (Rate limiting, authentication, request routing)          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    Lambda Functions                         │
│  - Upload video                                             │
│  - Get feed                                                 │
│  - Like/Comment/Share                                       │
│  - Generate thumbnails                                      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────┬──────────────────┬──────────────────────┐
│   S3 Buckets     │   DynamoDB       │   ElastiCache        │
│  - Videos        │  - Posts         │  (Redis)             │
│  - Thumbnails    │  - Likes         │  - Feed cache        │
│  - Originals     │  - Comments      │  - Like counts       │
└──────────────────┴──────────────────┴──────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│              MediaConvert (Video Processing)                │
│  - Transcode to multiple resolutions                        │
│  - Generate thumbnails automatically                        │
│  - HLS/DASH streaming formats                               │
└─────────────────────────────────────────────────────────────┘
```

### Detailed Architecture

**1. Video Upload Flow:**
```
Mobile App → API Gateway → Lambda (Get Presigned URL) → S3 Upload
→ S3 Event → Lambda → MediaConvert → Transcoded Videos + Thumbnails
→ DynamoDB (Update post with URLs) → CloudFront Invalidation
```

**2. Feed Retrieval Flow:**
```
Mobile App → API Gateway → Lambda → ElastiCache (Check) 
→ DynamoDB (Query) → ElastiCache (Store) → CloudFront URLs → App
```

**3. Like/Comment Flow:**
```
Mobile App → API Gateway → Lambda → DynamoDB (Atomic Counter)
→ ElastiCache (Update) → WebSocket (Real-time update) → App
```

## 2. Database Schema (DynamoDB)

### Table: Posts
```json
{
  "PK": "POST#<postId>",
  "SK": "METADATA",
  "postId": "uuid",
  "userId": "uuid",
  "videoUrl": "https://cdn.example.com/videos/...",
  "thumbnailUrl": "https://cdn.example.com/thumbnails/...",
  "caption": "string",
  "likeCount": 0,
  "commentCount": 0,
  "shareCount": 0,
  "viewCount": 0,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z",
  "GSI1PK": "USER#<userId>",
  "GSI1SK": "POST#<timestamp>",
  "GSI2PK": "FEED",
  "GSI2SK": "<timestamp>"
}
```

### Table: Likes
```json
{
  "PK": "POST#<postId>",
  "SK": "LIKE#<userId>",
  "userId": "uuid",
  "postId": "uuid",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### Table: Comments
```json
{
  "PK": "POST#<postId>",
  "SK": "COMMENT#<timestamp>#<commentId>",
  "commentId": "uuid",
  "postId": "uuid",
  "userId": "uuid",
  "userName": "string",
  "userAvatar": "url",
  "text": "string",
  "likeCount": 0,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### Global Secondary Indexes (GSI)

**GSI1: UserPosts**
- PK: GSI1PK (USER#<userId>)
- SK: GSI1SK (POST#<timestamp>)
- Purpose: Get all posts by user

**GSI2: FeedPosts**
- PK: GSI2PK (FEED)
- SK: GSI2SK (<timestamp>)
- Purpose: Get global feed with pagination

## 3. API Design (REST)

### Video Endpoints

```
POST   /api/v1/posts/upload-url
GET    /api/v1/posts/feed
GET    /api/v1/posts/:postId
POST   /api/v1/posts/:postId/like
DELETE /api/v1/posts/:postId/like
POST   /api/v1/posts/:postId/comments
GET    /api/v1/posts/:postId/comments
POST   /api/v1/posts/:postId/share
GET    /api/v1/users/:userId/posts
```

### Detailed API Specs

#### 1. Get Upload URL
```http
POST /api/v1/posts/upload-url
Authorization: Bearer <token>

Request:
{
  "fileName": "video.mp4",
  "fileSize": 10485760,
  "mimeType": "video/mp4"
}

Response:
{
  "uploadUrl": "https://s3.amazonaws.com/...",
  "postId": "uuid",
  "expiresIn": 3600
}
```

#### 2. Get Feed (Infinite Scroll)
```http
GET /api/v1/posts/feed?limit=20&cursor=<lastPostId>
Authorization: Bearer <token>

Response:
{
  "posts": [
    {
      "postId": "uuid",
      "userId": "uuid",
      "userName": "John Doe",
      "userAvatar": "url",
      "videoUrl": "https://cdn.example.com/...",
      "thumbnailUrl": "https://cdn.example.com/...",
      "caption": "Amazing video!",
      "likeCount": 1234,
      "commentCount": 56,
      "shareCount": 78,
      "viewCount": 5678,
      "isLiked": false,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "nextCursor": "uuid",
  "hasMore": true
}
```

#### 3. Like Post
```http
POST /api/v1/posts/:postId/like
Authorization: Bearer <token>

Response:
{
  "success": true,
  "likeCount": 1235,
  "isLiked": true
}
```

#### 4. Get Comments
```http
GET /api/v1/posts/:postId/comments?limit=20&cursor=<lastCommentId>
Authorization: Bearer <token>

Response:
{
  "comments": [
    {
      "commentId": "uuid",
      "userId": "uuid",
      "userName": "Jane Smith",
      "userAvatar": "url",
      "text": "Great video!",
      "likeCount": 12,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "nextCursor": "uuid",
  "hasMore": true
}
```

## 4. Frontend Implementation (Flutter)

### Grid View with Thumbnails

```dart
// lib/screens/profile_grid_screen.dart
class ProfileGridScreen extends StatefulWidget {
  @override
  _ProfileGridScreenState createState() => _ProfileGridScreenState();
}

class _ProfileGridScreenState extends State<ProfileGridScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _nextCursor;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMorePosts();
    }
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getPosts(limit: 20);
    setState(() {
      _posts = response.posts;
      _nextCursor = response.nextCursor;
      _isLoading = false;
    });
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || _nextCursor == null) return;
    setState(() => _isLoading = true);
    final response = await ApiService.getPosts(
      limit: 20, 
      cursor: _nextCursor
    );
    setState(() {
      _posts.addAll(response.posts);
      _nextCursor = response.nextCursor;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.7,
      ),
      itemCount: _posts.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _posts.length) {
          return Center(child: CircularProgressIndicator());
        }
        return VideoGridItem(
          post: _posts[index],
          onTap: () => _openFullScreen(index),
        );
      },
    );
  }

  void _openFullScreen(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          posts: _posts,
          initialIndex: index,
        ),
      ),
    );
  }
}

// lib/widgets/video_grid_item.dart
class VideoGridItem extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const VideoGridItem({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail
          CachedNetworkImage(
            imageUrl: post.thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[800],
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // Stats overlay
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  _formatCount(post.likeCount),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                SizedBox(width: 12),
                Icon(Icons.comment, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  _formatCount(post.commentCount),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          // Play icon
          Center(
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
```

### Full-Screen Video Player

```dart
// lib/screens/video_player_screen.dart
class VideoPlayerScreen extends StatefulWidget {
  final List<Post> posts;
  final int initialIndex;

  const VideoPlayerScreen({
    required this.posts,
    required this.initialIndex,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.posts.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          return VideoPlayerItem(
            post: widget.posts[index],
            isActive: index == _currentIndex,
          );
        },
      ),
    );
  }
}

// lib/widgets/video_player_item.dart
class VideoPlayerItem extends StatefulWidget {
  final Post post;
  final bool isActive;

  const VideoPlayerItem({required this.post, required this.isActive});

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _isLiked = false;
  int _likeCount = 0;
  int _commentCount = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likeCount;
    _commentCount = widget.post.commentCount;
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.network(widget.post.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        if (widget.isActive) _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void didUpdateWidget(VideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.value.isPlaying) {
      _controller.play();
    } else if (!widget.isActive && _controller.value.isPlaying) {
      _controller.pause();
    }
  }

  Future<void> _toggleLike() async {
    final newLiked = !_isLiked;
    setState(() {
      _isLiked = newLiked;
      _likeCount += newLiked ? 1 : -1;
    });

    try {
      if (newLiked) {
        await ApiService.likePost(widget.post.postId);
      } else {
        await ApiService.unlikePost(widget.post.postId);
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _isLiked = !newLiked;
        _likeCount += newLiked ? -1 : 1;
      });
    }
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(
        postId: widget.post.postId,
        onCommentAdded: () {
          setState(() => _commentCount++);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player
        _controller.value.isInitialized
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: VideoPlayer(_controller),
              )
            : Center(child: CircularProgressIndicator()),
        
        // Right side actions
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: [
              _buildActionButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                label: _formatCount(_likeCount),
                color: _isLiked ? Colors.red : Colors.white,
                onTap: _toggleLike,
              ),
              SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.comment,
                label: _formatCount(_commentCount),
                onTap: _showComments,
              ),
              SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.share,
                label: _formatCount(widget.post.shareCount),
                onTap: _sharePost,
              ),
            ],
          ),
        ),
        
        // Bottom info
        Positioned(
          left: 12,
          right: 80,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${widget.post.userName}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.post.caption,
                style: TextStyle(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  void _sharePost() async {
    await Share.share('Check out this video on Social Live!');
    await ApiService.incrementShareCount(widget.post.postId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## 5. Backend Lambda Functions

### Get Feed Lambda
```python
# lambda/get_feed.py
import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
posts_table = dynamodb.Table('Posts')

def lambda_handler(event, context):
    limit = int(event.get('queryStringParameters', {}).get('limit', 20))
    cursor = event.get('queryStringParameters', {}).get('cursor')
    
    query_params = {
        'IndexName': 'GSI2-FeedPosts',
        'KeyConditionExpression': 'GSI2PK = :feed',
        'ExpressionAttributeValues': {':feed': 'FEED'},
        'Limit': limit,
        'ScanIndexForward': False
    }
    
    if cursor:
        query_params['ExclusiveStartKey'] = json.loads(cursor)
    
    response = posts_table.query(**query_params)
    
    posts = []
    for item in response['Items']:
        posts.append({
            'postId': item['postId'],
            'userId': item['userId'],
            'videoUrl': item['videoUrl'],
            'thumbnailUrl': item['thumbnailUrl'],
            'caption': item.get('caption', ''),
            'likeCount': int(item.get('likeCount', 0)),
            'commentCount': int(item.get('commentCount', 0)),
            'shareCount': int(item.get('shareCount', 0)),
            'createdAt': item['createdAt']
        })
    
    next_cursor = None
    if 'LastEvaluatedKey' in response:
        next_cursor = json.dumps(response['LastEvaluatedKey'])
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'posts': posts,
            'nextCursor': next_cursor,
            'hasMore': next_cursor is not None
        })
    }
```

### Like Post Lambda
```python
# lambda/like_post.py
import json
import boto3

dynamodb = boto3.resource('dynamodb')
posts_table = dynamodb.Table('Posts')
likes_table = dynamodb.Table('Likes')

def lambda_handler(event, context):
    post_id = event['pathParameters']['postId']
    user_id = event['requestContext']['authorizer']['userId']
    
    # Add like record
    likes_table.put_item(
        Item={
            'PK': f'POST#{post_id}',
            'SK': f'LIKE#{user_id}',
            'userId': user_id,
            'postId': post_id,
            'createdAt': datetime.now().isoformat()
        }
    )
    
    # Increment like count atomically
    response = posts_table.update_item(
        Key={'PK': f'POST#{post_id}', 'SK': 'METADATA'},
        UpdateExpression='ADD likeCount :inc',
        ExpressionAttributeValues={':inc': 1},
        ReturnValues='ALL_NEW'
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'success': True,
            'likeCount': int(response['Attributes']['likeCount']),
            'isLiked': True
        })
    }
```

## 6. Performance & Scalability

### Caching Strategy
```
- CloudFront: Cache videos/thumbnails (TTL: 1 year)
- ElastiCache: Cache feed queries (TTL: 5 minutes)
- ElastiCache: Cache like/comment counts (TTL: 1 minute)
```

### Optimization Techniques
1. **Lazy Loading**: Load videos only when visible
2. **Preloading**: Preload next 2 videos in feed
3. **Thumbnail Optimization**: WebP format, 300x400px
4. **Video Optimization**: Multiple resolutions (360p, 720p, 1080p)
5. **CDN**: CloudFront with edge locations
6. **Database**: DynamoDB with on-demand capacity
7. **Real-time**: WebSocket API for live updates

### Cost Optimization
- S3 Intelligent-Tiering for old videos
- CloudFront compression enabled
- DynamoDB on-demand pricing
- Lambda provisioned concurrency for hot functions

## 7. Deployment

### Infrastructure as Code (Terraform)
```hcl
# terraform/main.tf
resource "aws_s3_bucket" "videos" {
  bucket = "social-live-videos"
}

resource "aws_dynamodb_table" "posts" {
  name           = "Posts"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PK"
  range_key      = "SK"
  
  global_secondary_index {
    name            = "GSI2-FeedPosts"
    hash_key        = "GSI2PK"
    range_key       = "GSI2SK"
    projection_type = "ALL"
  }
}
```

This architecture supports:
- ✅ Millions of users
- ✅ Infinite scroll
- ✅ Real-time interactions
- ✅ Auto-scaling
- ✅ Global delivery
- ✅ Cost-effective
