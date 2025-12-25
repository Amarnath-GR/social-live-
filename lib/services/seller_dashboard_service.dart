import '../models/commerce_models.dart';
import 'api_client.dart';

class SellerDashboardService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> getDashboardData(String sellerId) async {
    try {
      final response = await _apiClient.get('/seller/$sellerId/dashboard');
      return {'success': true, 'data': SellerDashboardData.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getSalesAnalytics(
    String sellerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _apiClient.get(
        '/seller/$sellerId/analytics?start=${startDate.toIso8601String()}&end=${endDate.toIso8601String()}',
      );
      return {'success': true, 'analytics': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getTopProducts(String sellerId, {int limit = 10}) async {
    try {
      final response = await _apiClient.get('/seller/$sellerId/products/top?limit=$limit');
      final products = (response.data['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList();
      return {'success': true, 'products': products};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getRevenueReport(
    String sellerId,
    String period, // 'daily', 'weekly', 'monthly'
  ) async {
    try {
      final response = await _apiClient.get('/seller/$sellerId/revenue?period=$period');
      return {'success': true, 'report': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getOrderMetrics(String sellerId) async {
    try {
      final response = await _apiClient.get('/seller/$sellerId/orders/metrics');
      return {'success': true, 'metrics': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getCustomerInsights(String sellerId) async {
    try {
      final response = await _apiClient.get('/seller/$sellerId/customers/insights');
      return {'success': true, 'insights': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getInventoryAlerts(String sellerId) async {
    try {
      final response = await _apiClient.get('/seller/$sellerId/inventory/alerts');
      return {'success': true, 'alerts': response.data['alerts']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateSellerSettings(String sellerId, Map<String, dynamic> settings) async {
    try {
      final response = await _apiClient.put('/seller/$sellerId/settings', data: settings);
      return {'success': true, 'settings': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getPayoutHistory(String sellerId) async {
    try {
      final response = await _apiClient.get('/seller/$sellerId/payouts');
      return {'success': true, 'payouts': response.data['payouts']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> requestPayout(String sellerId, double amount) async {
    try {
      final response = await _apiClient.post('/seller/$sellerId/payouts', data: {
        'amount': amount,
      });
      return {'success': true, 'payout': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
