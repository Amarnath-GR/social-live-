import '../models/commerce_models.dart';
import 'api_client.dart';

class InventoryService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> getInventory(String sellerId) async {
    try {
      final response = await _apiClient.get('/inventory/$sellerId');
      final products = (response.data['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList();
      return {'success': true, 'products': products};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateStock(String productId, int quantity) async {
    try {
      final response = await _apiClient.put('/inventory/$productId/stock', data: {
        'quantity': quantity,
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> checkAvailability(String productId, int quantity) async {
    try {
      final response = await _apiClient.get('/inventory/$productId/availability?quantity=$quantity');
      return {'success': true, 'available': response.data['available']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> reserveStock(String productId, int quantity) async {
    try {
      final response = await _apiClient.post('/inventory/$productId/reserve', data: {
        'quantity': quantity,
      });
      return {'success': true, 'reservationId': response.data['reservationId']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> releaseReservation(String reservationId) async {
    try {
      await _apiClient.delete('/inventory/reservations/$reservationId');
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> addProduct(Product product) async {
    try {
      final response = await _apiClient.post('/inventory/products', data: product.toJson());
      return {'success': true, 'product': Product.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.put('/inventory/products/$productId', data: updates);
      return {'success': true, 'product': Product.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getLowStockProducts(String sellerId, {int threshold = 10}) async {
    try {
      final response = await _apiClient.get('/inventory/$sellerId/low-stock?threshold=$threshold');
      final products = (response.data['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList();
      return {'success': true, 'products': products};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
