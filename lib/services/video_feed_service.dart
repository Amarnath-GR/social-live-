import '../services/api_client.dart';
import 'mock_video_data.dart';

class VideoFeedService {
  static final ApiClient _apiClient = ApiClient();
  static const bool _useMockData = true; // Set to false when backend is ready

  static Future<Map<String, dynamic>> getVideoFeed({int page = 1, int limit = 10}) async {
    // Use mock data for demo purposes
    if (_useMockData) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Simulate pagination
      final allVideos = MockVideoData.getMockVideos();
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      
      if (startIndex >= allVideos.length) {
        return {
          'success': true,
          'videos': [],
          'hasMore': false,
        };
      }
      
      final pageVideos = allVideos.sublist(
        startIndex,
        endIndex > allVideos.length ? allVideos.length : endIndex,
      );
      
      return {
        'success': true,
        'videos': pageVideos,
        'hasMore': endIndex < allVideos.length,
      };
    }

    try {
      final response = await _apiClient.get('/posts', queryParameters: {
        'page': page,
        'limit': limit,
        'type': 'VIDEO',
      });

      // Backend returns array directly, not wrapped in success/data
      final videos = List<Map<String, dynamic>>.from(response.data ?? []);
      
      return {
        'success': true,
        'videos': videos,
        'hasMore': videos.length >= limit,
      };
    } catch (e) {
      // Fallback to mock data if backend fails
      await Future.delayed(const Duration(seconds: 1));
      
      final allVideos = MockVideoData.getMockVideos();
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      
      if (startIndex >= allVideos.length) {
        return {
          'success': true,
          'videos': [],
          'hasMore': false,
        };
      }
      
      final pageVideos = allVideos.sublist(
        startIndex,
        endIndex > allVideos.length ? allVideos.length : endIndex,
      );
      
      return {
        'success': true,
        'videos': pageVideos,
        'hasMore': endIndex < allVideos.length,
      };
    }
  }

  static Future<Map<String, dynamic>> likeVideo(String videoId) async {
    // Mock like for demo
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true, 'message': 'Video liked'};
    }

    try {
      final response = await _apiClient.post('/posts/$videoId/like');
      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to like video'};
    }
  }
}
