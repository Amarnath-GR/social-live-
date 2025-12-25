import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';

class ProfilePostViewer extends StatefulWidget {
  final List<VideoModel> posts;
  final int initialIndex;

  const ProfilePostViewer({
    super.key,
    required this.posts,
    required this.initialIndex,
  });

  @override
  State<ProfilePostViewer> createState() => _ProfilePostViewerState();
}

class _ProfilePostViewerState extends State<ProfilePostViewer> {
  late PageController _pageController;
  int _currentIndex = 0;
  Map<int, VideoPlayerController?> _controllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeVideo(_currentIndex);
  }

  void _initializeVideo(int index) {
    if (_controllers[index] != null) return;
    
    final post = widget.posts[index];
    if (!post.isVideo) return;
    
    final videoUrl = post.videoUrl;
    if (videoUrl.isEmpty) return;

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _controllers[index] = controller;
      
      controller.initialize().then((_) {
        if (mounted && _currentIndex == index) {
          controller.play();
          controller.setLooping(true);
          setState(() {});
        }
      });
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  void _onPageChanged(int index) {
    _controllers[_currentIndex]?.pause();
    
    setState(() {
      _currentIndex = index;
    });
    
    _initializeVideo(index);
    if (_controllers[index]?.value.isInitialized == true) {
      _controllers[index]?.play();
    }
    
    if (index + 1 < widget.posts.length) {
      _initializeVideo(index + 1);
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller?.dispose());
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: widget.posts.length,
            itemBuilder: (context, index) {
              return _buildPostPage(widget.posts[index], index);
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostPage(VideoModel post, int index) {
    final isVideo = post.isVideo;
    final controller = _controllers[index];
    final isInitialized = controller?.value.isInitialized ?? false;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (isVideo)
          isInitialized
              ? Center(
                  child: AspectRatio(
                    aspectRatio: controller!.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                )
              : (post.thumbnailUrl != null
                  ? Image.network(
                      post.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
                    )
                  : Container(color: Colors.grey[900]))
        else
          post.thumbnailUrl != null
              ? Image.network(
                  post.thumbnailUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[900],
                    child: Center(
                      child: Icon(Icons.broken_image, color: Colors.grey, size: 64),
                    ),
                  ),
                )
              : Container(color: Colors.grey[900]),
        if (isVideo && !isInitialized)
          Center(child: CircularProgressIndicator(color: Colors.white)),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          left: 16,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.purple,
                    child: Text(
                      post.user.displayName[0].toUpperCase(),
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '@${post.user.username}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                post.content,
                style: TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 80,
          right: 16,
          child: Column(
            children: [
              _buildActionButton(
                Icons.favorite,
                post.stats.likes.toString(),
                post.isLiked ? Colors.red : Colors.white,
                () {
                  setState(() {
                    post.isLiked = !post.isLiked;
                    post.stats.likes += post.isLiked ? 1 : -1;
                  });
                },
              ),
              SizedBox(height: 20),
              _buildActionButton(
                Icons.comment,
                post.stats.comments.toString(),
                Colors.white,
                () {},
              ),
              SizedBox(height: 20),
              _buildActionButton(
                Icons.share,
                post.stats.shares.toString(),
                Colors.white,
                () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
