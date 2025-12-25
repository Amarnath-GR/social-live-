import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class FullscreenVideoPlayer extends StatefulWidget {
  final String videoPath;
  final int duration;

  const FullscreenVideoPlayer({
    Key? key,
    required this.videoPath,
    required this.duration,
  }) : super(key: key);

  @override
  _FullscreenVideoPlayerState createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    if (!widget.videoPath.startsWith('recorded_video_')) {
      _controller = VideoPlayerController.file(File(widget.videoPath));
      _controller!.initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.play();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _showControls = !_showControls;
            });
          },
          child: Stack(
          children: [
            Center(
              child: _isInitialized && _controller != null
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_filled, color: Colors.white, size: 80),
                            SizedBox(height: 16),
                            Text('Mock Video Player', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
            ),
            if (_showControls)
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            if (_showControls && _isInitialized)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _controller!.value.isPlaying
                            ? _controller!.pause()
                            : _controller!.play();
                      });
                    },
                    icon: Icon(
                      _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}