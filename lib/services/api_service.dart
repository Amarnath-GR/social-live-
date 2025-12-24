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
    final response = await http.get(
      Uri.parse('$baseUrl/api/videos/feed?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => VideoModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load video feed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> likeVideo(String videoId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/videos/like'),
      headers: _headers,
      body: jsonEncode({'videoId': videoId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to like video: ${response.body}');
    }
  }

  Future<void> recordVideoView(String videoId, int duration) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/videos/view'),
      headers: _headers,
      body: jsonEncode({
        'videoId': videoId,
        'duration': duration,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to record view: ${response.body}');
    }
  }

  Future<void> shareVideo(String videoId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/videos/share'),
      headers: _headers,
      body: jsonEncode({'videoId': videoId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to share video: ${response.body}');
    }
  }

  // Video Upload
  Future<Map<String, dynamic>> uploadVideo(File videoFile, {
    String? description,
    List<String>? hashtags,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/videos/upload'),
    );

    request.headers.addAll(_headers);
    request.files.add(await http.MultipartFile.fromPath('video', videoFile.path));
    
    if (description != null) {
      request.fields['description'] = description;
    }
    if (hashtags != null) {
      request.fields['hashtags'] = jsonEncode(hashtags);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to upload video: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getUploadUrl(String filename) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/videos/upload-url?filename=$filename'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get upload URL: ${response.body}');
    }
  }

  // User Profile Methods
  Future<UserModel?> getUserProfile([String? userId]) async {
    final endpoint = userId != null 
        ? '$baseUrl/api/users/$userId'
        : '$baseUrl/api/users/profile';
        
    final response = await http.get(
      Uri.parse(endpoint),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<List<VideoModel>> getUserVideos(String? userId) async {
    final endpoint = userId != null 
        ? '$baseUrl/api/users/$userId/videos'
        : '$baseUrl/api/videos/my-videos';
        
    final response = await http.get(
      Uri.parse(endpoint),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => VideoModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<List<VideoModel>> getUserLikedVideos(String? userId) async {
    final endpoint = userId != null 
        ? '$baseUrl/api/users/$userId/liked-videos'
        : '$baseUrl/api/videos/liked';
        
    final response = await http.get(
      Uri.parse(endpoint),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => VideoModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<void> followUser(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/$userId/follow'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to follow user: ${response.body}');
    }
  }

  Future<void> unfollowUser(String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/users/$userId/follow'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to unfollow user: ${response.body}');
    }
  }

  // Posts (legacy support)
  Future<List<dynamic>> getPosts({int page = 1, int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/posts?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['posts'];
    } else {
      throw Exception('Failed to load posts: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createPost(String content, {String? imageUrl}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/posts'),
      headers: _headers,
      body: jsonEncode({
        'content': content,
        if (imageUrl != null) 'imageUrl': imageUrl,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create post: ${response.body}');
    }
  }
}