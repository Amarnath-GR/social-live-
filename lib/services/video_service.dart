import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';

class VideoService {
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

  Future<void> uploadVideo({
    required File videoFile,
    required String caption,
    required List<String> hashtags,
    required String privacy,
    required String sound,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/videos/upload'),
    );

    // Add headers
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    // Add video file
    request.files.add(
      await http.MultipartFile.fromPath('video', videoFile.path),
    );

    // Add other fields
    request.fields['caption'] = caption;
    request.fields['hashtags'] = jsonEncode(hashtags);
    request.fields['privacy'] = privacy;
    request.fields['sound'] = sound;

    final response = await request.send();

    if (response.statusCode != 201) {
      final responseBody = await response.stream.bytesToString();
      throw Exception('Failed to upload video: $responseBody');
    }
  }

  Future<List<VideoModel>> getVideoFeed({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/videos/feed?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> videos = data['videos'] ?? data;
      return videos.map((json) => VideoModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load video feed: ${response.body}');
    }
  }

  Future<VideoModel> getVideo(String videoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/videos/$videoId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return VideoModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load video: ${response.body}');
    }
  }

  Future<void> likeVideo(String videoId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/videos/$videoId/like'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to like video: ${response.body}');
    }
  }

  Future<void> unlikeVideo(String videoId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/videos/$videoId/like'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to unlike video: ${response.body}');
    }
  }

  Future<void> shareVideo(String videoId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/videos/$videoId/share'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to share video: ${response.body}');
    }
  }

  Future<void> reportVideo(String videoId, String reason) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/videos/$videoId/report'),
      headers: _headers,
      body: jsonEncode({'reason': reason}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to report video: ${response.body}');
    }
  }

  Future<List<CommentModel>> getVideoComments(String videoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/videos/$videoId/comments'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CommentModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.body}');
    }
  }

  Future<void> addComment(String videoId, String comment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/videos/$videoId/comments'),
      headers: _headers,
      body: jsonEncode({'content': comment}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add comment: ${response.body}');
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
      throw Exception('Failed to load user videos: ${response.body}');
    }
  }

  Future<List<VideoModel>> getLikedVideos(String? userId) async {
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
      throw Exception('Failed to load liked videos: ${response.body}');
    }
  }

  Future<void> deleteVideo(String videoId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/videos/$videoId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete video: ${response.body}');
    }
  }
}

class CommentModel {
  final String id;
  final String content;
  final String userId;
  final String username;
  final String? userAvatar;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;

  CommentModel({
    required this.id,
    required this.content,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      content: json['content'],
      userId: json['userId'],
      username: json['user']['username'],
      userAvatar: json['user']['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
      likesCount: json['likesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'isLiked': isLiked,
    };
  }
}