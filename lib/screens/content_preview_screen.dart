import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/video_model.dart';
import '../services/user_content_service.dart';

class ContentPreviewScreen extends StatefulWidget {
  final String contentPath;
  final String contentType;
  final bool isOwner;
  final VideoModel? videoModel;

  const ContentPreviewScreen({
    Key? key,
    required this.contentPath,
    required this.contentType,
    required this.isOwner,
    this.videoModel,
  }) : super(key: key);

  @override
  _ContentPreviewScreenState createState() => _ContentPreviewScreenState();
}

class _ContentPreviewScreenState extends State<ContentPreviewScreen> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  bool _isLiked = false;
  int _likes = 0;
  int _comments = 0;
  int _shares = 0;

  @override
  void initState() {
    super.initState();
    if (widget.contentType == 'video') {
      _initializeVideo();
    }
    if (widget.videoModel != null) {
      _isLiked = widget.videoModel!.isLiked;
      _likes = widget.videoModel!.stats.likes;
      _comments = widget.videoModel!.stats.comments;
      _shares = widget.videoModel!.stats.shares;
    }
  }

  void _initializeVideo() {
    if (widget.contentPath.startsWith('http')) {
      _videoController = VideoPlayerController.network(widget.contentPath);
    } else {
      _videoController = VideoPlayerController.file(File(widget.contentPath));
    }
    
    _videoController!.initialize().then((_) {
      setState(() {});
      _videoController!.setLooping(true);
      _videoController!.play();
      _isPlaying = true;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          if (widget.isOwner)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    _showDeleteDialog();
                    break;
                  case 'share':
                    _shareContent();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'share', child: Text('Share')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _buildContentWidget(),
          ),
          
          // Action buttons for non-owner content
          if (!widget.isOwner)
            Positioned(
              right: 10,
              bottom: 100,
              child: Column(
                children: [
                  _buildActionButton(
                    icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.white,
                    label: _formatCount(_likes),
                    onTap: _toggleLike,
                  ),
                  SizedBox(height: 20),
                  _buildActionButton(
                    icon: Icons.comment,
                    color: Colors.white,
                    label: _formatCount(_comments),
                    onTap: _showComments,
                  ),
                  SizedBox(height: 20),
                  _buildActionButton(
                    icon: Icons.share,
                    color: Colors.white,
                    label: _formatCount(_shares),
                    onTap: _shareContent,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentWidget() {
    switch (widget.contentType) {
      case 'video':
        return _buildVideoPlayer();
      case 'live':
        return _buildLiveStreamPreview();
      case 'photo':
        return _buildPhotoPreview();
      default:
        return Container(
          child: Center(
            child: Text('Unsupported content type', style: TextStyle(color: Colors.white)),
          ),
        );
    }
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator(color: Colors.purple));
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_videoController!.value.isPlaying) {
            _videoController!.pause();
            _isPlaying = false;
          } else {
            _videoController!.play();
            _isPlaying = true;
          }
        });
      },
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),
          ),
          if (!_isPlaying)
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow, color: Colors.white, size: 60),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLiveStreamPreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.live_tv, color: Colors.red, size: 80),
          SizedBox(height: 16),
          Text(
            'Live Stream Ended',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'This live stream has ended',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Image.file(
      File(widget.contentPath),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[900],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo, color: Colors.purple, size: 80),
              SizedBox(height: 16),
              Text('Photo Preview', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
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

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likes++;
      } else {
        _likes--;
      }
    });
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Comments',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'No comments yet',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareContent() async {
    setState(() => _shares++);
    
    try {
      await Share.share(
        'Check out this content on Social Live!',
        subject: 'Shared from Social Live',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing: $e')),
      );
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Delete Content', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this content?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete from UserContentService
              final userContent = UserContentService().allContent;
              final contentToDelete = userContent.firstWhere(
                (c) => c.path == widget.contentPath,
                orElse: () => userContent.first,
              );
              UserContentService().deleteContent(contentToDelete.id);
              
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close preview
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Content deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}