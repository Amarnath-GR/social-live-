import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class AnalyticsTrackingWidget extends StatefulWidget {
  final Widget child;
  final String contentType;
  final String contentId;
  final Map<String, dynamic>? metadata;

  const AnalyticsTrackingWidget({
    Key? key,
    required this.child,
    required this.contentType,
    required this.contentId,
    this.metadata,
  }) : super(key: key);

  @override
  _AnalyticsTrackingWidgetState createState() => _AnalyticsTrackingWidgetState();
}

class _AnalyticsTrackingWidgetState extends State<AnalyticsTrackingWidget>
    with WidgetsBindingObserver {
  DateTime? _viewStartTime;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTracking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTracking();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopTracking();
    } else if (state == AppLifecycleState.resumed) {
      _startTracking();
    }
  }

  void _startTracking() {
    if (!_isVisible) {
      _isVisible = true;
      _viewStartTime = DateTime.now();
      
      AnalyticsService.trackView(
        contentType: widget.contentType,
        contentId: widget.contentId,
      );
      
      AnalyticsService.startDwellTracking(widget.contentType, widget.contentId);
    }
  }

  void _stopTracking() {
    if (_isVisible && _viewStartTime != null) {
      _isVisible = false;
      final dwellTime = DateTime.now().difference(_viewStartTime!).inSeconds;
      
      AnalyticsService.stopDwellTracking(widget.contentType, widget.contentId);
      
      AnalyticsService.trackView(
        contentType: widget.contentType,
        contentId: widget.contentId,
        viewDuration: dwellTime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Usage example in post widget
class PostWidget extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnalyticsTrackingWidget(
      contentType: 'post',
      contentId: post['id'],
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: Text(post['content']),
              subtitle: Text(post['user']['username']),
            ),
            ButtonBar(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite),
                  onPressed: () {
                    AnalyticsService.trackPostLike(post['id']);
                    // Handle like action
                  },
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    AnalyticsService.trackPostShare(post['id']);
                    // Handle share action
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
