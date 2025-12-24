import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../services/liked_videos_service.dart';
import '../models/video_model.dart';
import 'user_profile_screen.dart';

class SimpleVideoFeedScreen extends StatefulWidget {
  final VideoModel? initialVideo;
  
  const SimpleVideoFeedScreen({Key? key, this.initialVideo}) : super(key: key);

  @override
  _SimpleVideoFeedScreenState createState() => _SimpleVideoFeedScreenState();
}

// Make state class public for external access
typedef SimpleVideoFeedScreenState = _SimpleVideoFeedScreenState;

class _SimpleVideoFeedScreenState extends State<SimpleVideoFeedScreen> {
  PageController _pageController = PageController();
  List<VideoData> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  Map<int, VideoPlayerController> _controllers = {};
  bool _showLikeIcon = false;
  bool _showPlayPauseIcon = false;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  void _showLikeAnimation() {
    setState(() {
      _showLikeIcon = true;
    });
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showLikeIcon = false;
        });
      }
    });
  }

  void _showPlayPauseAnimation(bool isPlaying) {
    setState(() {
      _showPlayPauseIcon = true;
      _isPlaying = isPlaying;
    });
    Future.delayed(Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showPlayPauseIcon = false;
        });
      }
    });
  }

  Future<void> _loadVideos() async {
    final videoUrls = [
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    ];

    final videos = videoUrls.asMap().entries.map((entry) {
      return VideoData(
        id: 'video_${entry.key}',
        videoUrl: entry.value,
        title: 'Video ${entry.key + 1}',
        description: 'Amazing content! #trending #viral',
        creator: 'Creator ${entry.key + 1}',
        likes: 1000 + (entry.key * 500),
        comments: 50,
        shares: 10,
      );
    }).toList();

    setState(() {
      _videos = videos;
      _isLoading = false;
    });

    if (_videos.isNotEmpty) {
      _initializeVideo(0);
    }
  }

  void _initializeVideo(int index) {
    if (_controllers[index] != null) return;

    final video = _videos[index];
    final controller = VideoPlayerController.network(video.videoUrl);
    
    controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _controllers[index] = controller;
        });
        
        if (index == _currentIndex) {
          controller.play();
          controller.setLooping(true);
        }
      }
    });
  }

  void pauseVideos() {
    if (_controllers[_currentIndex] != null) {
      _controllers[_currentIndex]!.pause();
      _showPlayPauseAnimation(false);
    }
  }

  void resumeVideos() {
    if (_controllers[_currentIndex] != null && _controllers[_currentIndex]!.value.isInitialized) {
      _controllers[_currentIndex]!.play();
      _showPlayPauseAnimation(true);
    }
  }

  void _onPageChanged(int index) {
    if (_controllers[_currentIndex] != null) {
      _controllers[_currentIndex]!.pause();
    }

    setState(() {
      _currentIndex = index;
    });

    _initializeVideo(index);
    if (_controllers[index] != null && _controllers[index]!.value.isInitialized) {
      _controllers[index]!.play();
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.purple),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: _onPageChanged,
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          return _buildVideoPage(_videos[index], index);
        },
      ),
    );
  }

  Widget _buildVideoPage(VideoData video, int index) {
    final controller = _controllers[index];
    
    return Stack(
      children: [
        Center(
          child: controller != null && controller.value.isInitialized
              ? GestureDetector(
                  onTap: () {
                    if (controller.value.isPlaying) {
                      controller.pause();
                      _showPlayPauseAnimation(false);
                    } else {
                      controller.play();
                      _showPlayPauseAnimation(true);
                    }
                  },
                  onDoubleTap: () {
                    setState(() {
                      if (!video.isLiked) {
                        video.isLiked = true;
                        video.likes++;
                        LikedVideosService().likeVideo(
                          video.id,
                          video.videoUrl,
                          video.title,
                          video.creator,
                          video.likes,
                        );
                        _showLikeAnimation();
                      }
                    });
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                )
              : Container(
                  color: const Color(0xFF212121),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.purple),
                  ),
                ),
        ),

        // Right side actions
        Positioned(
          right: 10,
          bottom: 140,
          child: Column(
            children: [
              _buildActionButton(
                icon: video.isLiked ? Icons.favorite : Icons.favorite_border,
                color: video.isLiked ? Colors.red : Colors.white,
                label: _formatCount(video.likes),
                onTap: () {
                  setState(() {
                    video.isLiked = !video.isLiked;
                    if (video.isLiked) {
                      video.likes++;
                      LikedVideosService().likeVideo(
                        video.id,
                        video.videoUrl,
                        video.title,
                        video.creator,
                        video.likes,
                      );
                    } else {
                      video.likes--;
                      LikedVideosService().unlikeVideo(video.id);
                    }
                  });
                },
              ),
              SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.comment,
                color: Colors.white,
                label: _formatCount(video.comments),
                onTap: () {
                  _showCommentsBottomSheet(video);
                },
              ),
              SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.share,
                color: Colors.white,
                label: _formatCount(video.shares),
                onTap: () {
                  _showShareOptions(video);
                },
              ),
            ],
          ),
        ),

        // Bottom info
        Positioned(
          left: 10,
          right: 80,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(
                        username: '@${video.creator.toLowerCase().replaceAll(' ', '_')}',
                        userId: video.creator,
                      ),
                    ),
                  );
                },
                child: Text(
                  '@${video.creator.toLowerCase().replaceAll(' ', '_')}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 6),
              Text(
                video.description,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Like animation overlay
        if (_showLikeIcon)
          Center(
            child: AnimatedOpacity(
              opacity: _showLikeIcon ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: Icon(
                Icons.favorite,
                color: Colors.red,
                size: 120,
              ),
            ),
          ),

        // Play/Pause animation overlay
        if (_showPlayPauseIcon)
          Center(
            child: AnimatedOpacity(
              opacity: _showPlayPauseIcon ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
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
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  void _showCommentsBottomSheet(VideoData video) {
    // Pause video when opening comments
    if (_controllers[_currentIndex] != null) {
      _controllers[_currentIndex]!.pause();
    }

    final TextEditingController commentController = TextEditingController();
    List<Comment> comments = [
      Comment(username: 'user123', text: 'Amazing video! 🔥', timeAgo: '2h ago'),
      Comment(username: 'creator_fan', text: 'Love your content!', timeAgo: '5h ago'),
      Comment(username: 'video_lover', text: 'This is so cool! 😍', timeAgo: '1d ago'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[800]!, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${video.comments} Comments',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Resume video when closing comments
                          if (_controllers[_currentIndex] != null) {
                            _controllers[_currentIndex]!.play();
                          }
                        },
                        icon: Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Comments List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.purple,
                              radius: 18,
                              child: Text(
                                comment.username[0].toUpperCase(),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment.username,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        comment.timeAgo,
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    comment.text,
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.favorite_border, color: Colors.grey[500], size: 18),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Comment Input
                Container(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    border: Border(
                      top: BorderSide(color: Colors.grey[800]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.purple,
                        radius: 16,
                        child: Text(
                          'Y',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            filled: true,
                            fillColor: Colors.grey[800],
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.purple, width: 1),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          if (commentController.text.trim().isNotEmpty) {
                            setModalState(() {
                              comments.insert(
                                0,
                                Comment(
                                  username: 'You',
                                  text: commentController.text.trim(),
                                  timeAgo: 'Just now',
                                ),
                              );
                              video.comments++;
                            });
                            setState(() {});
                            commentController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Comment posted!'),
                                backgroundColor: Colors.purple,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.send, color: Colors.purple),
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

  void _showShareOptions(VideoData video) {
    setState(() {
      video.shares++;
    });

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
              'Share to',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareOption(
                  icon: Icons.message,
                  label: 'Messages',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Shared to Messages!'),
                        backgroundColor: Colors.purple,
                      ),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.copy,
                  label: 'Copy Link',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Link copied to clipboard!'),
                        backgroundColor: Colors.purple,
                      ),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.share_outlined,
                  label: 'More',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening share options...'),
                        backgroundColor: Colors.purple,
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class Comment {
  final String username;
  final String text;
  final String timeAgo;

  Comment({
    required this.username,
    required this.text,
    required this.timeAgo,
  });
}

class VideoData {
  final String id;
  final String videoUrl;
  final String title;
  final String description;
  final String creator;
  int likes;
  int comments;
  int shares;
  bool isLiked;

  VideoData({
    required this.id,
    required this.videoUrl,
    required this.title,
    required this.description,
    required this.creator,
    required this.likes,
    required this.comments,
    required this.shares,
    this.isLiked = false,
  });
}
