import 'package:flutter/material.dart';
import '../services/video_feed_service.dart';
import '../widgets/video_feed_item.dart';

class VideoFeedScreen extends StatefulWidget {
  final bool isActiveTab;
  
  const VideoFeedScreen({super.key, this.isActiveTab = true});

  @override
  State<VideoFeedScreen> createState() => VideoFeedScreenState();
}

class VideoFeedScreenState extends State<VideoFeedScreen> {
  final PageController _pageController = PageController();
  List<Map<String, dynamic>> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMore = true;
  GlobalKey<VideoFeedItemState>? _currentVideoKey;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VideoFeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActiveTab != oldWidget.isActiveTab) {
      if (!widget.isActiveTab) {
        // Pause video when tab becomes inactive
        pauseCurrentVideo();
      } else {
        // Resume video when tab becomes active
        setState(() {});
      }
    }
  }

  void pauseCurrentVideo() {
    _currentVideoKey?.currentState?.pauseVideo();
  }

  Map<String, dynamic>? getCurrentVideo() {
    if (_currentIndex < _videos.length) {
      return _videos[_currentIndex];
    }
    return null;
  }

  Future<void> _loadVideos({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _hasError = false;
        _currentPage = 1;
      }
    });

    try {
      final result = await VideoFeedService.getVideoFeed(
        page: refresh ? 1 : _currentPage,
        limit: 10,
      );

      if (result['success']) {
        final newVideos = List<Map<String, dynamic>>.from(result['videos']);
        
        setState(() {
          if (refresh) {
            _videos = newVideos;
          } else {
            _videos.addAll(newVideos);
          }
          _hasMore = result['hasMore'] ?? false;
          _currentPage++;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = result['message'] ?? 'Failed to load videos';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Network error occurred';
        _isLoading = false;
      });
    }
  }

  Future<void> _likeVideo(int index) async {
    if (index >= _videos.length) return;
    
    final video = _videos[index];
    final videoId = video['id']?.toString();
    
    if (videoId == null) return;

    final result = await VideoFeedService.likeVideo(videoId);
    
    if (result['success']) {
      setState(() {
        _videos[index]['isLiked'] = !(_videos[index]['isLiked'] ?? false);
        final currentLikes = _videos[index]['likesCount'] ?? 0;
        _videos[index]['likesCount'] = _videos[index]['isLiked'] 
            ? currentLikes + 1 
            : currentLikes - 1;
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Load more videos when near the end
    if (index >= _videos.length - 2 && _hasMore && !_isLoading) {
      _loadVideos();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _videos.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _loadVideos(refresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_videos.isEmpty && _isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_videos.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library_outlined, color: Colors.white, size: 64),
              SizedBox(height: 16),
              Text(
                'No videos available',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: _videos.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _videos.length) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final video = _videos[index];
              final isVisible = index == _currentIndex;
              final videoKey = GlobalKey<VideoFeedItemState>();
              
              if (isVisible) {
                _currentVideoKey = videoKey;
              }

              return VideoFeedItem(
                key: videoKey,
                video: video,
                isVisible: isVisible && widget.isActiveTab,
                onLike: () => _likeVideo(index),
                onComment: () {},
                onShare: () {},
              );
            },
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black26,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),

          if (_isLoading && _videos.isNotEmpty)
            const Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
