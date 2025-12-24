import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/user_content_service.dart';

class ContentPreviewScreen extends StatefulWidget {
  final UserContent content;
  final String username;

  const ContentPreviewScreen({
    Key? key,
    required this.content,
    required this.username,
  }) : super(key: key);

  @override
  _ContentPreviewScreenState createState() => _ContentPreviewScreenState();
}

class _ContentPreviewScreenState extends State<ContentPreviewScreen> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  bool _showPlayPauseIcon = false;

  @override
  void initState() {
    super.initState();
    if (widget.content.type == 'video') {
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    // Use sample video paths
    final sampleVideos = [
      'assets/videos/sample1.mp4',
      'assets/videos/sample2.mp4',
      'assets/videos/sample3.mp4',
    ];
    
    final videoIndex = widget.content.id.hashCode % sampleVideos.length;
    final videoPath = sampleVideos[videoIndex];
    
    _videoController = VideoPlayerController.asset(videoPath);
    _videoController!.initialize().then((_) {
      if (mounted) {
        setState(() {});
        _videoController!.play();
        _videoController!.setLooping(true);
        _isPlaying = true;
      }
    });
  }

  void _togglePlayPause() {
    if (_videoController == null) return;
    
    setState(() {
      if (_isPlaying) {
        _videoController!.pause();
        _isPlaying = false;
      } else {
        _videoController!.play();
        _isPlaying = true;
      }
      _showPlayPauseIcon = true;
    });
    
    // Hide icon after 600ms
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
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Content Display
          Center(
            child: widget.content.type == 'photo'
                ? _buildPhotoView()
                : widget.content.type == 'video'
                    ? _buildVideoView()
                    : _buildLiveView(),
          ),
          
          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.purple,
                      child: Text(
                        widget.username[0].toUpperCase(),
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () => _showOptions(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Play/Pause Icon Overlay
          if (_showPlayPauseIcon && widget.content.type == 'video')
            Center(
              child: AnimatedOpacity(
                opacity: _showPlayPauseIcon ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
          
          // Bottom Actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(Icons.favorite_border, '1.2K', () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Liked!'),
                          backgroundColor: Colors.red,
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                    }),
                    _buildActionButton(Icons.comment, '234', () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Comments'),
                          backgroundColor: Colors.purple,
                        ),
                      );
                    }),
                    _buildActionButton(Icons.share, 'Share', () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Share'),
                          backgroundColor: Colors.purple,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.6),
            Colors.purple.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera,
              color: Colors.white.withOpacity(0.7),
              size: 100,
            ),
            SizedBox(height: 16),
            Text(
              'Photo Preview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoView() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(color: Colors.purple),
      );
    }
    
    return GestureDetector(
      onTap: _togglePlayPause,
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      ),
    );
  }

  Widget _buildLiveView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.withOpacity(0.6),
            Colors.orange.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sensors,
              color: Colors.white.withOpacity(0.7),
              size: 100,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'LIVE STREAM ENDED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showOptions() {
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
            ListTile(
              leading: Icon(Icons.download, color: Colors.purple),
              title: Text('Save', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Saved!'), backgroundColor: Colors.green),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.report, color: Colors.red),
              title: Text('Report', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reported'), backgroundColor: Colors.red),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
