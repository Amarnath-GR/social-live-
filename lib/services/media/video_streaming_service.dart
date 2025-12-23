import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cdn_service.dart';

class VideoStreamingService {
  static const String _apiBaseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000');

  static Future<Map<String, dynamic>> getVideoManifest(String videoId) async {
    try {
      final manifestUrl = CdnService.getVideoUrl(videoId);
      final response = await http.get(Uri.parse(manifestUrl));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'manifestUrl': manifestUrl,
          'manifest': response.body,
        };
      }
      return {'success': false, 'message': 'Manifest not found'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getVideoMetadata(String videoId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/videos/$videoId/metadata'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Metadata not found'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static List<Map<String, dynamic>> parseQualityLevels(String manifest) {
    final qualities = <Map<String, dynamic>>[];
    final lines = manifest.split('\n');

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('#EXT-X-STREAM-INF:')) {
        final streamInfo = lines[i];
        final bandwidth = _extractBandwidth(streamInfo);
        final resolution = _extractResolution(streamInfo);
        
        if (i + 1 < lines.length && !lines[i + 1].startsWith('#')) {
          qualities.add({
            'bandwidth': bandwidth,
            'resolution': resolution,
            'url': lines[i + 1],
            'label': _getQualityLabel(resolution),
          });
        }
      }
    }

    qualities.sort((a, b) => b['bandwidth'].compareTo(a['bandwidth']));
    return qualities;
  }

  static int _extractBandwidth(String streamInfo) {
    final bandwidthMatch = RegExp(r'BANDWIDTH=(\d+)').firstMatch(streamInfo);
    return bandwidthMatch != null ? int.parse(bandwidthMatch.group(1)!) : 0;
  }

  static String _extractResolution(String streamInfo) {
    final resolutionMatch = RegExp(r'RESOLUTION=(\d+x\d+)').firstMatch(streamInfo);
    return resolutionMatch?.group(1) ?? 'Unknown';
  }

  static String _getQualityLabel(String resolution) {
    switch (resolution) {
      case '1280x720':
        return '720p HD';
      case '854x480':
        return '480p';
      case '640x360':
        return '360p';
      default:
        return resolution;
    }
  }
}
