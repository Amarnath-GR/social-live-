import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'simple_camera_screen.dart';
import '../services/video_service.dart';
import '../models/video_model.dart';

class SimpleProfileScreen extends StatefulWidget {
  @override
  _SimpleProfileScreenState createState() => _SimpleProfileScreenState();
}

class _SimpleProfileScreenState extends State<SimpleProfileScreen> {
  // Dynamic stats
  int followingCount = 234;
  int followersCount = 12543;
  int likesCount = 456789;
  
  final VideoService _videoService = VideoService();
  List<VideoModel> uploadedVideos = [];
  List<VideoModel> likedVideos = [];
  bool isLoadingVideos = true;
  bool isLoadingLiked = true;

  @override
  void initState() {
    super.initState();
    _loadUserVideos();
    _loadLikedVideos();
  }

  Future<void> _loadUserVideos() async {
    try {
      setState(() => isLoadingVideos = true);
      final videos = await _videoService.getUserVideos(null);
      setState(() {
        uploadedVideos = videos;
        isLoadingVideos = false;
      });
    } catch (e) {
      print('Error loading user videos: $e');
      setState(() => isLoadingVideos = false);
    }
  }

  Future<void> _loadLikedVideos() async {
    try {
      setState(() => isLoadingLiked = true);
      final videos = await _videoService.getLikedVideos(null);
      setState(() {
        likedVideos = videos;
        isLoadingLiked = false;
      });
    } catch (e) {
      print('Error loading liked videos: $e');
      setState(() => isLoadingLiked = false);
    }
  }

  Future<void> _refreshProfile() async {
    await Future.wait([
      _loadUserVideos(),
      _loadLikedVideos(),
    ]);
    setState(() {
      // Refresh stats
      followersCount += 10;
      likesCount += 100;
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
              '@myusername',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Content Creator & Social Media Enthusiast',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            SizedBox(height: 20),
            
            // Stats Row - Dynamic values
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Edit Profile clicked!')),
                            );
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
                          onPressed: () {
                            _shareProfile();
                          },
                          icon: Icon(Icons.share, color: Colors.white),
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
                                builder: (context) => SimpleCameraScreen(
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
                                builder: (context) => SimpleCameraScreen(
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
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[400],
                    tabs: [
                      Tab(icon: Icon(Icons.grid_on), text: 'Videos'),
                      Tab(icon: Icon(Icons.favorite), text: 'Liked'),
                    ],
                  ),
                  Container(
                    height: 400,
                    child: TabBarView(
                      children: [
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
    if (isLoadingVideos) {
      return Center(
        child: CircularProgressIndicator(color: Colors.purple),
      );
    }

    if (uploadedVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, color: Colors.grey[600], size: 64),
            SizedBox(height: 16),
            Text(
              'No videos yet',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to create your first video',
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
      itemCount: uploadedVideos.length,
      itemBuilder: (context, index) {
        final video = uploadedVideos[index];
        return GestureDetector(
          onTap: () {
            _playVideo(video);
          },
          onLongPress: () {
            _showVideoOptions(video, index);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                // Thumbnail image
                if (video.thumbnailUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      video.thumbnailUrl!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: Center(
                            child: Icon(Icons.video_library, color: Colors.grey[600], size: 32),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.purple,
                          ),
                        );
                      },
                    ),
                  ),
                // Play icon overlay
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
                // Duration
                if (video.duration != null)
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
                        _formatDuration(video.duration!),
                        style: TextStyle(color: Colors.white, fontSize: 10),
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
                        Icon(Icons.play_arrow, color: Colors.white, size: 10),
                        SizedBox(width: 2),
                        Text(
                          _formatCount(video.stats.views),
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
                // More options
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      _showVideoOptions(video, index);
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

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _playVideo(VideoModel video) {
    // Play video immediately - no intermediate screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing video...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showVideoOptions(VideoModel video, int index) {
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
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Reel', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(video, index);
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

  void _confirmDelete(Map<String, dynamic> video, int index) {
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
              setState(() {
                uploadedVideos.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildLikedGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(Icons.favorite, color: Colors.red, size: 32),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Text(
                  '${(index + 1) * 8}K',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Settings clicked!')),
              );
            }),
            _buildSettingsItem(Icons.privacy_tip, 'Privacy', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Privacy clicked!')),
              );
            }),
            _buildSettingsItem(Icons.help, 'Help', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Help clicked!')),
              );
            }),
            _buildSettingsItem(Icons.logout, 'Logout', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Logout clicked!')),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
