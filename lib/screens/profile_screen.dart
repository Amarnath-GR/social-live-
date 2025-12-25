import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/profile_service.dart';
import '../services/video_service.dart';
import '../services/post_storage_service.dart';
import '../models/post_model.dart';
import '../models/user_models.dart';
import '../models/video_model.dart';
import 'post_detail_screen.dart';
import 'fullscreen_video_player.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // If null, shows current user's profile

  ProfileScreen({this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  User? _user;
  List<PostModel> _userPosts = [];
  List<VideoModel> _userVideos = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  final VideoService _videoService = VideoService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProfileData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      final userResult = await ProfileService.getCurrentUser();
      if (userResult['success'] == true) {
        _user = userResult['user'] as User;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', _user!.id);
        
        final localPosts = await PostStorageService.getUserPosts(_user!.id);
        print('Loaded ${localPosts.length} posts for user ${_user!.id}');
        
        _userPosts = localPosts.map((post) {
          try {
            return PostModel.fromJson(post);
          } catch (e) {
            return null;
          }
        }).whereType<PostModel>().toList();
        
        try {
          final postsResult = await ProfileService.getUserPosts(_user!.id);
          if (postsResult['success'] == true) {
            final postsList = postsResult['posts'] as List<dynamic>;
            for (var apiPost in postsList) {
              if (!_userPosts.any((p) => p.id == apiPost['id'])) {
                _userPosts.add(PostModel.fromJson(apiPost));
              }
            }
          }
        } catch (e) {}
        
        _userVideos = localPosts
            .where((post) => post['videoPath'] != null && post['videoPath'].toString().isNotEmpty)
            .map((post) {
              try {
                return VideoModel(
                  id: post['id'],
                  content: post['description'] ?? '',
                  videoUrl: post['videoPath'],
                  duration: post['duration'],
                  createdAt: DateTime.parse(post['createdAt']),
                  user: _user!.toUserModel(),
                  hashtags: List<String>.from(post['hashtags'] ?? []),
                  stats: VideoStats(likes: 0, comments: 0, shares: 0, views: post['views'] ?? 0),
                  isLiked: false,
                );
              } catch (e) {
                return null;
              }
            })
            .whereType<VideoModel>()
            .toList();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      _buildStatsRow(),
                      _buildActionButtons(),
                      _buildBioSection(),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.white,
                      tabs: [
                        Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
                        Tab(icon: Icon(Icons.video_library), text: 'Videos'),
                        Tab(icon: Icon(Icons.favorite), text: 'Liked'),
                        Tab(icon: Icon(Icons.bookmark), text: 'Saved'),
                      ],
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPostsGrid(_userPosts),
                      _buildVideosGrid(_userVideos),
                      _buildPostsGrid([]), // Liked posts placeholder
                      _buildPostsGrid([]), // Saved posts placeholder
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      pinned: true,
      title: Text(
        _user?.username ?? 'Profile',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.white),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: _user?.avatar != null
                  ? Image.network(
                      _user!.avatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
          SizedBox(height: 12),
          
          // Username and Verification
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '@${_user?.username ?? 'username'}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_user?.kycVerified == true) ...[
                SizedBox(width: 6),
                Icon(
                  Icons.verified,
                  color: Colors.blue,
                  size: 20,
                ),
              ],
            ],
          ),
          
          // Display Name
          if (_user?.name != null && _user!.name.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              _user!.name,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[800],
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 50,
      ),
    );
  }

  Widget _buildStatsRow() {
    final totalLikes = _userPosts.fold<int>(0, (sum, post) => sum + post.likes);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('${_user?.followingCount ?? 0}', 'Following'),
          _buildStatItem('${_user?.followersCount ?? 0}', 'Followers'),
          _buildStatItem('$totalLikes', 'Likes'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (widget.userId == null) {
      // Current user's profile - show edit button
      return Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _editProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: _shareProfile,
                icon: Icon(Icons.share, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      // Other user's profile - show follow/message buttons
      return Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: _toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFollowing ? Colors.grey[800] : Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isFollowing ? 'Following' : 'Follow',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Icon(Icons.message, color: Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: _shareProfile,
                icon: Icon(Icons.share, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBioSection() {
    if (_user?.bio == null || _user!.bio!.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        _user!.bio!,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPostsGrid(List<PostModel> posts) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.grey[600],
            ),
            SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(2),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 9 / 16,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _buildPostThumbnail(posts[index]);
      },
    );
  }

  Widget _buildPostThumbnail(PostModel post) {
    final thumbnailUrl = post.thumbnailUrl;
    final views = post.views;
    
    return GestureDetector(
      onTap: () => _viewPost(post),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Post Thumbnail
            if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
              Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderThumbnail();
                },
              )
            else
              _buildPlaceholderThumbnail(),
            
            // Play Icon
            Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
            
            // View Count
            Positioned(
              bottom: 4,
              left: 4,
              child: Row(
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 12,
                  ),
                  SizedBox(width: 2),
                  Text(
                    _formatViewCount(views),
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

  Widget _buildPlaceholderThumbnail() {
    return Container(
      color: Colors.grey[800],
      child: Icon(
        Icons.video_library,
        color: Colors.grey[600],
        size: 40,
      ),
    );
  }

  String _formatViewCount(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    } else {
      return views.toString();
    }
  }

  void _viewPost(PostModel post) async {
    // Navigate to Instagram-like post detail screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(
          post: post,
          user: _user,
        ),
      ),
    );
    
    // If post was deleted, refresh the posts
    if (result == true) {
      _loadProfileData();
    }
  }

  void _editProfile() async {
    final result = await Navigator.pushNamed(context, '/edit-profile');
    if (result == true) {
      _loadProfileData();
    }
  }

  void _shareProfile() {
    // Implement profile sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile shared!')),
    );
  }

  void _toggleFollow() async {
    try {
      if (_isFollowing) {
        await ProfileService.unfollowUser(widget.userId!);
      } else {
        await ProfileService.followUser(widget.userId!);
      }
      setState(() {
        _isFollowing = !_isFollowing;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ${_isFollowing ? 'unfollow' : 'follow'} user')),
      );
    }
  }

  void _sendMessage() {
    Navigator.pushNamed(context, '/chat', arguments: widget.userId);
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.share, color: Colors.white),
              title: Text('Share Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _shareProfile();
              },
            ),
            if (widget.userId != null) ...[
              ListTile(
                leading: Icon(Icons.report, color: Colors.red),
                title: Text('Report', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _reportUser();
                },
              ),
              ListTile(
                leading: Icon(Icons.block, color: Colors.red),
                title: Text('Block', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _blockUser();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _reportUser() {
    // Implement user reporting
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User reported')),
    );
  }

  void _blockUser() {
    // Implement user blocking
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User blocked')),
    );
  }

  Widget _buildVideosGrid(List<VideoModel> videos) {
    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.grey[600],
            ),
            SizedBox(height: 16),
            Text(
              'No videos yet',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(2),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 9 / 16,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return _buildVideoThumbnail(videos[index]);
      },
    );
  }

  Widget _buildVideoThumbnail(VideoModel video) {
    return GestureDetector(
      onTap: () => _playVideo(video),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty)
              Image.network(
                video.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderThumbnail();
                },
              )
            else
              _buildPlaceholderThumbnail(),
            Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
            Positioned(
              bottom: 4,
              left: 4,
              child: Row(
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 12,
                  ),
                  SizedBox(width: 2),
                  Text(
                    _formatViewCount(video.views),
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

  void _playVideo(VideoModel video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayer(
          videoPath: video.videoUrl,
          duration: video.duration ?? 0,
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

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
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}