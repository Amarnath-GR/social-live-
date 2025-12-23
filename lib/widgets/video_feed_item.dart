import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

import 'video_player_widget.dart';
import 'animated_like_button.dart';
import 'comments_modal.dart';
import '../screens/profile_screen.dart';

class VideoFeedItem extends StatefulWidget {
  final Map<String, dynamic> video;
  final bool isVisible;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const VideoFeedItem({
    super.key,
    required this.video,
    required this.isVisible,
    this.onLike,
    this.onComment,
    this.onShare,
  });

  @override
  State<VideoFeedItem> createState() => VideoFeedItemState();
}

class VideoFeedItemState extends State<VideoFeedItem> {
  final GlobalKey<VideoPlayerWidgetState> _videoPlayerKey =
      GlobalKey<VideoPlayerWidgetState>();

  void pauseVideo() {
    _videoPlayerKey.currentState?.pauseVideo();
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsModal(
        postId: widget.video['id']?.toString() ?? '',
        initialCommentCount: widget.video['commentsCount'] ?? 0,
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  void _shareVideo() {
    final content = widget.video['content'] ?? '';
    final username = widget.video['user']?['username'] ?? 'Unknown';

    Share.share(
      'Check out this video by @$username: $content\n\n#SocialLiveMVP',
      subject: 'Amazing video on Social Live!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoUrl = widget.video['mediaUrl'] ?? '';
    final user = widget.video['user'] ?? {};
    final username = user['username'] ?? 'Unknown';
    final avatar = user['avatar'] ?? '';
    final content = widget.video['content'] ?? '';
    final likesCount = widget.video['likesCount'] ?? 0;
    final commentsCount = widget.video['commentsCount'] ?? 0;
    final isLiked = widget.video['isLiked'] ?? false;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        if (videoUrl.isNotEmpty)
          VideoPlayerWidget(
            key: _videoPlayerKey,
            videoUrl: videoUrl,
            isVisible: widget.isVisible,
          )
        else
          Container(
            color: Colors.black,
            child: const Center(
              child: Icon(Icons.video_library,
                  color: Colors.white, size: 64),
            ),
          ),

        // Right side actions
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              // User avatar
              GestureDetector(
                onTap: () => _navigateToProfile(context),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: avatar.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: avatar,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.person,
                                    color: Colors.white),
                          )
                        : const Icon(Icons.person,
                            color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              AnimatedLikeButton(
                isLiked: isLiked,
                likeCount: likesCount,
                onTap: widget.onLike,
              ),
              const SizedBox(height: 16),

              _ActionButton(
                icon: Icons.comment,
                color: Colors.white,
                count: commentsCount,
                onTap: () => _showComments(context),
              ),
              const SizedBox(height: 16),

              _ActionButton(
                icon: Icons.share,
                color: Colors.white,
                onTap: _shareVideo,
              ),
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
                '@$username',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (content.isNotEmpty)
                Text(
                  content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int? count;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black26,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          if (count != null && count! > 0) ...[
            const SizedBox(height: 4),
            Text(
              _formatCount(count!),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
