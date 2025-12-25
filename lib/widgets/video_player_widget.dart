import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool isVisible;
  final VoidCallback? onTap;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.isVisible,
    this.onTap,
  });

  @override
  State<VideoPlayerWidget> createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  void pauseVideo() {
    if (_controller != null && _isInitialized && _controller!.value.isPlaying) {
      _controller!.pause();
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.videoUrl != oldWidget.videoUrl) {
      _initializeVideo();
    }
    
    if (widget.isVisible != oldWidget.isVisible) {
      _handleVisibilityChange();
    }
  }

  void _initializeVideo() {
    _controller?.dispose();
    
    if (widget.videoUrl.isEmpty) {
      setState(() {
        _hasError = true;
        _isInitialized = false;
      });
      return;
    }
    
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    
    _controller!.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
        
        _controller!.setLooping(true);
        if (widget.isVisible) {
          _controller!.play();
        }
      }
    }).catchError((error) {
      debugPrint('Video initialization error: $error');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
    });
  }

  void _handleVisibilityChange() {
    if (_controller != null && _isInitialized) {
      if (widget.isVisible) {
        _controller!.play();
      } else {
        _controller!.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 48),
              SizedBox(height: 16),
              Text('Failed to load video', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (_controller != null && _isInitialized) {
          if (_controller!.value.isPlaying) {
            _controller!.pause();
          } else {
            _controller!.play();
          }
        }
        widget.onTap?.call();
      },
      child: Container(
        color: Colors.black,
        child: Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),
      ),
    );
  }
}
