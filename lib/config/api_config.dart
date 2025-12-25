class ApiConfig {
  static String get baseUrl => '';
  
  static List<String> get fallbackUrls => [];
  
  static const Duration timeout = Duration(seconds: 1);
  static const Duration connectTimeout = Duration(seconds: 1);
  static const Duration receiveTimeout = Duration(seconds: 1);
}