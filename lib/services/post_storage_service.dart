import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PostStorageService {
  static const String _postsKey = 'user_posts';
  
  static Future<void> savePost({
    required String userId,
    required String postId,
    required String videoPath,
    required String thumbnailPath,
    required String description,
    required List<String> hashtags,
    int duration = 30,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existingPosts = await getUserPosts(userId);
    
    final newPost = {
      'id': postId,
      'userId': userId,
      'videoPath': videoPath,
      'thumbnailPath': thumbnailPath,
      'description': description,
      'hashtags': hashtags,
      'duration': duration,
      'likes': 0,
      'views': 0,
      'comments': 0,
      'shares': 0,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    existingPosts.insert(0, newPost);
    await prefs.setString('${_postsKey}_$userId', jsonEncode(existingPosts));
  }
  
  static Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getString('${_postsKey}_$userId');
    if (postsJson == null) return [];
    
    final List<dynamic> postsList = jsonDecode(postsJson);
    return postsList.cast<Map<String, dynamic>>();
  }
  
  static Future<List<Map<String, dynamic>>> getAllPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_postsKey));
    
    List<Map<String, dynamic>> allPosts = [];
    for (String key in keys) {
      final postsJson = prefs.getString(key);
      if (postsJson != null) {
        final List<dynamic> userPosts = jsonDecode(postsJson);
        allPosts.addAll(userPosts.cast<Map<String, dynamic>>());
      }
    }
    
    allPosts.sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
    return allPosts;
  }

  static Future<void> deletePost(String userId, String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final existingPosts = await getUserPosts(userId);
    existingPosts.removeWhere((post) => post['id'] == postId);
    await prefs.setString('${_postsKey}_$userId', jsonEncode(existingPosts));
  }
}