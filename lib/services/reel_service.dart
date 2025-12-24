import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';

class ReelService {
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

  // Upload a reel with enhanced metadata
  Future<void> uploadReel({
    required File videoFile,
    required String caption,
    required List<String> hashtags,
    required String privacy,
    String? sound,
    String? location,
    List<String>? mentions,
    Map<String, dynamic>? effects,
    double? duration,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/reels/upload'),
    );

    // Add headers
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    // Add video file
    request.files.add(
      await http.MultipartFile.fromPath('video', videoFile.path),
    );

    // Add metadata
    request.fields['caption'] = caption;
    request.fields['hashtags'] = jsonEncode(hashtags);
    request.fields['privacy'] = privacy;
    request.fields['type'] = 'reel';
    
    if (sound != null) request.fields['sound'] = sound;
    if (location != null) request.fields['location'] = location;
    if (mentions != null) request.fields['mentions'] = jsonEncode(mentions);
    if (effects != null) request.fields['effects'] = jsonEncode(effects);
    if (duration != null) request.fields['duration'] = duration.toString();

    final response = await request.send();

    if (response.statusCode != 201) {
      final responseBody = await response.stream.bytesToString();
      throw Exception('Failed to upload reel: $responseBody');
    }
  }

  // Get reel feed (vertical scrolling format)
  Future<List<VideoModel>> getReelFeed({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    var url = '$baseUrl/api/reels/feed?page=$page&limit=$limit';
    if (category != null) {
      url += '&category=$category';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> reels = data['reels'] ?? data;
      return reels.map((json) => VideoModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reel feed: ${response.body}');
    }
  }

  // Get trending reels
  Future<List<VideoModel>> getTrendingReels({
    int limit = 20,
    String timeframe = '24h', // 24h, 7d, 30d
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/reels/trending?limit=$limit&timeframe=$timeframe'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => VideoModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load trending reels: ${response.body}');
    }
  }

  // Get reels by hashtag
  Future<List<VideoModel>> getReelsByHashtag(String hashtag, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/reels/hashtag/$hashtag?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> reels = data['reels'] ?? data;
      return reels.map((json) => VideoModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reels by hashtag: ${response.body}');
    }
  }

  // Get user's reels
  Future<List<VideoModel>> getUserReels(String? userId, {
    int page = 1,
    int limit = 10,
  }) async {
    final endpoint = userId != null 
        ? '$baseUrl/api/users/$userId/reels'
        : '$baseUrl/api/reels/my-reels';
        
    final response = await http.get(
      Uri.parse('$endpoint?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> reels = data['reels'] ?? data;
      return reels.map((json) => VideoModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user reels: ${response.body}');
    }
  }

  // Reel interactions
  Future<Map<String, dynamic>> likeReel(String reelId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/reels/$reelId/like'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to like reel: ${response.body}');
    }
  }

  Future<void> shareReel(String reelId, {String? platform}) async {
    final body = platform != null ? {'platform': platform} : <String, dynamic>{};
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/reels/$reelId/share'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to share reel: ${response.body}');
    }
  }

  Future<void> saveReel(String reelId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/reels/$reelId/save'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save reel: ${response.body}');
    }
  }

  // Comments
  Future<List<CommentModel>> getReelComments(String reelId, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/reels/$reelId/comments?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> comments = data['comments'] ?? data;
      return comments.map((json) => CommentModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.body}');
    }
  }

  Future<CommentModel> addReelComment(String reelId, String comment, {
    String? parentCommentId,
  }) async {
    final body = {
      'content': comment,
      if (parentCommentId != null) 'parentId': parentCommentId,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/reels/$reelId/comments'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return CommentModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add comment: ${response.body}');
    }
  }

  // Analytics
  Future<void> recordReelView(String reelId, int watchTime) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/reels/$reelId/view'),
      headers: _headers,
      body: jsonEncode({
        'watchTime': watchTime,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      print('Failed to record reel view: ${response.body}');
    }
  }

  // Search reels
  Future<List<VideoModel>> searchReels(String query, {
    int page = 1,
    int limit = 10,
    String? filter, // 'recent', 'popular', 'duration'
  }) async {
    var url = '$baseUrl/api/reels/search?q=$query&page=$page&limit=$limit';
    if (filter != null) {
      url += '&filter=$filter';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> reels = data['reels'] ?? data;
      return reels.map((json) => VideoModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search reels: ${response.body}');
    }
  }

  // Get reel suggestions based on user preferences
  Future<List<VideoModel>> getReelSuggestions({
    int limit = 10,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/reels/suggestions?limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => VideoModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reel suggestions: ${response.body}');
    }
  }

  // Report reel
  Future<void> reportReel(String reelId, String reason, {String? details}) async {
    final body = {
      'reason': reason,
      if (details != null) 'details': details,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/reels/$reelId/report'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to report reel: ${response.body}');
    }
  }

  // Delete reel
  Future<void> deleteReel(String reelId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/reels/$reelId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete reel: ${response.body}');
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
  final String? parentId;
  final List<CommentModel>? replies;

  CommentModel({
    required this.id,
    required this.content,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
    this.parentId,
    this.replies,
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
      parentId: json['parentId'],
      replies: json['replies'] != null
          ? (json['replies'] as List).map((r) => CommentModel.fromJson(r)).toList()
          : null,
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
      'parentId': parentId,
      'replies': replies?.map((r) => r.toJson()).toList(),
    };
  }
}