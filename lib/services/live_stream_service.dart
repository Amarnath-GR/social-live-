import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gift_model.dart';

class LiveStreamService {
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

  Future<String> createLiveStream(String title, String description) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/live-streams'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      throw Exception('Failed to create live stream: ${response.body}');
    }
  }

  Future<void> endLiveStream(String streamId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/live-streams/$streamId/end'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to end live stream: ${response.body}');
    }
  }

  Future<void> sendGift(String streamId, String giftId, int quantity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/live-streams/$streamId/gifts'),
      headers: _headers,
      body: jsonEncode({
        'giftId': giftId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send gift: ${response.body}');
    }
  }

  Future<void> sendMessage(String streamId, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/live-streams/$streamId/messages'),
      headers: _headers,
      body: jsonEncode({
        'message': message,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send message: ${response.body}');
    }
  }

  Future<List<GiftModel>> getAvailableGifts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/gifts'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GiftModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load gifts: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getStreamStats(String streamId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/live-streams/$streamId/stats'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load stream stats: ${response.body}');
    }
  }
}