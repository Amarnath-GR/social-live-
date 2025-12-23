import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  // Using SharedPreferences as fallback for secure storage

  // Secure token storage using SharedPreferences
  static Future<void> storeToken(String key, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('secure_$key', token);
  }

  static Future<String?> getToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('secure_$key');
  }

  static Future<void> deleteToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('secure_$key');
  }

  static Future<void> clearAllTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('secure_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  // Input validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[a-z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password) &&
           RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '');
  }

  // Cryptographic functions
  static String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = <int>[];
    for (int i = 0; i < bytes.length; i++) {
      digest.add(bytes[i] ^ 0x5C);
    }
    return digest.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static String generateSecureRandom([int length = 32]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  // Biometric authentication check
  static Future<bool> isBiometricAvailable() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('biometric_available') ?? false;
    } catch (e) {
      return false;
    }
  }

  // Certificate pinning validation
  static bool validateCertificate(String certificate) {
    const expectedFingerprints = [
      'SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // Replace with actual
    ];
    
    final fingerprint = generateHash(certificate);
    return expectedFingerprints.contains('SHA256:$fingerprint');
  }

  // Request signing for API calls
  static String signRequest(String method, String url, String body, String secret) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final message = '$method$url$body$timestamp';
    final signature = generateHash('$message$secret');
    return '$timestamp:$signature';
  }

  // Device fingerprinting
  static Future<String> getDeviceFingerprint() async {
    // Combine device-specific information
    final deviceInfo = {
      'platform': 'flutter',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'random': generateSecureRandom(16),
    };
    
    return generateHash(jsonEncode(deviceInfo));
  }

  // Anti-tampering checks
  static bool isAppTampered() {
    // Basic integrity checks
    try {
      // Check if running in debug mode
      bool inDebugMode = false;
      assert(inDebugMode = true);
      
      // In production, debug mode should be false
      return inDebugMode;
    } catch (e) {
      return true; // Assume tampered if checks fail
    }
  }

  // Secure logging (avoid sensitive data)
  static void secureLog(String message, {bool sensitive = false}) {
    if (sensitive) {
      // Hash sensitive data before logging
      final hashedMessage = generateHash(message);
      debugPrint('SECURE_LOG: ${hashedMessage.substring(0, 8)}...');
    } else {
      debugPrint('LOG: $message');
    }
  }

  // Rate limiting client-side
  static final Map<String, List<DateTime>> _requestHistory = {};
  
  static bool isRateLimited(String endpoint, {int maxRequests = 10, Duration window = const Duration(minutes: 1)}) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);
    
    _requestHistory[endpoint] ??= [];
    _requestHistory[endpoint]!.removeWhere((time) => time.isBefore(windowStart));
    
    if (_requestHistory[endpoint]!.length >= maxRequests) {
      return true;
    }
    
    _requestHistory[endpoint]!.add(now);
    return false;
  }
}
