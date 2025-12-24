import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../models/video_model.dart';
import 'simple_video_feed_screen.dart';
import 'enhanced_simple_camera_screen.dart';

class EnhancedProfileScreen extends StatefulWidget {
  final String? userId;

  const EnhancedProfileScreen({super.key, this.userId});

  @override
  State<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends State<EnhancedProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // User stats
  Map<String, dynamic>? userProfile;
  int followingCount = 234;
  int followersCount = 12543;
  int likesCount = 456789;
  
  // Content lists
  List<VideoModel> feedVideos = [];
  List<VideoModel> userVideos = [];
  List<VideoModel> likedVideos = [];
  
  bool isLoadingFeed = false;
  bool isLoadingVideos = false;
  bool isLoadingLiked = false;
  
  int feedPage = 1;
  int videosPage = 1;
  int likedPage = 1;

  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _apiService = ApiService();
    _loadUserProfile();
    _loadFeedVideos();
    _loadUserVideos();
    _loadLikedVideos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _apiService.getUserProfile();
      if (user != null) {
        setState(() {
          userProfile = user.toJson();
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> _loadFeedVideos() async {
    if (isLoadingFeed) return;
    
    setState(() => isLoadingFeed = true);
    
    try {
      final videos = await _apiService.getTikTokFeed(page: feedPage, limit: 20);
      setState(() {
        feedVideos.addAll(videos);
      });
    } catch (e) {
      debugPrint('Error loading feed videos: $e');
    } finally {
      setState(() => isLoadingFeed = false);
    }
  }

  Future<void> _loadUserVideos() async {
    if (isLoadingVideos) return;
    
    setState(() => isLoadingVideos = true);
    
    try {
      final videos = await _apiService.getUserVideos(null);
      setState(() {
        userVideos.addAll(videos);
      });
    } catch (e) {
      debugPrint('Error loading user videos: $e');
    } finally {
      setState(() => isLoadingVideos = false);
    }
  }

  Future<void> _loadLikedVideos() async {
    if (isLoadingLiked) return;
    
    setState(() => isLoadingLiked = true);
    
    try {
      final videos = await _apiService.getUserLikedVideos(null);
      setState(() {
        likedVideos.addAll(videos);
      });
    } catch (e) {
      debugPrint('Error loading liked videos: $e');
    } finally {
      setState(() => isLoadingLiked = false);
    }
  }

  Future<void> _refreshProfile() async {
    setState(() {
      feedVideos.clear();
      userVideos.clear();
      likedVideos.clear();
      feedPage = 1;
      videosPage = 1;
      likedPage = 1;
    });
    
    await Future.wait([
      _loadUserProfile(),
      _loadFeedVideos(),
      _loadUserVideos(),
      _loadLikedVideos(),
    ]);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile refreshed!'),
          backgroundColor: Colors.purple,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          userProfile?['username'] ?? 'Profile',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _showSettingsMenu,
            icon: Icon(Icons.menu, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: Colors.purple,
        backgroundColor: Colors.grey[900],
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildProfileHeader(),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.purple,
                  labelColor: Colors.purple,
                  unselectedLabelColor: Colors.grey[400],
                  tabs: [
                    Tab(icon: Icon(Icons.grid_on), text: 'Feed'),
                    Tab(icon: Icon(Icons.video_library), text: 'Videos'),
                    Tab(icon: Icon(Icons.favorite), text: 'Liked'),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVideoGrid(feedVideos, isLoadingFeed, _loadMoreFeed),
                  _buildVideoGrid(userVideos, isLoadingVideos, _loadMoreVideos),
                  _buildVideoGrid(likedVideos, isLoadingLiked, _loadMoreLiked),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        SizedBox(height: 20),
        // Profile Avatar
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.purple,
          backgroundImage: userProfile?['avatar'] != null
              ? CachedNetworkImageProvider(userProfile!['avatar'])
              : null,
          child: userProfile?['avatar'] == null
              ? Text(
                  userProfile?['name']?.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '@${userProfile?['username'] ?? 'username'}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (userProfile?['verified'] == true) ...[
              SizedBox(width: 4),
              Icon(Icons.verified, color: Colors.blue, size: 20),
            ],
          ],
        ),
        SizedBox(height: 8),
        Text(
          userProfile?['name'] ?? 'Content Creator',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        SizedBox(height: 20),
        
        // Stats Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat('Following', _formatCount(followingCount)),
            _buildStat('Followers', _formatCount(followersCount)),
            _buildStat('Likes', _formatCount(likesCount)),
          ],
        ),
        SizedBox(height: 20),
        
        // Action Buttons
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showEditProfileDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        minimumSize: Size(0, 45),
                      ),
                      child: Text('Edit Profile', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Share Profile clicked!')),
                        );
                      },
                      icon: Icon(Icons.share, color: Colors.purple),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EnhancedSimpleCameraScreen(
                              autoStartRecording: false,
                              isLiveMode: false,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        minimumSize: Size(0, 45),
                      ),
                      icon: Icon(Icons.upload, color: Colors.white),
                      label: Text('Upload', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EnhancedSimpleCameraScreen(
                              autoStartRecording: false,
                              isLiveMode: true,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        minimumSize: Size(0, 45),
                      ),
                      icon: Icon(Icons.videocam, color: Colors.white),
                      label: Text('Go Live', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
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

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildVideoGrid(List<VideoModel> videos, bool isLoading, VoidCallback loadMore) {
    if (videos.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              color: Colors.purple.withValues(alpha: 0.5),
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No videos yet',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Start creating content to see it here',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          loadMore();
        }
        return false;
      },
      child: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 0.6,
        ),
        itemCount: videos.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == videos.length) {
            return Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          final video = videos[index];
          return _buildVideoThumbnail(video);
        },
      ),
    );
  }

  Widget _buildVideoThumbnail(VideoModel video) {
    return GestureDetector(
      onTap: () => _playVideo(video),
      onLongPress: () => _showVideoOptions(video),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: video.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: video.thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.purple,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.purple,
                          size: 32,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.purple,
                        size: 32,
                      ),
                    ),
            ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            
            // Play icon
            Center(
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.white.withValues(alpha: 0.8),
                size: 40,
              ),
            ),
            
            // Duration badge
            if (video.duration != null)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDuration(video.duration!),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            
            // Views count
            Positioned(
              bottom: 4,
              left: 4,
              child: Row(
                children: [
                  Icon(Icons.play_arrow, color: Colors.white, size: 12),
                  SizedBox(width: 2),
                  Text(
                    _formatCount(video.stats.views),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Likes count
            Positioned(
              bottom: 4,
              right: 4,
              child: Row(
                children: [
                  Icon(
                    video.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: video.isLiked ? Colors.red : Colors.white,
                    size: 12,
                  ),
                  SizedBox(width: 2),
                  Text(
                    _formatCount(video.stats.likes),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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

  String _formatDuration(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '${seconds}s';
  }

  void _playVideo(VideoModel video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimpleVideoFeedScreen(initialVideo: video),
      ),
    );
  }

  void _showVideoOptions(VideoModel video) {
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
              leading: Icon(Icons.delete, color: Colors.purple),
              title: Text('Delete Video', style: TextStyle(color: Colors.purple)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(video);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.white),
              title: Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Share video')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.white),
              title: Text('Edit Caption', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Edit caption')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(VideoModel video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Delete Video?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This video will be permanently deleted.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete API call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Video deleted'),
                  backgroundColor: Colors.purple,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  void _loadMoreFeed() {
    setState(() => feedPage++);
    _loadFeedVideos();
  }

  void _loadMoreVideos() {
    setState(() => videosPage++);
    _loadUserVideos();
  }

  void _loadMoreLiked() {
    setState(() => likedPage++);
    _loadLikedVideos();
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
        content: Text(
          'Profile editing coming soon!',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu() {
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
            _buildSettingsItem(Icons.settings, 'Settings'),
            _buildSettingsItem(Icons.privacy_tip, 'Privacy'),
            _buildSettingsItem(Icons.help, 'Help'),
            _buildSettingsItem(Icons.logout, 'Logout'),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title clicked!')),
        );
      },
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}
