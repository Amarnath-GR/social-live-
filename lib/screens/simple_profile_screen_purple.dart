import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'enhanced_simple_camera_screen.dart';
import '../services/user_content_service.dart';
import '../services/liked_videos_service.dart';
import '../widgets/video_thumbnail_widget.dart';
import 'content_preview_screen.dart';
import 'dart:io';

class SimpleProfileScreenPurple extends StatefulWidget {
  @override
  _SimpleProfileScreenPurpleState createState() => _SimpleProfileScreenPurpleState();
}

class _SimpleProfileScreenPurpleState extends State<SimpleProfileScreenPurple> {
  // Dynamic stats
  int followingCount = 234;
  int followersCount = 12543;
  int likesCount = 456789;
  
  // Profile data
  String username = '@myusername';
  String bio = 'Content Creator & Social Media Enthusiast';
  
  List<Map<String, dynamic>> uploadedVideos = [];

  Future<void> _refreshProfile() async {
    // Simulate refresh delay
    await Future.delayed(Duration(seconds: 1));
    
    // Update stats (simulate fetching from server)
    setState(() {
      followersCount += 10;
      likesCount += 100;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile refreshed!'),
        backgroundColor: Colors.purple,
        duration: Duration(seconds: 1),
      ),
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
            onPressed: () {
              _showSettingsMenu(context);
            },
            icon: Icon(Icons.menu, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: Colors.purple,
        backgroundColor: Colors.grey[900],
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 20),
              // Profile Header
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.purple,
                child: Text(
                  'ME',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16),
              Text(
                username,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                bio,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              SizedBox(height: 20),
              
              // Stats Row - Dynamic values
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Following', _formatCount(followingCount), onTap: () => _showFollowingList()),
                  _buildStat('Followers', _formatCount(followersCount), onTap: () => _showFollowersList()),
                  _buildStat('Likes', _formatCount(likesCount), onTap: () => _showLikesInfo()),
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
                            onPressed: () {
                              _showEditProfileDialog();
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
                            border: Border.all(color: Colors.purple),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: () {
                              _shareProfile();
                            },
                            icon: Icon(Icons.share, color: Colors.purple),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    // Upload and Live buttons
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
                            label: Text('Upload Video', style: TextStyle(color: Colors.white)),
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
      ),
    );
  }

  Widget _buildStat(String label, String value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
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

  Widget _buildFeedGrid() {
    final userContent = UserContentService().allContent;
    
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
            SizedBox(height: 8),
            Text(
              'Share photos and videos to build your feed',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
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
            _playContent(content);
          },
          onLongPress: () {
            _showContentOptions(content);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Real thumbnail for videos, gradient for photos/live
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: content.type == 'video'
                    ? VideoThumbnailWidget(
                        videoPath: content.path,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: content.type == 'photo'
                              ? [Colors.blue.withOpacity(0.6), Colors.purple.withOpacity(0.6)]
                              : [Colors.red.withOpacity(0.6), Colors.orange.withOpacity(0.6)],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            content.type == 'photo' ? Icons.photo_camera : Icons.sensors,
                            color: Colors.white.withOpacity(0.7),
                            size: 40,
                          ),
                        ),
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

  Widget _buildVideoGrid() {
    // Filter to show ONLY videos (not photos or live)
    final videos = UserContentService().allContent.where((c) => c.type == 'video').toList();
    
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
            SizedBox(height: 8),
            Text(
              'Tap Upload Video to add your first video',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
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
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final content = videos[index];
        return GestureDetector(
          onTap: () {
            _playContent(content);
          },
          onLongPress: () {
            _showContentOptions(content);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Real thumbnail for videos
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: content.type == 'video'
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          VideoThumbnailWidget(
                            videoPath: content.path,
                            fit: BoxFit.cover,
                          ),
                          // Gradient overlay
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
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: content.type == 'photo'
                              ? [Colors.blue.withOpacity(0.6), Colors.purple.withOpacity(0.6)]
                              : [Colors.red.withOpacity(0.6), Colors.orange.withOpacity(0.6)],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            content.type == 'photo' ? Icons.photo : Icons.sensors,
                            color: Colors.white.withOpacity(0.7),
                            size: 32,
                          ),
                        ),
                      ),
                ),
                // Type badge
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: content.type == 'photo' 
                        ? Colors.blue.withOpacity(0.8)
                        : content.type == 'live'
                          ? Colors.red.withOpacity(0.8)
                          : Colors.purple.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      content.type.toUpperCase(),
                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Duration for videos
                if (content.type == 'video' && content.duration != null)
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
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                // Views
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Row(
                    children: [
                      Icon(Icons.remove_red_eye, color: Colors.white, size: 10),
                      SizedBox(width: 2),
                      Text(
                        _formatCount(content.views),
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                // Options button
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      _showContentOptions(content);
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.more_vert, color: Colors.white, size: 16),
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

  void _playContent(UserContent content) {
    // Actually play the content - navigate to full screen player
    if (content.type == 'video') {
      // TODO: Navigate to video player screen with content.path
      // For now, just show it's playing without message
    } else if (content.type == 'photo') {
      // Show photo in full screen
      _showPhotoFullScreen(content);
    } else if (content.type == 'live') {
      // Show live stream replay or info
      _showLiveStreamInfo(content);
    }
  }

  void _showPhotoFullScreen(UserContent content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: Icon(Icons.photo, color: Colors.purple, size: 120),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLiveStreamInfo(UserContent content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(Icons.sensors, color: Colors.red),
            SizedBox(width: 8),
            Text('Live Stream', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'This was a live stream. Replay not available.',
          style: TextStyle(color: Colors.grey[400]),
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

  void _showContentOptions(UserContent content) {
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
              title: Text('Delete ${content.type}', style: TextStyle(color: Colors.purple)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(content);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.white),
              title: Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _shareContent(content);
              },
            ),
            if (content.type != 'photo')
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

  void _confirmDelete(UserContent content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Delete ${content.type}?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This ${content.type} will be permanently deleted.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              UserContentService().deleteContent(content.id);
              Navigator.pop(context);
              setState(() {}); // Refresh UI
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${content.type} deleted'),
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

  Widget _buildLikedGrid() {
    final likedVideos = LikedVideosService().likedVideos;

    if (likedVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[700]),
            SizedBox(height: 16),
            Text(
              'No liked videos yet',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Double tap videos to like them',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Sample video paths for thumbnails
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
      itemCount: likedVideos.length,
      itemBuilder: (context, index) {
        final video = likedVideos[index];
        final videoIndex = index % sampleVideos.length;
        final videoPath = sampleVideos[videoIndex];
        
        return GestureDetector(
          onTap: () {
            // Play the liked video
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Playing: ${video.title}'),
                backgroundColor: Colors.purple,
                duration: Duration(seconds: 1),
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
                      // Gradient overlay
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
                // Favorite badge
                Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(Icons.favorite, color: Colors.red, size: 20),
                ),
                // Likes count
                Positioned(
                  bottom: 4,
                  left: 4,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, color: Colors.red, size: 10),
                        SizedBox(width: 2),
                        Text(
                          '${(video.likes / 1000).toStringAsFixed(1)}K',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                // Views count
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
                          _formatCount(video.likes * 10), // Estimate views as 10x likes
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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

  void _showSettingsMenu(BuildContext context) {
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
            _buildSettingsItem(Icons.settings, 'Settings', () {
              Navigator.pop(context);
              _showSettingsDialog();
            }),
            _buildSettingsItem(Icons.privacy_tip, 'Privacy', () {
              Navigator.pop(context);
              _showPrivacyDialog();
            }),
            _buildSettingsItem(Icons.help, 'Help', () {
              Navigator.pop(context);
              _showHelpDialog();
            }),
            _buildSettingsItem(Icons.logout, 'Logout', () {
              Navigator.pop(context);
              _showLogoutDialog();
            }),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Push Notifications', style: TextStyle(color: Colors.white)),
                subtitle: Text('Receive notifications for likes and comments', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                value: true,
                activeColor: Colors.purple,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value ? 'Notifications enabled' : 'Notifications disabled'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
              Divider(color: Colors.grey[700]),
              SwitchListTile(
                title: Text('Auto-play Videos', style: TextStyle(color: Colors.white)),
                subtitle: Text('Automatically play videos in feed', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                value: true,
                activeColor: Colors.purple,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value ? 'Auto-play enabled' : 'Auto-play disabled'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
              Divider(color: Colors.grey[700]),
              ListTile(
                leading: Icon(Icons.language, color: Colors.purple),
                title: Text('Language', style: TextStyle(color: Colors.white)),
                subtitle: Text('English', style: TextStyle(color: Colors.grey[400])),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language settings'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.dark_mode, color: Colors.purple),
                title: Text('Dark Mode', style: TextStyle(color: Colors.white)),
                subtitle: Text('Always on', style: TextStyle(color: Colors.grey[400])),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Theme settings'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
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

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Privacy & Security', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(Icons.lock, color: Colors.purple),
                title: Text('Private Account', style: TextStyle(color: Colors.white)),
                subtitle: Text('Only followers can see your posts', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                trailing: Switch(
                  value: false,
                  activeColor: Colors.purple,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(value ? 'Account is now private' : 'Account is now public'),
                        backgroundColor: Colors.purple,
                      ),
                    );
                  },
                ),
              ),
              Divider(color: Colors.grey[700]),
              ListTile(
                leading: Icon(Icons.visibility, color: Colors.purple),
                title: Text('Activity Status', style: TextStyle(color: Colors.white)),
                subtitle: Text('Show when you\'re active', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                trailing: Switch(
                  value: true,
                  activeColor: Colors.purple,
                  onChanged: (value) {},
                ),
              ),
              Divider(color: Colors.grey[700]),
              ListTile(
                leading: Icon(Icons.block, color: Colors.purple),
                title: Text('Blocked Accounts', style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No blocked accounts'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.comment, color: Colors.purple),
                title: Text('Comments', style: TextStyle(color: Colors.white)),
                subtitle: Text('Control who can comment', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Comment settings'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Help & Support', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.help_outline, color: Colors.purple),
                title: Text('Help Center', style: TextStyle(color: Colors.white)),
                subtitle: Text('Get answers to common questions', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening Help Center...'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
              Divider(color: Colors.grey[700]),
              ListTile(
                leading: Icon(Icons.email, color: Colors.purple),
                title: Text('Contact Us', style: TextStyle(color: Colors.white)),
                subtitle: Text('support@sociallive.app', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening email app...'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
              Divider(color: Colors.grey[700]),
              ListTile(
                leading: Icon(Icons.report_problem, color: Colors.purple),
                title: Text('Report a Problem', style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _showReportProblemDialog();
                },
              ),
              Divider(color: Colors.grey[700]),
              ListTile(
                leading: Icon(Icons.info, color: Colors.purple),
                title: Text('About', style: TextStyle(color: Colors.white)),
                subtitle: Text('Version 1.0.0', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog();
                },
              ),
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

  void _showReportProblemDialog() {
    final problemController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Report a Problem', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please describe the issue you\'re experiencing:',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            SizedBox(height: 16),
            TextField(
              controller: problemController,
              style: TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe the problem...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Problem report submitted. Thank you!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('About Social Live', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_library, color: Colors.purple, size: 64),
            SizedBox(height: 16),
            Text(
              'Social Live',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'A social media platform for sharing videos, photos, and live streams with the world.',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              '© 2024 Social Live. All rights reserved.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear user data and navigate to login
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Colors.purple,
                ),
              );
              // TODO: Navigate to login screen
              // Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  void _showFollowingList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Following', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Text('U${index + 1}', style: TextStyle(color: Colors.white)),
                  ),
                  title: Text('User ${index + 1}', style: TextStyle(color: Colors.white)),
                  subtitle: Text('@user${index + 1}', style: TextStyle(color: Colors.grey)),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                    child: Text('Following', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
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
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Followers', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 15,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Text('F${index + 1}', style: TextStyle(color: Colors.white)),
                  ),
                  title: Text('Follower ${index + 1}', style: TextStyle(color: Colors.white)),
                  subtitle: Text('@follower${index + 1}', style: TextStyle(color: Colors.grey)),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                    child: Text('Follow Back', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLikesInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Total Likes', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: Colors.red, size: 60),
            SizedBox(height: 16),
            Text(
              _formatCount(likesCount),
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Total likes across all your videos',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
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

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: username);
    final bioController = TextEditingController(text: bio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple, width: 2),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: bioController,
              style: TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Bio',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                username = nameController.text;
                bio = bioController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _shareProfile() {
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
            Text(
              'Share Profile',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.copy, color: Colors.purple),
              title: Text('Copy Profile Link', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final profileLink = 'https://sociallive.app/profile/$username';
                await Clipboard.setData(ClipboardData(text: profileLink));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profile link copied to clipboard!'),
                    backgroundColor: Colors.purple,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.qr_code, color: Colors.purple),
              title: Text('Show QR Code', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showQRCode();
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.purple),
              title: Text('Share via...', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final profileLink = 'https://sociallive.app/profile/$username';
                  await Share.share(
                    'Check out my profile on Social Live! $profileLink',
                    subject: 'My Social Live Profile',
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Share failed: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Profile QR Code', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.qr_code_2, size: 150, color: Colors.purple),
              ),
            ),
            SizedBox(height: 16),
            Text(
              username,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Scan to view profile',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
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

  void _shareContent(UserContent content) {
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
            Text(
              'Share ${content.type}',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.copy, color: Colors.purple),
              title: Text('Copy Link', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final contentLink = 'https://sociallive.app/${content.type}/${content.id}';
                await Clipboard.setData(ClipboardData(text: contentLink));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Link copied to clipboard!'),
                    backgroundColor: Colors.purple,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.message, color: Colors.purple),
              title: Text('Send via Message', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final contentLink = 'https://sociallive.app/${content.type}/${content.id}';
                  await Share.share(
                    'Check out this ${content.type} on Social Live! $contentLink',
                    subject: 'Shared from Social Live',
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Share failed: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.purple),
              title: Text('More Options', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final contentLink = 'https://sociallive.app/${content.type}/${content.id}';
                  await Share.share(
                    'Check out this ${content.type} on Social Live! $contentLink',
                    subject: 'Shared from Social Live',
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Share failed: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
