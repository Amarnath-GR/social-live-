import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:2307/api/v1';
    }
    return 'http://localhost:2307/api/v1';
  }
  
  static List<String> get fallbackUrls => [
    'http://192.168.1.6:2307/api/v1',
    'http://127.0.0.1:2307/api/v1',
    'http://localhost:2307/api/v1',
  ];
  
  static const Duration timeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);
}