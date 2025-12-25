import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/user_models.dart';
import '../services/profile_service.dart';
import '../widgets/comments_modal.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;
  final User? user;

  const PostDetailScreen({
    Key? key,
    required this.post,
    this.user,
  }) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late PostModel _post;
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final result = await ProfileService.getCurrentUser();
      if (result['success'] == true) {
        _currentUser = result['user'] as User;
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
    setState(() {
      _isLoading = false;
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPostHeader(),
                        _buildPostContent(),
                        _buildPostActions(),
                        _buildPostStats(),
                        _buildPostDescription(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[800],
            backgroundImage: widget.user?.avatar != null
                ? NetworkImage(widget.user!.avatar!)
                : null,
            child: widget.user?.avatar == null
                ? Icon(Icons.person, color: Colors.white, size: 20)
                : null,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.user?.username ?? 'Unknown User',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (widget.user?.kycVerified == true) ...[
                      SizedBox(width: 4),
                      Icon(Icons.verified, color: Colors.blue, size: 16),
                    ],
                  ],
                ),
                Text(
                  _formatTimeAgo(_post.createdAt),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Container(
      width: double.infinity,
      height: 400,
      color: Colors.grey[900],
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_post.type == 'video' && _post.thumbnailUrl != null)
            Image.network(
              _post.thumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            )
          else if (_post.type == 'image' && _post.imageUrl != null)
            Image.network(
              _post.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            )
          else
            _buildPlaceholder(),
          
          if (_post.type == 'video')
            Center(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Icon(
          _post.type == 'video' ? Icons.video_library : Icons.image,
          color: Colors.grey[600],
          size: 60,
        ),
      ),
    );
  }

  Widget _buildPostActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleLike,
            child: Icon(
              _post.isLiked ? Icons.favorite : Icons.favorite_border,
              color: _post.isLiked ? Colors.red : Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 20),
          GestureDetector(
            onTap: _showComments,
            child: Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 26,
            ),
          ),
          SizedBox(width: 20),
          GestureDetector(
            onTap: _sharePost,
            child: Icon(
              Icons.share,
              color: Colors.white,
              size: 26,
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: _bookmarkPost,
            child: Icon(
              Icons.bookmark_border,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostStats() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_post.stats.likes > 0)
            Text(
              '${_formatCount(_post.stats.likes)} likes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          if (_post.stats.views > 0) ...[
            SizedBox(height: 4),
            Text(
              '${_formatCount(_post.stats.views)} views',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${widget.user?.username ?? 'user'} ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text: _post.content,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          if (_post.hashtags.isNotEmpty) ...[
            SizedBox(height: 8),
            Wrap(
              children: _post.hashtags.map((hashtag) => Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text(
                  '#$hashtag',
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
              )).toList(),
            ),
          ],
          SizedBox(height: 8),
          Text(
            'Post ID: ${_post.id}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      _post.isLiked = !_post.isLiked;
      if (_post.isLiked) {
        _post.stats.likes++;
      } else {
        _post.stats.likes--;
      }
    });
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsModal(postId: _post.id),
    );
  }

  void _sharePost() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post shared!'),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  void _bookmarkPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post saved!'),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  void _showMoreOptions() {
    final bool isOwnPost = _currentUser?.id == _post.userId;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            if (isOwnPost) ...[
              _buildBottomSheetItem(
                icon: Icons.delete,
                title: 'Delete Post',
                color: Colors.red,
                onTap: _deletePost,
              ),
              _buildBottomSheetItem(
                icon: Icons.edit,
                title: 'Edit Post',
                onTap: _editPost,
              ),
            ] else ...[
              _buildBottomSheetItem(
                icon: Icons.report,
                title: 'Report Post',
                color: Colors.red,
                onTap: _reportPost,
              ),
            ],
            _buildBottomSheetItem(
              icon: Icons.copy,
              title: 'Copy Link',
              onTap: _copyLink,
            ),
            _buildBottomSheetItem(
              icon: Icons.share,
              title: 'Share Post',
              onTap: () {
                Navigator.pop(context);
                _sharePost();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetItem({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white),
      title: Text(
        title,
        style: TextStyle(color: color ?? Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  void _deletePost() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Delete Post', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true); // Return true to indicate deletion
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Post deleted'),
                  backgroundColor: Colors.grey[800],
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editPost() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit post feature coming soon'),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  void _reportPost() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post reported'),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  void _copyLink() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link copied to clipboard'),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
}