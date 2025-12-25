import '../services/api_client.dart';

class VideoFeedService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> getVideoFeed({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiClient.get('/posts', queryParameters: {
        'page': page,
        'limit': limit,
        'type': 'VIDEO',
      });

      final videos = List<Map<String, dynamic>>.from(response.data ?? []);
      
      return {
        'success': true,
        'videos': videos,
        'hasMore': videos.length >= limit,
      };
    } catch (e) {
      return {
        'success': true,
        'videos': [],
        'hasMore': false,
      };
    }
  }

  static Future<Map<String, dynamic>> likeVideo(String videoId) async {
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
