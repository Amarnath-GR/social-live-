import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'api_client.dart';

class AnalyticsService {
  static final ApiClient _apiClient = ApiClient();
  static final Uuid _uuid = Uuid();
  static String? _sessionId;
  static Timer? _batchTimer;
  static final List<Map<String, dynamic>> _eventQueue = [];
  static const int _batchSize = 10;
  static const Duration _batchInterval = Duration(seconds: 30);

  static String get sessionId {
    _sessionId ??= _uuid.v4();
    return _sessionId!;
  }

  static void initialize() {
    _startBatchTimer();
    _trackSession('start');
  }

  static void dispose() {
    _trackSession('end');
    _flushEvents();
    _batchTimer?.cancel();
  }

  // View Tracking
  static void trackView({
    required String contentType,
    required String contentId,
    int? viewDuration,
    double? scrollDepth,
    String? referrer,
  }) {
    _queueEvent({
      'eventType': 'view',
      'data': {
        'contentType': contentType,
        'contentId': contentId,
        'viewDuration': viewDuration,
        'scrollDepth': scrollDepth,
        'referrer': referrer,
      },
    });
  }

  // Engagement Tracking
  static void trackEngagement({
    required String action,
    required String targetType,
    required String targetId,
    Map<String, dynamic>? metadata,
  }) {
    _queueEvent({
      'eventType': 'engagement',
      'data': {
        'action': action,
        'targetType': targetType,
        'targetId': targetId,
        'metadata': metadata,
      },
    });
  }

  // Purchase Tracking
  static void trackPurchase({
    required String productId,
    required String orderId,
    required double amount,
    String currency = 'USD',
    int quantity = 1,
    required String paymentMethod,
    List<String>? conversionPath,
  }) {
    _queueEvent({
      'eventType': 'purchase',
      'data': {
        'productId': productId,
        'orderId': orderId,
        'amount': amount,
        'currency': currency,
        'quantity': quantity,
        'paymentMethod': paymentMethod,
        'conversionPath': conversionPath,
      },
    });
  }

  // Stream Tracking
  static void trackStream({
    required String action,
    required String streamId,
    int? duration,
    int? viewerCount,
    String? messageContent,
  }) {
    _queueEvent({
      'eventType': 'stream',
      'data': {
        'action': action,
        'streamId': streamId,
        'duration': duration,
        'viewerCount': viewerCount,
        'messageContent': messageContent,
      },
    });
  }

  // Session Tracking
  static void _trackSession(String action, {
    int? duration,
    int? pageViews,
    Map<String, dynamic>? device,
  }) {
    _queueEvent({
      'eventType': 'session',
      'data': {
        'action': action,
        'duration': duration,
        'pageViews': pageViews,
        'device': device,
      },
    });
  }

  // Dwell Time Tracking
  static Timer? _dwellTimer;
  static DateTime? _viewStartTime;

  static void startDwellTracking(String contentType, String contentId) {
    _viewStartTime = DateTime.now();
    _dwellTimer?.cancel();
    
    _dwellTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      final dwellTime = DateTime.now().difference(_viewStartTime!).inSeconds;
      trackView(
        contentType: contentType,
        contentId: contentId,
        viewDuration: dwellTime,
      );
    });
  }

  static void stopDwellTracking(String contentType, String contentId) {
    if (_viewStartTime != null) {
      final totalDwellTime = DateTime.now().difference(_viewStartTime!).inSeconds;
      trackView(
        contentType: contentType,
        contentId: contentId,
        viewDuration: totalDwellTime,
      );
    }
    _dwellTimer?.cancel();
    _viewStartTime = null;
  }

  // Event Queue Management
  static void _queueEvent(Map<String, dynamic> event) {
    event['eventId'] = _uuid.v4();
    event['sessionId'] = sessionId;
    event['timestamp'] = DateTime.now().toIso8601String();
    event['platform'] = 'mobile';
    event['schemaVersion'] = '1.1.0';

    _eventQueue.add(event);

    if (_eventQueue.length >= _batchSize) {
      _flushEvents();
    }
  }

  static void _startBatchTimer() {
    _batchTimer = Timer.periodic(_batchInterval, (timer) {
      if (_eventQueue.isNotEmpty) {
        _flushEvents();
      }
    });
  }

  static Future<void> _flushEvents() async {
    if (_eventQueue.isEmpty) return;

    final events = List<Map<String, dynamic>>.from(_eventQueue);
    _eventQueue.clear();

    try {
      await _apiClient.post('/analytics/events/batch', data: {
        'events': events,
      });
    } catch (e) {
      // Re-queue events on failure
      _eventQueue.addAll(events);
      debugPrint('Failed to send analytics events: $e');
    }
  }

  // Immediate tracking (bypass queue)
  static Future<void> trackImmediate(Map<String, dynamic> event) async {
    event['eventId'] = _uuid.v4();
    event['sessionId'] = sessionId;
    event['timestamp'] = DateTime.now().toIso8601String();
    event['platform'] = 'mobile';
    event['schemaVersion'] = '1.1.0';

    try {
      await _apiClient.post('/analytics/events/track', data: event);
    } catch (e) {
      debugPrint('Failed to send immediate analytics event: $e');
    }
  }

  // Convenience methods for common actions
  static void trackPostView(String postId) {
    trackView(contentType: 'post', contentId: postId);
  }

  static void trackPostLike(String postId) {
    trackEngagement(action: 'like', targetType: 'post', targetId: postId);
  }

  static void trackPostShare(String postId) {
    trackEngagement(action: 'share', targetType: 'post', targetId: postId);
  }

  static void trackUserFollow(String userId) {
    trackEngagement(action: 'follow', targetType: 'user', targetId: userId);
  }

  static void trackStreamJoin(String streamId) {
    trackStream(action: 'join', streamId: streamId);
  }

  static void trackStreamLeave(String streamId, int duration) {
    trackStream(action: 'leave', streamId: streamId, duration: duration);
  }

  static void trackProductView(String productId) {
    trackView(contentType: 'product', contentId: productId);
  }
}
