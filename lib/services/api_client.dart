import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() {
    _initializeDio();
  }

  static const String _tokenKey = 'access_token';
  
  late Dio _dio;
  bool _isInitialized = false;

  void _initializeDio() {
    if (_isInitialized) return;
    
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await _getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          // Ignore token errors
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _handleUnauthorized();
        }
        handler.next(error);
      },
    ));
    
    _isInitialized = true;
  }

  void initialize() {
    _initializeDio();
  }

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> _handleUnauthorized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove('refresh_token');
    } catch (e) {
      // Ignore storage errors
    }
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    throw ApiException(message: 'Backend disabled', statusCode: 0);
  }

  Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    throw ApiException(message: 'Backend disabled', statusCode: 0);
  }

  Future<Response<T>> put<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    throw ApiException(message: 'Backend disabled', statusCode: 0);
  }

  Future<Response<T>> delete<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    throw ApiException(message: 'Backend disabled', statusCode: 0);
  }

  Future<Response<T>> uploadFile<T>(String path, String filePath, {String fieldName = 'file', Map<String, dynamic>? data, Options? options}) async {
    throw ApiException(message: 'Backend disabled', statusCode: 0);
  }

  ApiException _handleDioError(DioException error) {
    String message = 'Connection error';
    int statusCode = 0;

    if (error.response != null) {
      statusCode = error.response!.statusCode ?? 0;
      final data = error.response!.data;
      
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        message = data['message'];
      } else {
        message = error.response!.statusMessage ?? 'Server error';
      }
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Connection timeout - check if backend is running';
          break;
        case DioExceptionType.connectionError:
          message = 'Cannot connect to server - check backend connection';
          break;
        default:
          message = 'Network error - please try again';
      }
    }

    return ApiException(message: message, statusCode: statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => message;
}