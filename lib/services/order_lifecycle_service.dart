import '../models/commerce_models.dart';
import 'api_client.dart';
import 'inventory_service.dart';
import 'tax_service.dart';

class OrderLifecycleService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> createOrder({
    required String customerId,
    required List<OrderItem> items,
    required Map<String, dynamic> shippingAddress,
  }) async {
    try {
      // Reserve stock for all items
      final reservations = <String>[];
      for (final item in items) {
        final reservation = await InventoryService.reserveStock(item.productId, item.quantity);
        if (!reservation['success']) {
          // Release any successful reservations
          for (final resId in reservations) {
            await InventoryService.releaseReservation(resId);
          }
          return {'success': false, 'message': 'Insufficient stock for ${item.productName}'};
        }
        reservations.add(reservation['reservationId']);
      }

      // Calculate tax
      final subtotal = items.fold(0.0, (sum, item) => sum + item.total);
      final taxCalc = await TaxService.calculateTax(subtotal, shippingAddress);
      final tax = taxCalc['success'] ? taxCalc['tax'].amount : 0.0;

      final orderData = {
        'customerId': customerId,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'total': subtotal + tax,
        'shippingAddress': shippingAddress,
        'reservations': reservations,
      };

      final response = await _apiClient.post('/orders', data: orderData);
      return {'success': true, 'order': Order.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final response = await _apiClient.put('/orders/$orderId/status', data: {
        'status': status.name,
      });
      return {'success': true, 'order': Order.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final response = await _apiClient.get('/orders/$orderId');
      return {'success': true, 'order': Order.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getOrdersByCustomer(String customerId) async {
    try {
      final response = await _apiClient.get('/orders/customer/$customerId');
      final orders = (response.data['orders'] as List)
          .map((e) => Order.fromJson(e))
          .toList();
      return {'success': true, 'orders': orders};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getOrdersBySeller(String sellerId) async {
    try {
      final response = await _apiClient.get('/orders/seller/$sellerId');
      final orders = (response.data['orders'] as List)
          .map((e) => Order.fromJson(e))
          .toList();
      return {'success': true, 'orders': orders};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> confirmOrder(String orderId) async {
    return updateOrderStatus(orderId, OrderStatus.confirmed);
  }

  static Future<Map<String, dynamic>> processOrder(String orderId) async {
    return updateOrderStatus(orderId, OrderStatus.processing);
  }

  static Future<Map<String, dynamic>> shipOrder(String orderId, {String? trackingNumber}) async {
    try {
      final response = await _apiClient.put('/orders/$orderId/ship', data: {
        'trackingNumber': trackingNumber,
      });
      return {'success': true, 'order': Order.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deliverOrder(String orderId) async {
    return updateOrderStatus(orderId, OrderStatus.delivered);
  }

  static Future<Map<String, dynamic>> cancelOrder(String orderId, String reason) async {
    try {
      final response = await _apiClient.put('/orders/$orderId/cancel', data: {
        'reason': reason,
      });
      return {'success': true, 'order': Order.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getOrderTracking(String orderId) async {
    try {
      final response = await _apiClient.get('/orders/$orderId/tracking');
      return {'success': true, 'tracking': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
