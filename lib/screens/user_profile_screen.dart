import 'package:flutter/material.dart';
import '../services/user_content_service.dart';
import '../widgets/video_thumbnail_widget.dart';
import 'content_preview_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String username;
  final String userId;

  const UserProfileScreen({
    Key? key,
    required this.username,
    required this.userId,
  }) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isFollowing = false;
  int followersCount = 0;
  int followingCount = 0;
  int likesCount = 0;
  List<UserContent> userContent = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // Simulate loading user data
    setState(() {
      followersCount = 5000 + (widget.userId.hashCode % 10000);
      followingCount = 200 + (widget.userId.hashCode % 500);
      likesCount = 50000 + (widget.userId.hashCode % 100000);
      
      // Generate sample content for this user
      userContent = _generateUserContent();
    });
  }

  List<UserContent> _generateUserContent() {
    final random = widget.userId.hashCode;
    final contentCount = 8 + (random % 12);
    
    return List.generate(contentCount, (index) {
      final types = ['photo', 'video', 'live'];
      final type = types[(random + index) % types.length];
      
      return UserContent(
        id: 'user_${widget.userId}_$index',
        type: type,
        path: 'path/to/content_$index',
        thumbnailPath: null,
        duration: type == 'video' ? 15 + (index * 5) : null,
        views: 1000 + (index * 500),
        createdAt: DateTime.now().subtract(Duration(days: index)),
      );
    });
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.username,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showMoreOptions(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purple,
              child: Text(
                widget.username[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Username
            Text(
              widget.username,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            // Bio
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Content creator | Living my best life 🎬✨',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('Following', _formatCount(followingCount)),
                _buildStat('Followers', _formatCount(followersCount)),
                _buildStat('Likes', _formatCount(likesCount)),
              ],
            ),
            SizedBox(height: 20),
            // Follow/Message Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isFollowing = !isFollowing;
                          if (isFollowing) {
                            followersCount++;
                          } else {
                            followersCount--;
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFollowing
                                  ? 'Following ${widget.username}'
                                  : 'Unfollowed ${widget.username}',
                            ),
                            backgroundColor: Colors.purple,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing ? Colors.grey[800] : Colors.purple,
                        minimumSize: Size(0, 45),
                      ),
                      child: Text(
                        isFollowing ? 'Following' : 'Follow',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Message feature coming soon!'),
                            backgroundColor: Colors.purple,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.purple),
                        minimumSize: Size(0, 45),
                      ),
                      child: Icon(Icons.message, color: Colors.purple),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Tabs
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Colors.purple,
                    labelColor: Colors.purple,
                    unselectedLabelColor: Colors.grey[400],
                    tabs: [
                      Tab(icon: Icon(Icons.grid_on), text: 'Feed'),
                      Tab(icon: Icon(Icons.video_library), text: 'Videos'),
                      Tab(icon: Icon(Icons.favorite), text: 'Liked'),
                    ],
                  ),
                  Container(
                    height: 400,
                    child: TabBarView(
                      children: [
                        _buildFeedGrid(),
                        _buildVideoGrid(),
                        _buildLikedGrid(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFeedGrid() {
    if (userContent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, color: Colors.purple.withOpacity(0.5), size: 64),
            SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1.0,
      ),
      itemCount: userContent.length,
      itemBuilder: (context, index) {
        final content = userContent[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContentPreviewScreen(
                  content: content,
                  username: widget.username,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail with gradient overlay
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Generate thumbnail based on content type
                      _buildThumbnailImage(content, index),
                      // Gradient overlay for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Type badge
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: content.type == 'photo' 
                        ? Colors.blue
                        : content.type == 'live'
                          ? Colors.red
                          : Colors.purple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          content.type == 'photo' 
                            ? Icons.image 
                            : content.type == 'live' 
                              ? Icons.live_tv 
                              : Icons.videocam,
                          color: Colors.white,
                          size: 10,
                        ),
                        SizedBox(width: 3),
                        Text(
                          content.type == 'photo' ? 'IMG' : content.type == 'live' ? 'LIVE' : 'VID',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Duration for videos
                if (content.type == 'video' && content.duration != null)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '${content.duration}s',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                
                // Views count
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow, color: Colors.white, size: 10),
                        SizedBox(width: 2),
                        Text(
                          _formatCount(content.views),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThumbnailImage(UserContent content, int index) {
    // Use sample video paths from assets
    final sampleVideos = [
      'assets/videos/sample1.mp4',
      'assets/videos/sample2.mp4',
      'assets/videos/sample3.mp4',
    ];
    
    // Generate a pseudo-random but consistent video selection for each content
    final videoIndex = (widget.userId.hashCode + index) % sampleVideos.length;
    final videoPath = sampleVideos[videoIndex];
    
    if (content.type == 'photo') {
      // For photos, show a colored gradient with icon
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.withOpacity(0.6),
              Colors.purple.withOpacity(0.6),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.photo_camera,
            color: Colors.white.withOpacity(0.7),
            size: 40,
          ),
        ),
      );
    } else if (content.type == 'live') {
      // For live streams, show a red gradient
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.withOpacity(0.6),
              Colors.orange.withOpacity(0.6),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.sensors,
            color: Colors.white.withOpacity(0.7),
            size: 40,
          ),
        ),
      );
    } else {
      // For videos, show real thumbnail from video file
      return VideoThumbnailWidget(
        videoPath: videoPath,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildVideoGrid() {
    // Filter to show only videos
    final videos = userContent.where((content) => content.type == 'video').toList();
    
    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, color: Colors.purple.withOpacity(0.5), size: 64),
            SizedBox(height: 16),
            Text(
              'No videos yet',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    // Sample video paths
    final sampleVideos = [
      'assets/videos/sample1.mp4',
      'assets/videos/sample2.mp4',
      'assets/videos/sample3.mp4',
    ];
    
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final content = videos[index];
        final videoIndex = (widget.userId.hashCode + index) % sampleVideos.length;
        final videoPath = sampleVideos[videoIndex];
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContentPreviewScreen(
                  content: content,
                  username: widget.username,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Real video thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      VideoThumbnailWidget(
                        videoPath: videoPath,
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                          ),
                        ),
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
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                // Duration
                if (content.duration != null)
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${content.duration}s',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                // Views
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.remove_red_eye, color: Colors.white, size: 10),
                        SizedBox(width: 2),
                        Text(
                          _formatCount(content.views),
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLikedGrid() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 60, color: Colors.grey[700]),
          SizedBox(height: 16),
          Text(
            'This user\'s liked videos are private',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.share, color: Colors.purple),
              title: Text('Share Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Share profile'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.report, color: Colors.red),
              title: Text('Report', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Report user'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: Colors.red),
              title: Text('Block', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Block user'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
