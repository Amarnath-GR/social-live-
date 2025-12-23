import 'dart:convert';
import 'package:http/http.dart' as http;

class CdnService {
  static const String _cdnBaseUrl = String.fromEnvironment('CDN_URL', defaultValue: 'https://d1234567890.cloudfront.net');
  static const String _apiBaseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000');

  static String getMediaUrl(String path) {
    return '$_cdnBaseUrl/$path';
  }

  static String getVideoUrl(String videoId) {
    return '$_cdnBaseUrl/videos/$videoId/master.m3u8';
  }

  static Future<Map<String, dynamic>> invalidateCache(List<String> paths, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/cdn/invalidate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'paths': paths}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Invalidation failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> uploadVideo(String filePath, String token) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiBaseUrl/api/media/upload'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('video', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Upload failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
