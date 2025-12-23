import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class PaymentService {
  static const String _stripePublishableKey = 'pk_test_your_stripe_publishable_key';
  static final String _baseUrl = ApiConfig.baseUrl;

  // Create payment intent for order
  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String orderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/create-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'amount': (amount * 100).round(), // Convert to cents
          'currency': currency,
          'orderId': orderId,
          'metadata': metadata ?? {},
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'clientSecret': data['data']['clientSecret'],
          'paymentIntentId': data['data']['paymentIntentId'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create payment intent',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating payment intent: $e',
      };
    }
  }

  // Confirm payment
  static Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'paymentIntentId': paymentIntentId,
          'paymentMethodId': paymentMethodId,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'payment': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Payment confirmation failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error confirming payment: $e',
      };
    }
  }

  // Get payment status
  static Future<Map<String, dynamic>> getPaymentStatus(String paymentIntentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/status/$paymentIntentId'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'status': data['data']['status'],
          'payment': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get payment status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting payment status: $e',
      };
    }
  }

  // Process refund
  static Future<Map<String, dynamic>> processRefund({
    required String paymentIntentId,
    required double amount,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/refund'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'paymentIntentId': paymentIntentId,
          'amount': (amount * 100).round(), // Convert to cents
          'reason': reason ?? 'requested_by_customer',
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'refund': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Refund processing failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error processing refund: $e',
      };
    }
  }

  // Get saved payment methods
  static Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/methods'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'paymentMethods': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get payment methods',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting payment methods: $e',
      };
    }
  }

  // Save payment method
  static Future<Map<String, dynamic>> savePaymentMethod({
    required String paymentMethodId,
    required bool setAsDefault,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/save-method'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'paymentMethodId': paymentMethodId,
          'setAsDefault': setAsDefault,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'paymentMethod': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to save payment method',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error saving payment method: $e',
      };
    }
  }

  // Helper method to get auth token
  static Future<String?> _getAuthToken() async {
    // This should get the token from your auth service
    // For now, returning a placeholder
    return 'your_auth_token_here';
  }

  // Validate card details
  static Map<String, dynamic> validateCardDetails({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
  }) {
    final errors = <String>[];

    // Remove spaces from card number
    final cleanCardNumber = cardNumber.replaceAll(' ', '');

    // Validate card number
    if (cleanCardNumber.isEmpty) {
      errors.add('Card number is required');
    } else if (cleanCardNumber.length < 13 || cleanCardNumber.length > 19) {
      errors.add('Invalid card number length');
    } else if (!RegExp(r'^\d+$').hasMatch(cleanCardNumber)) {
      errors.add('Card number must contain only digits');
    }

    // Validate expiry month
    final month = int.tryParse(expiryMonth);
    if (month == null || month < 1 || month > 12) {
      errors.add('Invalid expiry month');
    }

    // Validate expiry year
    final year = int.tryParse(expiryYear);
    final currentYear = DateTime.now().year;
    if (year == null || year < currentYear || year > currentYear + 20) {
      errors.add('Invalid expiry year');
    }

    // Validate CVV
    if (cvv.isEmpty) {
      errors.add('CVV is required');
    } else if (cvv.length < 3 || cvv.length > 4) {
      errors.add('Invalid CVV');
    } else if (!RegExp(r'^\d+$').hasMatch(cvv)) {
      errors.add('CVV must contain only digits');
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
    };
  }

  // Get card type from number
  static String getCardType(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(' ', '');
    
    if (cleanNumber.startsWith('4')) {
      return 'Visa';
    } else if (cleanNumber.startsWith('5') || cleanNumber.startsWith('2')) {
      return 'Mastercard';
    } else if (cleanNumber.startsWith('3')) {
      return 'American Express';
    } else if (cleanNumber.startsWith('6')) {
      return 'Discover';
    } else {
      return 'Unknown';
    }
  }
}
