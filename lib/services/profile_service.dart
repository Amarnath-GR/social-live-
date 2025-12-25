import '../models/user_models.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getCurrentUser() async {
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

  static Future<Map<String, dynamic>> getUserPosts(String userId, {int page = 1, int limit = 20}) async {
    return {'success': true, 'posts': []};
  }

  static Future<Map<String, dynamic>> getLikedPosts(String userId, {int page = 1, int limit = 20}) async {
    return {'success': true, 'posts': []};
  }

  static Future<Map<String, dynamic>> followUser(String userId) async {
    return {'success': true, 'message': 'Followed successfully'};
  }

  static Future<Map<String, dynamic>> unfollowUser(String userId) async {
    return {'success': true, 'message': 'Unfollowed successfully'};
  }

  static Future<Map<String, dynamic>> getFollowers(String userId, {int page = 1, int limit = 20}) async {
    return {'success': true, 'users': []};
  }

  static Future<Map<String, dynamic>> getFollowing(String userId, {int page = 1, int limit = 20}) async {
    return {'success': true, 'users': []};
  }

  static Future<Map<String, dynamic>> updateProfile(UpdateProfileRequest request) async {
    return {'success': true, 'message': 'Profile updated locally'};
  }

  static Future<Map<String, dynamic>> uploadAvatar(String imagePath) async {
    return {'success': true, 'avatarUrl': imagePath};
  }

  static Future<Map<String, dynamic>> getUserById(String userId) async {
    return {'success': false, 'message': 'User not found'};
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return {'success': true, 'message': 'Password changed locally'};
  }

  static Future<Map<String, dynamic>> deleteAccount() async {
    return {'success': true, 'message': 'Account deleted locally'};
  }
}
