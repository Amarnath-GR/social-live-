import 'package:flutter/material.dart';
import '../services/liked_videos_service.dart';

class VideoReelScreen extends StatefulWidget {
  final List<Map<String, dynamic>> posts;
  final int initialIndex;

  const VideoReelScreen({
    super.key,
    required this.posts,
    required this.initialIndex,
  });

  @override
  State<VideoReelScreen> createState() => _VideoReelScreenState();
}

class _VideoReelScreenState extends State<VideoReelScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final LikedVideosService _likedVideosService = LikedVideosService();
  Map<String, bool> _likedPosts = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _loadLikedStatus();
  }

  void _loadLikedStatus() {
    for (var post in widget.posts) {
      final postId = post['id']?.toString() ?? '';
      _likedPosts[postId] = _likedVideosService.isLiked(postId);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.posts.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          final post = widget.posts[index];
          return _buildVideoPage(post);
        },
      ),
    );
  }

  Widget _buildVideoPage(Map<String, dynamic> post) {
    return Stack(
      children: [
        // Video placeholder
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[900],
          child: post['thumbnailUrl'] != null
              ? Image.network(
                  post['thumbnailUrl'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.video_library, color: Colors.white54, size: 100),
                )
              : const Icon(Icons.video_library, color: Colors.white54, size: 100),
        ),

        // Top gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
        ),

        // Back button
        Positioned(
          top: 50,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // Right side actions
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              _buildLikeButton(post),
              const SizedBox(height: 20),
              _buildActionButton(Icons.comment, '${post['comments'] ?? 0}', () {}),
              const SizedBox(height: 20),
              _buildActionButton(Icons.share, 'Share', () {}),
              const SizedBox(height: 20),
              _buildActionButton(Icons.more_vert, '', () {}),
            ],
          ),
        ),

        // Bottom info
        Positioned(
          left: 16,
          right: 80,
          bottom: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${post['user']?['username'] ?? 'unknown'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (post['caption'] != null)
                Text(
                  post['caption'],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showAudioOptions(post),
                      child: Text(
                        post['audio'] ?? 'Original sound',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLikeButton(Map<String, dynamic> post) {
    final postId = post['id']?.toString() ?? '';
    final isLiked = _likedPosts[postId] ?? false;
    final likes = post['likes'] ?? 0;

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : Colors.white,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                if (isLiked) {
                  _likedPosts[postId] = false;
                  _likedVideosService.unlikeVideo(postId);
                } else {
                  _likedPosts[postId] = true;
                  _likedVideosService.likeVideo(
                    postId,
                    post['videoUrl'] ?? '',
                    post['caption'] ?? 'Video',
                    post['user']?['username'] ?? 'unknown',
                    likes,
                  );
                }
              });
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$likes',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 24),
            onPressed: onTap,
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ],
    );
  }

  void _showAudioOptions(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.music_note, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['audio'] ?? 'Original sound',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '@${post['user']?['username'] ?? 'unknown'}',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


}