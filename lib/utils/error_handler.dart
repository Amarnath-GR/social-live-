import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error is Map<String, dynamic>) {
      return error['message'] ?? 'An error occurred';
    }
    return error.toString();
  }

  static bool isNetworkError(dynamic error) {
    final message = error.toString().toLowerCase();
    return message.contains('network') || 
           message.contains('connection') || 
           message.contains('timeout');
  }
}