import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/video_upload_service.dart';
import '../services/user_content_service.dart';

class VideoPreviewScreen extends StatefulWidget {
  final File videoFile;
  final String? selectedMusic;

  const VideoPreviewScreen({
    super.key, 
    required this.videoFile,
    this.selectedMusic,
  });

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  VideoPlayerController? _controller;
  final TextEditingController _captionController = TextEditingController();
  bool _isInitialized = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.file(widget.videoFile);
    
    try {
      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.play();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
    }
  }

  Future<void> _publishVideo() async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Getting upload URL...';
    });

    try {
      // Get upload URL
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      final uploadUrlResult = await VideoUploadService.getUploadUrl(fileName);

      if (!uploadUrlResult['success']) {
        _showError(uploadUrlResult['message']);
        return;
      }

      setState(() {
        _uploadStatus = 'Uploading video...';
      });

      // Upload video
      final uploadResult = await VideoUploadService.uploadVideo(
        uploadUrlResult['uploadUrl'],
        widget.videoFile,
        (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      if (!uploadResult['success']) {
        _showError(uploadResult['message']);
        return;
      }

      setState(() {
        _uploadStatus = 'Creating post...';
        _uploadProgress = 1.0;
      });

      // Create post
      final postResult = await VideoUploadService.createVideoPost(
        videoUrl: uploadUrlResult['fileUrl'],
        content: _captionController.text.trim(),
      );

      if (postResult['success']) {
        _showSuccess();
      } else {
        _showError(postResult['message']);
      }
    } catch (e) {
      _showError('Upload failed: ${e.toString()}');
    }
  }

  void _showError(String message) {
    setState(() {
      _isUploading = false;
      _uploadProgress = 0.0;
      _uploadStatus = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess() {
    setState(() {
      _isUploading = false;
      _uploadProgress = 0.0;
      _uploadStatus = '';
    });

    // Save to UserContentService
    final userContentService = UserContentService();
    userContentService.addVideo(
      widget.videoFile.path,
      _controller?.value.duration.inSeconds ?? 30,
      thumbnailPath: widget.videoFile.path,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video published successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  List<String> _extractHashtags(String text) {
    final regex = RegExp(r'#\w+');
    return regex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
          // Video preview
          if (_isInitialized && _controller != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Top overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const Text(
                  'Preview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          // Bottom overlay with caption and publish
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selected music display
                  if (widget.selectedMusic != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.music_note, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.selectedMusic!.split('/').last.replaceAll('.mp3', ''),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 16),
                            onPressed: () {
                              // Remove music selection
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Caption input
                  TextField(
                    controller: _captionController,
                    style: const TextStyle(color: Colors.black),
                    maxLines: 3,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption...',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      counterStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Upload progress
                  if (_isUploading) ...[
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: _uploadProgress,
                          backgroundColor: Colors.white30,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _uploadStatus,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ],

                  // Publish button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _publishVideo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Publish',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
