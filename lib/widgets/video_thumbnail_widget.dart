import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'dart:typed_data';

class VideoThumbnailWidget extends StatefulWidget {
  final String videoPath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;

  const VideoThumbnailWidget({
    Key? key,
    required this.videoPath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
  }) : super(key: key);

  @override
  _VideoThumbnailWidgetState createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  Uint8List? _thumbnailData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: widget.videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 400,
        quality: 75,
      );

      if (mounted) {
        setState(() {
          _thumbnailData = uint8list;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error generating thumbnail: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.withOpacity(0.3),
                  Colors.deepPurple.withOpacity(0.3),
                ],
              ),
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                strokeWidth: 2,
              ),
            ),
          );
    }

    if (_hasError || _thumbnailData == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.withOpacity(0.6),
              Colors.deepPurple.withOpacity(0.6),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.play_circle_filled,
            color: Colors.white.withOpacity(0.7),
            size: 40,
          ),
        ),
      );
    }

    return Image.memory(
      _thumbnailData!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.withOpacity(0.6),
                Colors.deepPurple.withOpacity(0.6),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.play_circle_filled,
              color: Colors.white.withOpacity(0.7),
              size: 40,
            ),
          ),
        );
      },
    );
  }
}
