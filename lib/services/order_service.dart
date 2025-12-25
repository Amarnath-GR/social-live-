import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

class OrderService {
  static final String _baseUrl = '${ApiConfig.baseUrl}/api/v1';

  // Create new order
  static Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
    String? couponCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'items': items,
          'shippingAddress': shippingAddress,
          'couponCode': couponCode,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'order': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create order',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating order: $e',
      };
    }
  }

  // Get order by ID
  static Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'order': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Order not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting order: $e',
      };
    }
  }

  // Get user orders
  static Future<Map<String, dynamic>> getUserOrders({
    int page = 1,
    int limit = 20,
    OrderStatus? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (status != null) {
        queryParams['status'] = status.name;
      }

      final uri = Uri.parse('$_baseUrl/marketplace/orders').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        final responseData = data['data'];
        List<Map<String, dynamic>> orders = [];
        
        if (responseData is List) {
          orders = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map) {
          if (responseData['orders'] != null) {
            orders = List<Map<String, dynamic>>.from(responseData['orders']);
          } else if (responseData['data'] != null) {
            orders = List<Map<String, dynamic>>.from(responseData['data']);
          }
        }
        
        return {
          'success': true,
          'orders': orders,
          'pagination': responseData is Map ? (responseData['pagination'] ?? {}) : {},
        };
      } else {
        // Return empty orders instead of error for better UX
        return {
          'success': true,
          'orders': [],
          'pagination': {},
        };
      }
    } catch (e) {
      // Return empty orders instead of error for better UX
      return {
        'success': true,
        'orders': [],
        'pagination': {},
      };
    }
  }

  // Update order status
  static Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? notes,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'status': status.name,
          'notes': notes,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'order': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update order status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating order status: $e',
      };
    }
  }

  // Cancel order
  static Future<Map<String, dynamic>> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/orders/$orderId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'reason': reason,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'order': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to cancel order',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error cancelling order: $e',
      };
    }
  }

  // Request refund
  static Future<Map<String, dynamic>> requestRefund({
    required String orderId,
    required String reason,
    List<String>? itemIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/orders/$orderId/refund'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'reason': reason,
          'itemIds': itemIds,
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
          'message': data['message'] ?? 'Failed to request refund',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error requesting refund: $e',
      };
    }
  }

  // Track order
  static Future<Map<String, dynamic>> trackOrder(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/$orderId/tracking'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'tracking': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get tracking info',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error tracking order: $e',
      };
    }
  }

  // Get order invoice
  static Future<Map<String, dynamic>> getOrderInvoice(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/$orderId/invoice'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'invoice': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get invoice',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting invoice: $e',
      };
    }
  }

  // Helper method to get auth token
  static Future<String?> _getAuthToken() async {
    return await AuthService().getToken();
  }

  // Get order status color
  static Color getOrderStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.grey;
    }
  }

  // Get order status display text
  static String getOrderStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  // Parse order status from string
  static OrderStatus parseOrderStatus(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }
}
