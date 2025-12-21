import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      
      if (data is Map<String, dynamic>) {
        if (data.containsKey('accessToken') && data.containsKey('user')) {
          await _saveTokens(
            data['accessToken'],
            data['refreshToken'] ?? '',
          );
          return {'success': true, 'user': data['user']};
        }
        
        if (data['success'] == true && data.containsKey('data')) {
          final responseData = data['data'];
          if (responseData.containsKey('tokens')) {
            await _saveTokens(
              responseData['tokens']['accessToken'],
              responseData['tokens']['refreshToken'],
            );
            return {'success': true, 'user': responseData['user']};
          }
        }
        
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
      
      return {'success': false, 'message': 'Invalid response format'};
    } catch (e) {
      return {'success': false, 'message': _getErrorMessage(e)};
    }
  }

  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await _apiClient.get('/health');
      return {
        'success': true, 
        'message': 'Backend connected successfully', 
        'data': response.data
      };
    } catch (e) {
      return {
        'success': false, 
        'message': _getErrorMessage(e), 
        'details': e.toString()
      };
    }
  }

  static Future<void> _saveTokens(String accessToken, String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, accessToken);
      if (refreshToken.isNotEmpty) {
        await prefs.setString(_refreshTokenKey, refreshToken);
      }
    } catch (e) {
      // Ignore storage errors
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
    } catch (e) {
      // Ignore storage errors
    }
  }

  static String _getErrorMessage(dynamic error) {
    if (error.toString().contains('Connection timeout') || 
        error.toString().contains('Cannot connect')) {
      return 'Cannot connect to server. Please check if the backend is running.';
    }
    return error.toString();
  }
}