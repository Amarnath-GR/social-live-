import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:video_player/video_player.dart';
import '../services/video_service.dart';
import '../services/user_content_service.dart';
import '../services/auth_service.dart';
import '../services/saved_videos_service.dart';
import '../models/video_model.dart';
import 'enhanced_simple_camera_screen.dart';
import 'content_preview_screen.dart';
import 'content_viewer_screen.dart';
import 'settings_screen.dart';
import 'profile_edit_screen.dart';
import '../screens/user_account_screen.dart';
import 'admin_panel_screen.dart';
import 'fullscreen_video_player.dart';
import '../services/following_service.dart';
import '../services/following_notifier.dart';
import 'profile_post_viewer.dart';

class SimpleProfileScreen extends StatefulWidget {
  const SimpleProfileScreen({super.key});
  
  @override
  _SimpleProfileScreenState createState() => _SimpleProfileScreenState();
}

class _SimpleProfileScreenState extends State<SimpleProfileScreen> {
  String _username = 'myusername';
  String _bio = 'Content Creator & Social Media Enthusiast';
  String? _profilePicture;

  int followingCount = 0;
  int followersCount = 0;
  int likesCount = 0;
  bool isAdmin = true;
  
  final VideoService _videoService = VideoService();
  List<VideoModel> allPosts = [];
  List<VideoModel> videoPosts = [];
  bool isLoadingVideos = true;
  final UserContentService _userContentService = UserContentService();
  List<UserContent> _userContent = [];

  @override
  void initState() {
    super.initState();
    _loadUserVideos();
    _loadUserContent();
    SavedVideosService().loadSavedVideos();
    FollowingService().loadFollowing().then((_) {
      setState(() {
        followingCount = FollowingService().followingCount;
      });
    });
    FollowingNotifier().setCallback(() {
      setState(() {
        followingCount = FollowingService().followingCount;
      });
    });
  }

  Future<void> _loadUserVideos() async {
    setState(() {
      allPosts = [];
      videoPosts = [];
      isLoadingVideos = false;
    });
  }


  Future<void> _refreshProfile() async {
    await _loadUserVideos();
    _loadUserContent();
  }

  void _loadUserContent() {
    setState(() {
      _userContent = UserContentService().allContent;
      likesCount = _userContent.fold(0, (sum, c) => sum + c.likes);
    });
  }

  void _shareProfile() {
    final String profileUrl = 'https://sociallive.app/@myusername';
    final String shareText = 'Check out my profile on Social Live!\n$profileUrl';
    
    Share.share(
      shareText,
      subject: 'My Social Live Profile',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () => _showSettingsMenu(context),
            icon: Icon(Icons.menu, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          color: Colors.purple,
          backgroundColor: Colors.grey[900],
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                key: ValueKey(_profilePicture),
                radius: 60,
                backgroundColor: Colors.purple,
                backgroundImage: _profilePicture != null ? FileImage(File(_profilePicture!)) : null,
                child: _profilePicture == null ? Text(
                  'ME',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ) : null,
              ),
              SizedBox(height: 16),
              Text(
                '@$_username',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                _bio,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => _showFollowingList(),
                    child: _buildStat('Following', _formatCount(followingCount)),
                  ),
                  GestureDetector(
                    onTap: () => _showFollowersList(),
                    child: _buildStat('Followers', _formatCount(followersCount)),
                  ),
                  GestureDetector(
                    onTap: () => _showLikesBreakdown(),
                    child: _buildStat('Likes', _formatCount(likesCount)),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileEditScreen(
                                    currentUsername: _username,
                                    currentBio: _bio,
                                    currentProfilePicture: _profilePicture,
                                  ),
                                ),
                              );
                              if (result != null && result is Map) {
                                setState(() {
                                  _username = result['username'] ?? _username;
                                  _bio = result['bio'] ?? _bio;
                                  _profilePicture = result['image'];
                                });
                              }
                            },
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
                            border: Border.all(color: Colors.grey[600]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: _shareProfile,
                            icon: Icon(Icons.share, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[400],
                      tabs: [
                        Tab(icon: Icon(Icons.grid_on), text: 'Feed'),
                        Tab(icon: Icon(Icons.video_library), text: 'Videos'),
                        Tab(icon: Icon(Icons.bookmark), text: 'Saved'),
                      ],
                    ),
                    Container(
                      height: 400,
                      child: TabBarView(
                        children: [
                          _buildFeedGrid(),
                          _buildVideoGrid(),
                          _buildSavedGrid(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildStat(String label, String value) {
    if (label == 'Likes') return SizedBox.shrink();
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildVideoGrid() {
    final userVideos = UserContentService().videos;

    if (userVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, color: Colors.grey[600], size: 64),
            SizedBox(height: 16),
            Text('No videos yet', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
            SizedBox(height: 8),
            Text('Upload your first video', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.7,
      ),
      itemCount: userVideos.length,
      itemBuilder: (context, index) {
        final video = userVideos[index];
        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContentViewerScreen(
                  contents: userVideos,
                  initialIndex: index,
                ),
              ),
            );
            setState(() {});
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: video.thumbnailPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(video.thumbnailPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.purple.withOpacity(0.3),
                            child: Icon(Icons.video_library, color: Colors.white, size: 32),
                          ),
                        ),
                      )
                    : Center(child: Icon(Icons.video_library, color: Colors.white, size: 32)),
              ),
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
              Positioned(
                left: 4,
                bottom: 4,
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, color: Colors.white, size: 14),
                    SizedBox(width: 2),
                    Text(
                      _formatCount(video.views),
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedGrid() {
    final savedVideos = SavedVideosService().savedVideos;

    if (savedVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, color: Colors.grey[600], size: 64),
            SizedBox(height: 16),
            Text('No saved posts yet', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
            SizedBox(height: 8),
            Text('Save posts to view them here', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: savedVideos.length,
      itemBuilder: (context, index) {
        final video = savedVideos[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContentPreviewScreen(
                  contentPath: video['videoUrl'] ?? '',
                  contentType: 'video',
                  isOwner: false,
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
              children: [
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
                Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(Icons.bookmark, color: Colors.yellow, size: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isAdmin)
                ListTile(
                  leading: Icon(Icons.admin_panel_settings, color: Colors.orange),
                  title: Text('Admin Panel', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminPanelScreen()),
                    );
                  },
                ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.white),
                title: Text('Settings', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.white),
                title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileEditScreen(
                        currentUsername: _username,
                        currentBio: _bio,
                        currentProfilePicture: _profilePicture,
                      ),
                    ),
                  );
                  if (result != null && result is Map) {
                    setState(() {
                      _username = result['username'] ?? _username;
                      _bio = result['bio'] ?? _bio;
                      _profilePicture = result['image'];
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: Colors.white),
                title: Text('Share Profile', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _shareProfile();
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnalytics() {
    final userContent = UserContentService().getUserContent();
    final totalViews = userContent.fold(0, (sum, content) => sum + (content['views'] as int? ?? 0));
    final totalLikes = userContent.fold(0, (sum, content) => sum + (content['likes'] as int? ?? 0));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Profile Analytics', style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnalyticItem('Total Posts', '${userContent.length}', ''),
              _buildAnalyticItem('Total Views', '$totalViews', ''),
              _buildAnalyticItem('Total Likes', '$totalLikes', ''),
              _buildAnalyticItem('Followers', '$followersCount', ''),
              _buildAnalyticItem('Following', '$followingCount', ''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticItem(String label, String value, String change) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400])),
          Row(
            children: [
              Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              if (change.isNotEmpty) ...[
                SizedBox(width: 8),
                Text(
                  change,
                  style: TextStyle(
                    color: change.startsWith('+') ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Logout', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement logout logic here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFollowingList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                'Following ($followingCount)',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: FollowingService().followingUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, color: Colors.grey[600], size: 64),
                          SizedBox(height: 16),
                          Text('Not following anyone yet', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                itemCount: FollowingService().followingUsers.length,
                itemBuilder: (context, index) {
                  final followingUsers = FollowingService().followingUsers;
                  final user = followingUsers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Text(user['displayName']![0].toUpperCase(), style: TextStyle(color: Colors.white)),
                    ),
                    title: Text(user['displayName']!, style: TextStyle(color: Colors.white)),
                    subtitle: Text(user['username']!, style: TextStyle(color: Colors.grey[400])),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        await FollowingService().unfollowUser(user['username']!);
                        setState(() {
                          followingCount = FollowingService().followingCount;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Unfollowed ${user['displayName']}')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        minimumSize: Size(80, 30),
                      ),
                      child: Text('Following', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserAccountScreen(
                            username: user['username']!,
                            displayName: user['displayName']!,
                            isFollowing: true,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFollowersList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                'Followers ($followersCount)',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, color: Colors.grey[600], size: 64),
                    SizedBox(height: 16),
                    Text('No followers yet', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Share your content to gain followers', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLikesBreakdown() {
    final userContent = UserContentService().getUserContent();
    
    final videoLikes = userContent
        .where((c) => c['type'] == 'video')
        .fold(0, (sum, c) => sum + (c['likes'] as int? ?? 0));
    final photoLikes = userContent
        .where((c) => c['type'] == 'photo')
        .fold(0, (sum, c) => sum + (c['likes'] as int? ?? 0));
    final liveLikes = userContent
        .where((c) => c['type'] == 'live')
        .fold(0, (sum, c) => sum + (c['likes'] as int? ?? 0));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Likes Breakdown', style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLikeItem('Videos', '$videoLikes'),
              _buildLikeItem('Photos', '$photoLikes'),
              _buildLikeItem('Live Streams', '$liveLikes'),
              Divider(color: Colors.grey[600]),
              _buildLikeItem('Total', '$likesCount', isTotal: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeItem(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.grey[400],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedGrid() {
    final userContent = UserContentService().allContent;

    if (userContent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, color: Colors.grey[600], size: 64),
            SizedBox(height: 16),
            Text('No content yet', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
            SizedBox(height: 8),
            Text('Upload your first post', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.7,
      ),
      itemCount: userContent.length,
      itemBuilder: (context, index) {
        final content = userContent[index];
        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContentViewerScreen(
                  contents: userContent,
                  initialIndex: index,
                ),
              ),
            );
            setState(() {});
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: content.thumbnailPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(content.thumbnailPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: content.type == 'video' ? Colors.purple.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                            child: Icon(content.type == 'video' ? Icons.video_library : Icons.image, color: Colors.white, size: 32),
                          ),
                        ),
                      )
                    : Center(child: Icon(content.type == 'video' ? Icons.play_arrow : Icons.image, color: Colors.white, size: 32)),
              ),
              if (content.type == 'video')
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
              Positioned(
                left: 4,
                bottom: 4,
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, color: Colors.white, size: 14),
                    SizedBox(width: 2),
                    Text(
                      _formatCount(content.views),
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContentThumbnail(Map<String, dynamic> content) {
    final path = content['path'];
    
    if (path == null) return _buildFallbackThumbnail(content['type']);
    
    // For photos, show the image file
    if (content['type'] == 'photo') {
      try {
        final file = File(path);
        if (file.existsSync()) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              file,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        }
      } catch (e) {}
    }
    
    // For videos, generate thumbnail from video file
    if (content['type'] == 'video') {
      return FutureBuilder<Uint8List?>(
        future: _generateVideoThumbnail(path),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Image.memory(
                    snapshot.data!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Center(
                    child: Icon(Icons.play_circle_outline, color: Colors.white, size: 32),
                  ),
                ],
              ),
            );
          }
          return _buildFallbackThumbnail('video');
        },
      );
    }
    
    return _buildFallbackThumbnail(content['type']);
  }

  Future<Uint8List?> _generateVideoThumbnail(String videoPath) async {
    try {
      final file = File(videoPath);
      if (!file.existsSync()) return null;
      
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      await controller.seekTo(Duration(seconds: 1));
      
      // Wait a bit for the frame to load
      await Future.delayed(Duration(milliseconds: 100));
      
      controller.dispose();
      return null; // Fallback for now
    } catch (e) {
      return null;
    }
  }

  Widget _buildVideoThumbnail(String path) {
    // For videos, always show fallback thumbnail since we can't display video files as images
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.8),
            Colors.deepPurple.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.play_arrow, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildFallbackThumbnail(String type) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: type == 'video' ? [
            Colors.purple.withOpacity(0.8),
            Colors.deepPurple.withOpacity(0.6),
          ] : type == 'live' ? [
            Colors.red.withOpacity(0.8),
            Colors.deepOrange.withOpacity(0.6),
          ] : [
            Colors.blue.withOpacity(0.8),
            Colors.indigo.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          type == 'video' ? Icons.play_arrow :
          type == 'live' ? Icons.live_tv :
          Icons.photo,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}