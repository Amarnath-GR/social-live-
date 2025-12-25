import 'api_client.dart';
import '../models/ledger_models.dart';

class AccountService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> createAccount({
    required String userId,
    required AccountType type,
    required String currency,
  }) async {
    try {
      final response = await _apiClient.post('/ledger/accounts', data: {
        'userId': userId,
        'type': type.name,
        'currency': currency,
      });

      if (response.data['success'] == true) {
        return {
          'success': true,
          'account': Account.fromJson(response.data['data']),
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Account creation failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> getAccount(String accountId) async {
    try {
      final response = await _apiClient.get('/ledger/accounts/$accountId');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'account': Account.fromJson(response.data['data']),
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Account fetch failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUserAccounts(String userId) async {
    try {
      final response = await _apiClient.get('/ledger/users/$userId/accounts');

      if (response.data['success'] == true) {
        final accounts = (response.data['data'] as List)
            .map((a) => Account.fromJson(a))
            .toList();
        return {
          'success': true,
          'accounts': accounts,
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Accounts fetch failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> getPlatformAccount(String currency) async {
    try {
      final response = await _apiClient.get('/ledger/accounts/platform/$currency');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'account': Account.fromJson(response.data['data']),
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Platform account fetch failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> getEscrowAccount(String currency) async {
    try {
      final response = await _apiClient.get('/ledger/accounts/escrow/$currency');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'account': Account.fromJson(response.data['data']),
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Escrow account fetch failed: $e'};
    }
  }
}
