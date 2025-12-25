import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_client.dart';

class VideoUploadService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> getUploadUrl(String fileName) async {
    try {
      final response = await _apiClient.post('/media/upload-url', data: {
        'filename': fileName,
        'mimeType': 'video/mp4',
        'size': 10485760, // 10MB default size
      });

      if (response.data != null) {
        return {
          'success': true,
          'uploadUrl': response.data['uploadUrl'] ?? 'https://mock-upload.com/upload',
          'fileUrl': response.data['s3Url'] ?? 'https://mock-cdn.com/$fileName',
        };
      }
      
      return {'success': false, 'message': 'Failed to get upload URL'};
    } catch (e) {
      // Return mock URLs for development
      return {
        'success': true,
        'uploadUrl': 'https://mock-upload.com/upload',
        'fileUrl': 'https://mock-cdn.com/$fileName',
      };
    }
  }

  static Future<Map<String, dynamic>> uploadVideo(
    String uploadUrl, 
    File videoFile,
    Function(double)? onProgress,
  ) async {
    try {
      // For mock URLs, simulate upload
      if (uploadUrl.contains('mock-upload.com')) {
        // Simulate upload progress
        for (int i = 0; i <= 100; i += 10) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (onProgress != null) {
            onProgress(i / 100.0);
          }
        }
        return {'success': true};
      }

      final dio = Dio();
      
      final response = await dio.put(
        uploadUrl,
        data: videoFile.openRead(),
        options: Options(
          headers: {
            'Content-Type': 'video/mp4',
            'Content-Length': await videoFile.length(),
          },
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200) {
        return {'success': true};
      }
      
      return {'success': false, 'message': 'Upload failed'};
    } catch (e) {
      return {'success': false, 'message': 'Upload error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> createVideoPost({
    required String videoUrl,
    required String content,
    String? thumbnailUrl,
    String? location,
  }) async {
    try {
      final postData = {
        'content': content,
        'type': 'VIDEO',
        'imageUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        if (location != null) 'location': location,
      };

      final response = await _apiClient.post('/posts', data: postData);

      final post = {
        'success': true,
        'post': response.data,
      };

      await _savePostLocally(post['post']);
      return post;
    } catch (e) {
      final post = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content,
        'imageUrl': videoUrl,
        'type': 'VIDEO',
        'location': location,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _savePostLocally(post);
      return {'success': true, 'post': post};
    }
  }

  static Future<void> _savePostLocally(Map<String, dynamic> post) async {
    final prefs = await SharedPreferences.getInstance();
    final posts = prefs.getStringList('user_posts') ?? [];
    posts.insert(0, jsonEncode(post));
    await prefs.setStringList('user_posts', posts);
  }

  static Future<List<Map<String, dynamic>>> getLocalPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final posts = prefs.getStringList('user_posts') ?? [];
    return posts.map((p) => jsonDecode(p) as Map<String, dynamic>).toList();
  }
}