import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config/api_config.dart';

class BackendHealthChecker {
  static const int maxRetries = 10;
  static const Duration retryDelay = Duration(seconds: 2);

  static Future<bool> waitForBackend() async {
    return true;
  }

  static Future<bool> isBackendReady() async {
    return true;
  }

  static Future<bool> _testUrl(String baseUrl) async {
    try {
      debugPrint('Testing URL: $baseUrl/api/v1/health');
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));

      debugPrint('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Response data: $data');
        return data['status'] == 'ok';
      }
      return false;
    } catch (e) {
      debugPrint('URL test failed for $baseUrl: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getBackendInfo() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error getting backend info: $e');
    }
    return null;
  }
}