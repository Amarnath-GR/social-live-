import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password, String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
        'username': username,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  // Video Feed APIs
  Future<List<VideoModel>> getTikTokFeed({int page = 1, int limit = 20}) async {
    return [];
  }

  Future<Map<String, dynamic>> likeVideo(String videoId) async {
    return {'success': true};
  }

  Future<void> recordVideoView(String videoId, int duration) async {
    return;
  }

  Future<void> shareVideo(String videoId) async {
    return;
  }

  // Video Upload
  Future<Map<String, dynamic>> uploadVideo(File videoFile, {
    String? description,
    List<String>? hashtags,
  }) async {
    return {'success': true, 'videoId': 'local_${DateTime.now().millisecondsSinceEpoch}'};
  }

  Future<Map<String, dynamic>> getUploadUrl(String filename) async {
    return {'uploadUrl': '', 'videoId': 'local_${DateTime.now().millisecondsSinceEpoch}'};
  }

  // User Profile Methods
  Future<UserModel?> getUserProfile([String? userId]) async {
    return null;
  }

  Future<List<VideoModel>> getUserVideos(String? userId) async {
    return [];
  }

  Future<List<VideoModel>> getUserLikedVideos(String? userId) async {
    return [];
  }

  Future<void> followUser(String userId) async {
    return;
  }

  Future<void> unfollowUser(String userId) async {
    return;
  }

  // Posts (legacy support)
  Future<List<dynamic>> getPosts({int page = 1, int limit = 10}) async {
    return [];
  }

  Future<Map<String, dynamic>> createPost(String content, {String? imageUrl}) async {
    return {'success': true, 'postId': 'local_${DateTime.now().millisecondsSinceEpoch}'};
  }
}