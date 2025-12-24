import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../services/api_service.dart';
import '../services/real_video_service.dart';
import '../models/video_model.dart';
import 'reel_camera_screen.dart';

class VideoFeedScreen extends StatefulWidget {
  @override
  _VideoFeedScreenState createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> with TickerProviderStateMixin {
  PageController _pageController = PageController();
  List<VideoModel> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  Map<int, VideoPlayerController> _controllers = {};
  Map<int, ChewieController> _chewieControllers = {};
  static const int _maxCachedControllers = 5; // Limit memory usage
  
  // Auto-scroll functionality
  Timer? _autoScrollTimer;
  Map<int, int> _playCount = {}; // Track how many times each video has played
  bool _isManualScrolling = false;
  
  // Play/Pause icon overlay
  bool _showPlayPauseIcon = false;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      // Load real videos from curated sources
      final realVideos = await RealVideoService.getRealVideos(limit: 20);
      
      setState(() {
        _videos = realVideos;
        _isLoading = false;
      });

      // Initialize first video
      if (_videos.isNotEmpty) {
        _initializeVideo(0);
      }
    } catch (e) {
      print('Error loading videos: $e');
      setState(() {
        _isLoading = false;
      });
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
        
        // Create Chewie controller for better video controls
        final chewieController = ChewieController(
          videoPlayerController: controller,
          autoPlay: index == _currentIndex,
          looping: true,
          showControls: false, // Hide controls for TikTok-like experience
          aspectRatio: 9/16, // Vertical video aspect ratio
          allowFullScreen: false,
          allowMuting: false,
          showControlsOnInitialize: false,
        );
        
        _chewieControllers[index] = chewieController;
        
        // Auto-play if this is the current video
        if (index == _currentIndex) {
          controller.play();
          _startAutoScrollTimer(index);
        }
        
        // Listen for video completion to handle auto-scroll
        controller.addListener(() => _onVideoPositionChanged(index));
      }
    }).catchError((error) {
      print('Error initializing video $index: $error');
    });

    // Clean up old controllers to prevent memory leaks
    _cleanupControllers(index);
  }

  void _onVideoPositionChanged(int index) {
    final controller = _controllers[index];
    if (controller == null || !controller.value.isInitialized) return;
    
    final position = controller.value.position;
    final duration = controller.value.duration;
    
    // Check if video completed
    if (position >= duration && duration.inMilliseconds > 0) {
      _playCount[index] = (_playCount[index] ?? 0) + 1;
      
      // Auto-scroll after video plays twice (unless manually scrolling)
      if (_playCount[index]! >= 2 && !_isManualScrolling && index == _currentIndex) {
        _autoScrollToNext();
      }
    }
  }

  void _startAutoScrollTimer(int index) {
    _autoScrollTimer?.cancel();
    
    final video = _videos[index];
    final duration = Duration(milliseconds: video.duration ?? 30000); // Default 30 seconds if null
    
    // Set timer for 2x video duration for auto-scroll
    _autoScrollTimer = Timer(duration * 2, () {
      if (!_isManualScrolling && index == _currentIndex) {
        _autoScrollToNext();
      }
    });
  }

  void _autoScrollToNext() {
    if (_currentIndex < _videos.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _cleanupControllers(int currentIndex) {
    final controllersToRemove = <int>[];
    
    _controllers.forEach((index, controller) {
      // Keep only current video ± 2 positions
      if ((index - currentIndex).abs() > 2) {
        controllersToRemove.add(index);
      }
    });

    for (final index in controllersToRemove) {
      _controllers[index]?.dispose();
      _chewieControllers[index]?.dispose();
      _controllers.remove(index);
      _chewieControllers.remove(index);
    }

    // Enforce maximum cache size
    if (_controllers.length > _maxCachedControllers) {
      final sortedIndexes = _controllers.keys.toList()
        ..sort((a, b) => (a - currentIndex).abs().compareTo((b - currentIndex).abs()));
      
      for (int i = _maxCachedControllers; i < sortedIndexes.length; i++) {
        final index = sortedIndexes[i];
        _controllers[index]?.dispose();
        _chewieControllers[index]?.dispose();
        _controllers.remove(index);
        _chewieControllers.remove(index);
      }
    }
  }

  void _onPageChanged(int index) {
    // Mark as manual scrolling
    _isManualScrolling = true;
    
    // Reset manual scrolling flag after a delay
    Timer(Duration(milliseconds: 500), () {
      _isManualScrolling = false;
    });
    
    // Cancel auto-scroll timer
    _autoScrollTimer?.cancel();
    
    // Pause previous video
    if (_controllers[_currentIndex] != null) {
      _controllers[_currentIndex]!.pause();
    }

    setState(() {
      _currentIndex = index;
    });

    // Initialize and play current video
    _initializeVideo(index);
    if (_controllers[index] != null && _controllers[index]!.value.isInitialized) {
      _controllers[index]!.play();
      _startAutoScrollTimer(index);
    }

    // Preload next videos
    if (index + 1 < _videos.length) {
      _initializeVideo(index + 1);
    }
    if (index + 2 < _videos.length) {
      _initializeVideo(index + 2);
    }

    // Record view
    _recordView(_videos[index].id);
  }

  Future<void> _recordView(String videoId) async {
    try {
      final apiService = ApiService();
      await apiService.recordVideoView(videoId, 5000); // 5 seconds default
    } catch (e) {
      print('Error recording view: $e');
    }
  }

  Future<void> _likeVideo(String videoId) async {
    try {
      final apiService = ApiService();
      final result = await apiService.likeVideo(videoId);
      
      // Update local state
      setState(() {
        final videoIndex = _videos.indexWhere((v) => v.id == videoId);
        if (videoIndex != -1) {
          _videos[videoIndex].isLiked = result['liked'];
          if (result['liked']) {
            _videos[videoIndex].stats.likes++;
          } else {
            _videos[videoIndex].stats.likes--;
          }
        }
      });

      // Show heart animation
      _showHeartAnimation();
    } catch (e) {
      print('Error liking video: $e');
    }
  }

  void _showHeartAnimation() {
    // TODO: Implement heart animation overlay
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

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controllers.values.forEach((controller) {
      controller.dispose();
    });
    _chewieControllers.values.forEach((controller) {
      controller.dispose();
    });
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Loading amazing videos...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_videos.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library, color: Colors.white, size: 64),
              SizedBox(height: 16),
              Text(
                'No videos available',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Pull down to refresh',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: _refreshVideos,
        color: Colors.white,
        backgroundColor: Colors.black,
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: _onPageChanged,
          itemCount: _videos.length,
          itemBuilder: (context, index) {
            // Load more videos when approaching the end
            if (index == _videos.length - 3) {
              _loadMoreVideos();
            }
            return _buildVideoPage(_videos[index], index);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReelCameraScreen()),
          );
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Future<void> _refreshVideos() async {
    setState(() {
      _isLoading = true;
    });
    
    // Clear existing videos and controllers
    _controllers.values.forEach((controller) => controller.dispose());
    _chewieControllers.values.forEach((controller) => controller.dispose());
    _controllers.clear();
    _chewieControllers.clear();
    _playCount.clear();
    _autoScrollTimer?.cancel();
    
    await _loadVideos();
  }

  Future<void> _loadMoreVideos() async {
    try {
      final moreVideos = await RealVideoService.getRealVideos(limit: 10);
      setState(() {
        _videos.addAll(moreVideos);
      });
    } catch (e) {
      print('Error loading more videos: $e');
    }
  }

  Widget _buildVideoPage(VideoModel video, int index) {
    final controller = _controllers[index];
    
    return Stack(
      children: [
        // Video Player
        Center(
          child: controller != null && controller.value.isInitialized
              ? GestureDetector(
                  onTap: () {
                    // Toggle play/pause
                    if (controller.value.isPlaying) {
                      controller.pause();
                      _autoScrollTimer?.cancel();
                      _showPlayPauseAnimation(false);
                    } else {
                      controller.play();
                      _startAutoScrollTimer(index);
                      _showPlayPauseAnimation(true);
                    }
                  },
                  onDoubleTap: () {
                    // Double tap to like
                    _likeVideo(video.id);
                  },
                  child: Container(
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
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[900],
                  child: video.thumbnailUrl != null
                      ? Image.network(
                          video.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error, color: Colors.white, size: 48),
                                  SizedBox(height: 16),
                                  Text(
                                    'Failed to load video',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Loading video...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                ),
        ),

        // Top indicators
        Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Play count indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Play ${_playCount[index] ?? 0}/2',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              // Auto-scroll indicator
              if (!_isManualScrolling && (_playCount[index] ?? 0) >= 1)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.autorenew, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Auto-scroll',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          right: 10,
          bottom: 100,
          child: Column(
            children: [
              // Like button
              _buildActionButton(
                icon: video.isLiked ? Icons.favorite : Icons.favorite_border,
                color: video.isLiked ? Colors.red : Colors.white,
                label: _formatCount(video.stats.likes),
                onTap: () => _likeVideo(video.id),
              ),
              SizedBox(height: 20),
              
              // Comment button
              _buildActionButton(
                icon: Icons.comment,
                color: Colors.white,
                label: _formatCount(video.stats.comments),
                onTap: () {
                  // TODO: Open comments
                },
              ),
              SizedBox(height: 20),
              
              // Share button
              _buildActionButton(
                icon: Icons.share,
                color: Colors.white,
                label: _formatCount(video.stats.shares),
                onTap: () {
                  // TODO: Share video
                },
              ),
              SizedBox(height: 20),
              
              // Creator avatar
              CircleAvatar(
                radius: 25,
                backgroundImage: video.user.avatar != null
                    ? NetworkImage(video.user.avatar!)
                    : null,
                child: video.user.avatar == null
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),

        // Video progress indicator
        if (controller != null && controller.value.isInitialized)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: false,
                colors: VideoProgressColors(
                  playedColor: Colors.white,
                  bufferedColor: Colors.white.withOpacity(0.3),
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ),

        // Bottom info
        Positioned(
          left: 10,
          right: 80,
          bottom: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Creator info
              Row(
                children: [
                  Text(
                    '@${video.user.username}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (video.user.verified) ...[
                    SizedBox(width: 5),
                    Icon(
                      Icons.verified,
                      color: Colors.blue,
                      size: 16,
                    ),
                  ],
                ],
              ),
              SizedBox(height: 8),
              
              // Description
              Text(
                video.content,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              
              // Hashtags
              if (video.hashtags.isNotEmpty)
                Wrap(
                  children: video.hashtags.map((hashtag) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text(
                        '#$hashtag',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
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
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
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
}