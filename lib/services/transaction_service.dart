import 'api_client.dart';

class TransactionService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> getTransactionHistory({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (type != null) {
        queryParams['type'] = type;
      }

      final response = await _apiClient.get(
        '/wallet/transactions',
        queryParameters: queryParams,
      );
      
      if (response.data['success'] == true) {
        return {
          'success': true,
          'transactions': response.data['data']['transactions'] ?? response.data['data'],
          'pagination': response.data['data']['pagination'] ?? {},
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get transactions'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting transactions: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      final response = await _apiClient.get('/wallet');
      
      if (response.data['success'] == true) {
        return {
          'success': true,
          'wallet': response.data['data']
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get wallet balance'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting wallet balance: $e'
      };
    }
  }
}