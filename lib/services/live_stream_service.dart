import 'package:flutter/foundation.dart';

class LiveStreamService extends ChangeNotifier {
  bool _isStreaming = false;
  int _viewerCount = 0;
  String? _currentStreamId;

  bool get isStreaming => _isStreaming;
  int get viewerCount => _viewerCount;
  String? get currentStreamId => _currentStreamId;

  Future<bool> startStream(String streamId) async {
    try {
      _currentStreamId = streamId;
      _isStreaming = true;
      _viewerCount = 1; // Start with host as viewer
      notifyListeners();
      return true;
    } catch (e) {
      print('Error starting stream: $e');
      return false;
    }
  }

  Future<void> stopStream() async {
    try {
      _isStreaming = false;
      _viewerCount = 0;
      _currentStreamId = null;
      notifyListeners();
    } catch (e) {
      print('Error stopping stream: $e');
    }
  }

  void updateViewerCount(int count) {
    _viewerCount = count;
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    // Implement message sending logic
    print('Sending message: $message');
  }

  Future<void> sendGift(String giftId, String recipientId) async {
    // Implement gift sending logic
    print('Sending gift $giftId to $recipientId');
  }
}