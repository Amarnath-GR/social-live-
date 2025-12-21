import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://192.168.1.6:3000/api/v1';
    }
    return 'http://localhost:3000/api/v1';
  }
  
  static const Duration timeout = Duration(seconds: 10);
}