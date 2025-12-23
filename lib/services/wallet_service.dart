import 'api_client.dart';

class WalletService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> getBalance(String? accountId) async {
    try {
      final response = await _apiClient.get('/wallet');
      
      if (response.data['success'] == true) {
        return {
          'success': true,
          'balance': response.data['data']['balance'] ?? 0.0,
          'wallet': response.data['data']
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get balance'
      };
    } catch (e) {
      return {'success': false, 'message': 'Balance fetch failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> getJournalEntries({
    String? accountId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (accountId != null) {
        queryParams['accountId'] = accountId;
      }

      final response = await _apiClient.get(
        '/wallet/transactions',
        queryParameters: queryParams,
      );
      
      if (response.data['success'] == true) {
        final data = response.data['data'];
        List<Map<String, dynamic>> transactions = [];
        
        if (data is List) {
          transactions = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['transactions'] != null) {
          transactions = List<Map<String, dynamic>>.from(data['transactions']);
        } else if (data is Map && data['entries'] != null) {
          transactions = List<Map<String, dynamic>>.from(data['entries']);
        }
        
        return {
          'success': true,
          'data': transactions,
          'pagination': data is Map ? (data['pagination'] ?? {}) : {},
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get transactions'
      };
    } catch (e) {
      // Return empty data instead of error for better UX
      return {
        'success': true,
        'data': [],
        'pagination': {},
      };
    }
  }

  static Future<Map<String, dynamic>> transfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String description,
    String? referenceId,
  }) async {
    try {
      final response = await _apiClient.post('/wallet/transfer', data: {
        'fromAccountId': fromAccountId,
        'toAccountId': toAccountId,
        'amount': amount,
        'description': description,
        'referenceId': referenceId,
      });
      
      if (response.data['success'] == true) {
        return {
          'success': true,
          'transaction': response.data['data']
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Transfer failed'
      };
    } catch (e) {
      return {'success': false, 'message': 'Transfer failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> holdInEscrow({
    required String userAccountId,
    required String escrowAccountId,
    required double amount,
    required String description,
    String? referenceId,
  }) async {
    try {
      final response = await _apiClient.post('/wallet/escrow/hold', data: {
        'userAccountId': userAccountId,
        'escrowAccountId': escrowAccountId,
        'amount': amount,
        'description': description,
        'referenceId': referenceId,
      });
      
      if (response.data['success'] == true) {
        return {
          'success': true,
          'escrow': response.data['data']
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Escrow hold failed'
      };
    } catch (e) {
      return {'success': false, 'message': 'Escrow hold failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> releaseFromEscrow({
    required String escrowAccountId,
    required String toAccountId,
    required double amount,
    required String description,
    String? referenceId,
  }) async {
    try {
      final response = await _apiClient.post('/wallet/escrow/release', data: {
        'escrowAccountId': escrowAccountId,
        'toAccountId': toAccountId,
        'amount': amount,
        'description': description,
        'referenceId': referenceId,
      });
      
      if (response.data['success'] == true) {
        return {
          'success': true,
          'release': response.data['data']
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Escrow release failed'
      };
    } catch (e) {
      return {'success': false, 'message': 'Escrow release failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> reconcileAccount(String accountId) async {
    try {
      final response = await _apiClient.post('/wallet/reconcile', data: {
        'accountId': accountId,
      });
      
      if (response.data['success'] == true) {
        return {
          'success': true,
          'reconciliation': response.data['data']
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Reconciliation failed'
      };
    } catch (e) {
      return {'success': false, 'message': 'Reconciliation failed: $e'};
    }
  }
}
