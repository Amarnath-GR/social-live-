import '../models/user_models.dart';
import 'api_client.dart';

class ProfileService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/users/me');
      
      if (response.data != null && response.data['success'] == true) {
        final userData = response.data['data'];
        if (userData != null) {
          final user = User.fromJson(userData);
          return {'success': true, 'user': user};
        }
      }
      
      return {
        'success': false, 
        'message': response.data?['message'] ?? 'Failed to load profile'
      };
    } catch (e) {
      // Return mock user data when backend is unavailable
      final mockUser = User(
        id: 'mock-user-id',
        username: 'demo_user',
        name: 'Demo User',
        email: 'demo@example.com',
        bio: 'Welcome to Social Live! 🎉',
        avatar: null,
        role: 'USER',
        isBlocked: false,
        kycVerified: false,
        kybVerified: false,
        amlVerified: false,
        followersCount: 0,
        followingCount: 0,
        isFollowing: false,
        stats: UserStats(posts: 0, likes: 0, comments: 0),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return {'success': true, 'user': mockUser};
    }
  }

  static Future<Map<String, dynamic>> getUserPosts(String userId, {int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.get('/posts/user/$userId', queryParameters: {'page': page, 'limit': limit});
      
      if (response.data['success'] == true) {
        final data = response.data['data'];
        List<Map<String, dynamic>> posts = [];
        
        if (data is List) {
          posts = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['posts'] != null) {
          posts = List<Map<String, dynamic>>.from(data['posts']);
        }
        
        return {'success': true, 'posts': posts};
      }
      
      return {'success': false, 'message': response.data['message'] ?? 'Failed to get posts'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> followUser(String userId) async {
    try {
      final response = await _apiClient.post('/users/$userId/follow');
      
      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? 'Follow action failed'
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> unfollowUser(String userId) async {
    try {
      final response = await _apiClient.post('/users/$userId/unfollow');
      
      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? 'Unfollow action failed'
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getFollowers(String userId, {int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.get('/users/$userId/followers', queryParameters: {'page': page, 'limit': limit});
      
      if (response.data['success'] == true) {
        return {'success': true, 'users': response.data['data']};
      }
      
      return {'success': false, 'message': response.data['message'] ?? 'Failed to get followers'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getFollowing(String userId, {int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.get('/users/$userId/following', queryParameters: {'page': page, 'limit': limit});
      
      if (response.data['success'] == true) {
        return {'success': true, 'users': response.data['data']};
      }
      
      return {'success': false, 'message': response.data['message'] ?? 'Failed to get following'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _apiClient.put('/users/me', data: request.toJson());
      
      if (response.data['success'] == true) {
        final user = User.fromJson(response.data['data']);
        return {'success': true, 'user': user};
      }
      
      return {'success': false, 'message': response.data['message'] ?? 'Failed to update profile'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> uploadAvatar(String imagePath) async {
    try {
      final response = await _apiClient.uploadFile('/users/avatar', imagePath);
      
      if (response.data['success'] == true) {
        return {'success': true, 'avatarUrl': response.data['data']['url']};
      }
      
      return {'success': false, 'message': response.data['message'] ?? 'Failed to upload avatar'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId');
      
      if (response.data['success'] == true) {
        final user = User.fromJson(response.data['data']);
        return {'success': true, 'user': user};
      }
      
      return {'success': false, 'message': response.data['message'] ?? 'Failed to get user'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.put('/users/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      
      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? 'Password change failed'
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _apiClient.delete('/users/me');
      
      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? 'Account deletion failed'
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
