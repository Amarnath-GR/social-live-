import '../models/commerce_models.dart';
import 'api_client.dart';

class TaxService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> calculateTax(
    double amount,
    Map<String, dynamic> address,
  ) async {
    try {
      final response = await _apiClient.post('/tax/calculate', data: {
        'amount': amount,
        'address': address,
      });
      return {'success': true, 'tax': TaxCalculation.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getTaxRates(String jurisdiction) async {
    try {
      final response = await _apiClient.get('/tax/rates/$jurisdiction');
      return {'success': true, 'rates': response.data['rates']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> validateTaxId(String taxId, String country) async {
    try {
      final response = await _apiClient.post('/tax/validate', data: {
        'taxId': taxId,
        'country': country,
      });
      return {'success': true, 'valid': response.data['valid']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getExemptions(String customerId) async {
    try {
      final response = await _apiClient.get('/tax/exemptions/$customerId');
      return {'success': true, 'exemptions': response.data['exemptions']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> applyExemption(String customerId, String exemptionId) async {
    try {
      final response = await _apiClient.post('/tax/exemptions/apply', data: {
        'customerId': customerId,
        'exemptionId': exemptionId,
      });
      return {'success': true, 'applied': response.data['applied']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getTaxReport(String sellerId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await _apiClient.get(
        '/tax/report/$sellerId?start=${startDate.toIso8601String()}&end=${endDate.toIso8601String()}',
      );
      return {'success': true, 'report': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
