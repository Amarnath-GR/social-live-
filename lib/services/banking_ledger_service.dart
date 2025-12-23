import 'api_client.dart';

class BankingLedgerService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> createTransaction({
    required String description,
    required List<Map<String, dynamic>> entries,
    String? referenceId,
    String? referenceType,
  }) async {
    try {
      final response = await _apiClient.post('/ledger/transactions', data: {
        'description': description,
        'entries': entries,
        'referenceId': referenceId,
        'referenceType': referenceType,
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getAccountBalance(String accountId) async {
    try {
      final response = await _apiClient.get('/ledger/accounts/$accountId/balance');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getJournalEntries({
    String? accountId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _apiClient.get('/ledger/entries', queryParameters: {
        if (accountId != null) 'accountId': accountId,
        'page': page,
        'limit': limit,
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> reconcileAccount(String accountId) async {
    try {
      final response = await _apiClient.post('/ledger/accounts/$accountId/reconcile');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createAccount({
    required String userId,
    required String type,
    required String currency,
  }) async {
    try {
      final response = await _apiClient.post('/ledger/accounts', data: {
        'userId': userId,
        'type': type,
        'currency': currency,
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
