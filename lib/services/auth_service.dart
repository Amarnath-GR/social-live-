import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoggedIn = false;
  String? _currentUserId;
  String? _currentUserEmail;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserId => _currentUserId;
  String? get currentUserEmail => _currentUserEmail;

  Future<bool> login(String email, String password) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      _isLoggedIn = true;
      _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _currentUserEmail = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password, String name) async {
    if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
      _isLoggedIn = true;
      _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _currentUserEmail = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> signOut() async {
    _isLoggedIn = false;
    _currentUserId = null;
    _currentUserEmail = null;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  Future<void> logout() async {
    await signOut();
  }

  Future<String?> getToken() async {
    // Return mock token for authenticated user
    if (_isLoggedIn) {
      return 'mock_token_${_currentUserId}';
    }
    return null;
  }

  // Admin functions
  static Future<Map<String, dynamic>> getAllUsers() async {
    return {
      'success': true,
      'users': [
        UserModel(
          id: '1',
          username: 'john_doe',
          email: 'john@demo.com',
          name: 'John Doe',
          role: 'user',
          verified: true,
          isBlocked: false,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
        ),
        UserModel(
          id: '2',
          username: 'jane_smith',
          email: 'jane@demo.com',
          name: 'Jane Smith',
          role: 'creator',
          verified: false,
          isBlocked: false,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now(),
        ),
      ],
    };
  }

  static Future<Map<String, dynamic>> suspendUser(String userId) async {
    return {'success': true, 'message': 'User suspended'};
  }

  static Future<Map<String, dynamic>> activateUser(String userId) async {
    return {'success': true, 'message': 'User activated'};
  }

  static Future<Map<String, dynamic>> deleteUser(String userId) async {
    return {'success': true, 'message': 'User deleted'};
  }

  static Future<Map<String, dynamic>> resetUserPassword(String userId) async {
    return {'success': true, 'message': 'Password reset'};
  }
}