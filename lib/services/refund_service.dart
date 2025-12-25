import '../models/commerce_models.dart';
import 'api_client.dart';

class RefundService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> requestRefund({
    required String orderId,
    required double amount,
    required String reason,
  }) async {
    try {
      final response = await _apiClient.post('/refunds', data: {
        'orderId': orderId,
        'amount': amount,
        'reason': reason,
      });
      return {'success': true, 'refund': Refund.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> approveRefund(String refundId) async {
    try {
      final response = await _apiClient.put('/refunds/$refundId/approve');
      return {'success': true, 'refund': Refund.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> rejectRefund(String refundId, String reason) async {
    try {
      final response = await _apiClient.put('/refunds/$refundId/reject', data: {
        'reason': reason,
      });
      return {'success': true, 'refund': Refund.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> processRefund(String refundId) async {
    try {
      final response = await _apiClient.put('/refunds/$refundId/process');
      return {'success': true, 'refund': Refund.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getRefund(String refundId) async {
    try {
      final response = await _apiClient.get('/refunds/$refundId');
      return {'success': true, 'refund': Refund.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getRefundsByOrder(String orderId) async {
    try {
      final response = await _apiClient.get('/refunds/order/$orderId');
      final refunds = (response.data['refunds'] as List)
          .map((e) => Refund.fromJson(e))
          .toList();
      return {'success': true, 'refunds': refunds};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getPendingRefunds(String sellerId) async {
    try {
      final response = await _apiClient.get('/refunds/seller/$sellerId/pending');
      final refunds = (response.data['refunds'] as List)
          .map((e) => Refund.fromJson(e))
          .toList();
      return {'success': true, 'refunds': refunds};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> calculateRefundAmount(String orderId, List<String> itemIds) async {
    try {
      final response = await _apiClient.post('/refunds/calculate', data: {
        'orderId': orderId,
        'itemIds': itemIds,
      });
      return {'success': true, 'amount': response.data['amount']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getRefundHistory(String customerId) async {
    try {
      final response = await _apiClient.get('/refunds/customer/$customerId');
      final refunds = (response.data['refunds'] as List)
          .map((e) => Refund.fromJson(e))
          .toList();
      return {'success': true, 'refunds': refunds};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
