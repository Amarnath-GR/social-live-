import 'package:flutter/material.dart';
import '../screens/live_camera_stream_screen.dart';

class LiveStreamButton extends StatelessWidget {
  final bool isFloating;
  final VoidCallback? onPressed;

  const LiveStreamButton({
    Key? key,
    this.isFloating = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isFloating) {
      return FloatingActionButton(
        onPressed: () => _startLiveStream(context),
        backgroundColor: Colors.red,
        child: Icon(Icons.videocam, color: Colors.white),
        heroTag: "live_stream_fab",
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _startLiveStream(context),
      icon: Icon(Icons.videocam, color: Colors.white),
      label: Text(
        'Go Live',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  void _startLiveStream(BuildContext context) {
    if (onPressed != null) {
      onPressed!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveCameraStreamScreen(
          isHost: true,
          streamId: 'live_${DateTime.now().millisecondsSinceEpoch}',
        ),
      ),
    );
  }
}

class QuickLiveStreamDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Row(
        children: [
          Icon(Icons.videocam, color: Colors.red),
          SizedBox(width: 8),
          Text(
            'Start Live Stream',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to go live?',
            style: TextStyle(color: Colors.grey[300], fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            '• Make sure you have good lighting\n• Check your internet connection\n• Your followers will be notified',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LiveCameraStreamScreen(
                  isHost: true,
                  streamId: 'live_${DateTime.now().millisecondsSinceEpoch}',
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            'Go Live',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => QuickLiveStreamDialog(),
    );
  }
}