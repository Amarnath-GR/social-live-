import 'package:flutter/material.dart';
import '../services/user_content_service.dart';
import 'content_preview_screen.dart';

class ContentViewerScreen extends StatefulWidget {
  final List<UserContent> contents;
  final int initialIndex;

  const ContentViewerScreen({
    Key? key,
    required this.contents,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<ContentViewerScreen> createState() => _ContentViewerScreenState();
}

class _ContentViewerScreenState extends State<ContentViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: widget.contents.length,
      onPageChanged: (index) {
        setState(() => _currentIndex = index);
      },
      itemBuilder: (context, index) {
        final content = widget.contents[index];
        return ContentPreviewScreen(
          contentPath: content.path,
          contentType: content.type,
          isOwner: true,
        );
      },
    );
  }
}
