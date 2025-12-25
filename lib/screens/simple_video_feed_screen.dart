import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import '../services/liked_videos_service.dart';
import '../services/saved_videos_service.dart';
import '../services/api_client.dart';
import '../models/video_model.dart';
import 'user_profile_screen.dart';
import 'user_account_screen.dart';

class SimpleVideoFeedScreen extends StatefulWidget {
  final VideoModel? initialVideo;
  
  const SimpleVideoFeedScreen({Key? key, this.initialVideo}) : super(key: key);

  @override
  SimpleVideoFeedScreenState createState() => SimpleVideoFeedScreenState();
}

// Make state class public for external access
class SimpleVideoFeedScreenState extends State<SimpleVideoFeedScreen> with WidgetsBindingObserver {
  PageController _pageController = PageController();
  List<VideoData> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  Map<int, VideoPlayerController> _controllers = {};
  bool _showLikeIcon = false;
  bool _showPlayPauseIcon = false;
  bool _isOnHomeScreen = true;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SavedVideosService().loadSavedVideos();
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
    try {
      final response = await ApiClient().get('/posts');
      final List<dynamic> data = response.data is Map ? (response.data['posts'] ?? []) : (response.data ?? []);
      final posts = data.where((p) => p['type']?.toString().toUpperCase() == 'VIDEO').toList();
      
      if (posts.isNotEmpty) {
        final videos = posts.map((p) => VideoData(
          id: p['id']?.toString() ?? '',
          videoUrl: p['videoUrl'] ?? p['imageUrl'] ?? '',
          title: p['content'] ?? '',
          description: p['content'] ?? '',
          creator: p['user']?['username'] ?? 'Unknown',
          likes: p['likesCount'] ?? 0,
          comments: p['commentsCount'] ?? 0,
          shares: 0,
        )).toList();

        setState(() {
          _videos = videos;
          _isLoading = false;
        });
        
        if (_videos.isNotEmpty) {
          _initializeVideo(0);
        }
        return;
      }
    } catch (e) {
      // Fallback to sample data
    }

    // Sample videos if backend fails
    setState(() {
      _videos = [
        VideoData(
          id: 'sample1',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          title: 'Sample Video 1',
          description: 'This is a sample video',
          creator: 'Demo User',
          likes: 100,
          comments: 10,
          shares: 5,
        ),
      ];
      _isLoading = false;
    });

    if (_videos.isNotEmpty) {
      _initializeVideo(0);
    }
  }

  void _initializeVideo(int index) {
    if (_controllers[index] != null) return;
    if (index >= _videos.length) return;

    final video = _videos[index];
    if (video.videoUrl.isEmpty) return;
    
    final controller = VideoPlayerController.networkUrl(Uri.parse(video.videoUrl));
    
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
    }).catchError((e) {
      print('Error initializing video: $e');
    });
  }

  void pauseVideos() {
    print('Pausing videos'); // Debug print
    _isOnHomeScreen = false;
    if (_controllers.containsKey(_currentIndex) && 
        _controllers[_currentIndex] != null && 
        _controllers[_currentIndex]!.value.isInitialized) {
      _controllers[_currentIndex]!.pause();
      _showPlayPauseAnimation(false);
    }
  }

  void resumeVideos() {
    print('Resuming videos'); // Debug print
    _isOnHomeScreen = true;
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
    WidgetsBinding.instance.removeObserver(this);
    _controllers.values.forEach((controller) => controller.dispose());
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_controllers[_currentIndex] != null) {
        _controllers[_currentIndex]!.pause();
      }
    } else if (state == AppLifecycleState.resumed && _isOnHomeScreen) {
      if (_controllers[_currentIndex] != null && _controllers[_currentIndex]!.value.isInitialized) {
        _controllers[_currentIndex]!.play();
      }
    }
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
                  onDoubleTap: () async {
                    if (!video.isLiked) {
                      try {
                        await ApiClient().post('/posts/${video.id}/like');
                      } catch (e) {}
                      setState(() {
                        video.isLiked = true;
                        video.likes++;
                      });
                      LikedVideosService().likeVideo(video.id, video.videoUrl, video.title, video.creator, video.likes);
                      _showLikeAnimation();
                    }
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
                onTap: () async {
                  try {
                    if (!video.isLiked) {
                      await ApiClient().post('/posts/${video.id}/like');
                      setState(() {
                        video.isLiked = true;
                        video.likes++;
                      });
                      LikedVideosService().likeVideo(video.id, video.videoUrl, video.title, video.creator, video.likes);
                    } else {
                      await ApiClient().delete('/posts/${video.id}/like');
                      setState(() {
                        video.isLiked = false;
                        video.likes--;
                      });
                      LikedVideosService().unlikeVideo(video.id);
                    }
                  } catch (e) {
                    setState(() {
                      if (!video.isLiked) {
                        video.isLiked = true;
                        video.likes++;
                      } else {
                        video.isLiked = false;
                        video.likes--;
                      }
                    });
                  }
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
                icon: SavedVideosService().isSaved(video.id) ? Icons.bookmark : Icons.bookmark_border,
                color: SavedVideosService().isSaved(video.id) ? Colors.yellow : Colors.white,
                label: 'Save',
                onTap: () {
                  setState(() {
                    if (SavedVideosService().isSaved(video.id)) {
                      SavedVideosService().unsaveVideo(video.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Removed from saved'), backgroundColor: Colors.grey[700]),
                      );
                    } else {
                      SavedVideosService().saveVideo(video.id, video.videoUrl, video.title, video.creator);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Saved to collection'), backgroundColor: Colors.purple),
                      );
                    }
                  });
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
                  // Pause video when navigating to user profile
                  if (_controllers[_currentIndex] != null) {
                    _controllers[_currentIndex]!.pause();
                  }
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserAccountScreen(
                        username: '@${video.creator.toLowerCase().replaceAll(' ', '_')}',
                        displayName: video.creator,
                        isFollowing: false,
                      ),
                    ),
                  ).then((_) {
                    // Resume video when returning from user profile
                    if (_controllers[_currentIndex] != null) {
                      _controllers[_currentIndex]!.play();
                    }
                  });
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
                                      GestureDetector(
                                        onTap: () {
                                          // Pause video when navigating to user profile from comments
                                          if (_controllers[_currentIndex] != null) {
                                            _controllers[_currentIndex]!.pause();
                                          }
                                          
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => UserAccountScreen(
                                                username: '@${comment.username}',
                                                displayName: comment.username,
                                                isFollowing: false,
                                              ),
                                            ),
                                          ).then((_) {
                                            // Resume video when returning
                                            if (_controllers[_currentIndex] != null) {
                                              _controllers[_currentIndex]!.play();
                                            }
                                          });
                                        },
                                        child: Text(
                                          comment.username,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
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
                        onPressed: () async {
                          if (commentController.text.trim().isNotEmpty) {
                            try {
                              await ApiClient().post('/posts/${video.id}/comments', data: {'content': commentController.text.trim()});
                            } catch (e) {}
                            setModalState(() {
                              comments.insert(0, Comment(username: 'You', text: commentController.text.trim(), timeAgo: 'Just now'));
                              video.comments++;
                            });
                            setState(() {});
                            commentController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Comment posted!'), backgroundColor: Colors.purple, duration: Duration(seconds: 2)),
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
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      await Share.share(
                        'Check out this amazing video: ${video.title}\n${video.videoUrl}',
                        subject: 'Shared from Social Live',
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error sharing: $e')),
                      );
                    }
                  },
                ),
                _buildShareOption(
                  icon: Icons.copy,
                  label: 'Copy Link',
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      await Clipboard.setData(ClipboardData(text: video.videoUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Link copied to clipboard!'),
                          backgroundColor: Colors.purple,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error copying link: $e')),
                      );
                    }
                  },
                ),
                _buildShareOption(
                  icon: Icons.share_outlined,
                  label: 'More',
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      await Share.share(
                        'Check out this video on Social Live: ${video.title}\n${video.videoUrl}',
                        subject: 'Shared from Social Live',
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error sharing: $e')),
                      );
                    }
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
