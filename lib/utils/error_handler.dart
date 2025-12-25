import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../config/environment.dart';

class ErrorHandler {
  static void logError(dynamic error, StackTrace? stackTrace, {String? context}) {
    if (EnvironmentConfig.enableLogging) {
      developer.log(
        'Error: $error',
        name: 'ErrorHandler',
        error: error,
        stackTrace: stackTrace,
      );
    }
    
    if (EnvironmentConfig.enableCrashReporting) {
      // TODO: Integrate with crash reporting service (Firebase Crashlytics, Sentry, etc.)
      _reportToCrashlytics(error, stackTrace, context);
    }
  }
  
  static void _reportToCrashlytics(dynamic error, StackTrace? stackTrace, String? context) {
    // Placeholder for crash reporting integration
    if (kDebugMode) {
      print('Would report to crashlytics: $error');
    }
  }
  
  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException') || 
        error.toString().contains('TimeoutException')) {
      return 'Network connection error. Please check your internet connection.';
    }
    
    if (error.toString().contains('FormatException')) {
      return 'Invalid data format received from server.';
    }
    
    if (error.toString().contains('401')) {
      return 'Authentication failed. Please log in again.';
    }
    
    if (error.toString().contains('403')) {
      return 'Access denied. You don\'t have permission for this action.';
    }
    
    if (error.toString().contains('404')) {
      return 'Requested resource not found.';
    }
    
    if (error.toString().contains('500')) {
      return 'Server error. Please try again later.';
    }
    
    return EnvironmentConfig.isProduction 
        ? 'Something went wrong. Please try again.'
        : error.toString();
  }
  
  static void handleError(dynamic error, StackTrace? stackTrace, {String? context}) {
    logError(error, stackTrace, context: context);
    
    // Additional error handling logic can be added here
    // such as showing user notifications, logging to analytics, etc.
  }
}