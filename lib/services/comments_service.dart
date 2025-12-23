import '../services/api_client.dart';

class CommentsService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> getComments(String postId, {int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.get('/comments/post/$postId', queryParameters: {
        'page': page,
        'limit': limit,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        List<Map<String, dynamic>> comments = [];
        
        if (data is List) {
          comments = List<Map<String, dynamic>>.from(data);
        } else if (data is Map) {
          comments = List<Map<String, dynamic>>.from(data['comments'] ?? data['data'] ?? []);
        }
        
        return {
          'success': true,
          'comments': comments,
          'hasMore': data is Map ? (data['hasMore'] ?? false) : false,
        };
      }
      
      return {'success': false, 'message': response.data['message'] ?? 'Failed to load comments'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> addComment(String postId, String content) async {
    try {
      final response = await _apiClient.post('/comments', data: {
        'postId': postId,
        'content': content,
      });

      if (response.data['success'] == true) {
        return {
          'success': true,
          'comment': response.data['data'],
        };
      }
      
      return {'success': false, 'message': response.data['message'] ?? 'Failed to add comment'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> deleteComment(String commentId) async {
    try {
      final response = await _apiClient.delete('/comments/$commentId');
      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete comment'};
    }
  }
}
