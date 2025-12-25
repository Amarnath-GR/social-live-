import 'package:flutter/material.dart';
import 'dart:io';
import 'fullscreen_video_player.dart';
import '../services/following_service.dart';
import '../services/real_video_service.dart';
import '../services/post_storage_service.dart';
import '../models/video_model.dart';

class UserAccountScreen extends StatefulWidget {
  final String username;
  final String displayName;
  final bool isFollowing;
  final String? userId;

  const UserAccountScreen({
    Key? key,
    required this.username,
    required this.displayName,
    this.isFollowing = false,
    this.userId,
  }) : super(key: key);

  @override
  _UserAccountScreenState createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  bool isFollowing = false;
  int followingCount = 156;
  int followersCount = 8234;
  int likesCount = 234567;
  List<Map<String, dynamic>> userPosts = [];

  @override
  void initState() {
    super.initState();
    isFollowing = FollowingService().isFollowing(widget.username);
    _generateMockPosts();
  }

  void _generateMockPosts() {
    // Load real posts from storage
    _loadUserPosts();
  }
  
  Future<void> _loadUserPosts() async {
    final posts = await PostStorageService.getUserPosts(widget.userId ?? 'other_user');
    setState(() {
      userPosts = posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(widget.username, style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () => _showMoreOptions(),
            icon: Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Text(
                  widget.displayName.substring(0, 2).toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16),
              Text(
                widget.displayName,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                widget.username,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Content creator and social media enthusiast 🎬✨',
                style: TextStyle(color: Colors.grey[300], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Following', _formatCount(followingCount)),
                  _buildStat('Followers', _formatCount(followersCount)),
                  _buildStat('Likes', _formatCount(likesCount)),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _toggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFollowing ? Colors.grey[700] : Colors.purple,
                          minimumSize: Size(0, 45),
                        ),
                        child: Text(
                          isFollowing ? 'Following' : 'Follow',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[600]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () => _sendMessage(),
                        icon: Icon(Icons.message, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[400],
                      tabs: [
                        Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
                        Tab(icon: Icon(Icons.favorite), text: 'Liked'),
                      ],
                    ),
                    Container(
                      height: 400,
                      child: TabBarView(
                        children: [
                          _buildPostsGrid(),
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

  Widget _buildPostsGrid() {
    if (userPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, color: Colors.grey[600], size: 64),
            SizedBox(height: 16),
            Text('No posts yet', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1.0,
      ),
      itemCount: userPosts.length,
      itemBuilder: (context, index) {
        final post = userPosts[index];
        return GestureDetector(
          onTap: () {
            if (post['videoPath'] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullscreenVideoPlayer(
                    videoPath: post['videoPath'],
                    duration: post['duration'] ?? 30,
                  ),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
            ),
            child: Stack(
              children: [
                _buildPostThumbnail(post),
                if (post['type'] == 'video')
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(Icons.play_arrow, color: Colors.white, size: 16),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostThumbnail(Map<String, dynamic> post) {
    final thumbnailPath = post['thumbnailPath'];
    if (thumbnailPath != null && thumbnailPath.isNotEmpty && File(thumbnailPath).existsSync()) {
      return Image.file(
        File(thumbnailPath),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return _buildFallbackThumbnail(post['type']?.toString() ?? 'video');
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
          ] : [
            Colors.blue.withOpacity(0.8),
            Colors.indigo.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          type == 'video' ? Icons.play_arrow : Icons.photo,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildLikedGrid() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, color: Colors.grey[600], size: 64),
          SizedBox(height: 16),
          Text('Private', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
          SizedBox(height: 8),
          Text('This user\'s liked posts are private', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  void _toggleFollow() async {
    if (isFollowing) {
      await FollowingService().unfollowUser(widget.username);
      setState(() {
        isFollowing = false;
        followersCount--;
      });
    } else {
      await FollowingService().followUser(widget.username, widget.displayName);
      setState(() {
        isFollowing = true;
        followersCount++;
      });
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFollowing ? 'Following ${widget.displayName}' : 'Unfollowed ${widget.displayName}'),
        backgroundColor: isFollowing ? Colors.green : Colors.grey,
      ),
    );
  }

  void _sendMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Message feature coming soon!')),
    );
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
              leading: Icon(Icons.report, color: Colors.red),
              title: Text('Report', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User reported')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: Colors.red),
              title: Text('Block', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User blocked')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.white),
              title: Text('Share Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile shared')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}