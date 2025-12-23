import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'api_client.dart';
import '../models/ledger_models.dart';

class DoubleEntryLedgerService {
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

      if (response.data['success'] == true) {
        return {
          'success': true,
          'transaction': Transaction.fromJson(response.data['data']),
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Transaction failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> getBalance(String accountId) async {
    try {
      final response = await _apiClient.get('/ledger/accounts/$accountId/balance');
      
      if (response.data['success'] == true) {
        return {
          'success': true,
          'balance': Balance.fromJson(response.data['data']),
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Balance fetch failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> getJournalEntries({
    String? accountId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final query = accountId != null ? '?accountId=$accountId&page=$page&limit=$limit' : '?page=$page&limit=$limit';
      final response = await _apiClient.get('/ledger/entries$query');
      
      if (response.data['success'] == true) {
        final entries = (response.data['data']['entries'] as List)
            .map((e) => JournalEntry.fromJson(e))
            .toList();
        return {
          'success': true,
          'entries': entries,
          'total': response.data['data']['total'],
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Entries fetch failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> reconcileAccount(String accountId) async {
    try {
      final response = await _apiClient.post('/ledger/accounts/$accountId/reconcile');
      
      if (response.data['success'] == true) {
        return {
          'success': true,
          'reconciliation': response.data['data'],
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Reconciliation failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyEntryIntegrity(String entryId) async {
    try {
      final response = await _apiClient.get('/ledger/entries/$entryId/verify');
      
      if (response.data['success'] == true) {
        return {
          'success': true,
          'isValid': response.data['data']['isValid'],
          'hash': response.data['data']['hash'],
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Verification failed: $e'};
    }
  }

  static String _generateEntryHash(JournalEntry entry) {
    final data = '${entry.transactionId}${entry.accountId}${entry.type.name}${entry.amount}${entry.description}${entry.createdAt.toIso8601String()}';
    return sha256.convert(utf8.encode(data)).toString();
  }

  static Future<Map<String, dynamic>> payment({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String description,
    String? referenceId,
  }) async {
    return createTransaction(
      description: description,
      referenceId: referenceId,
      referenceType: 'PAYMENT',
      entries: [
        {
          'accountId': fromAccountId,
          'type': 'debit',
          'amount': amount,
          'description': description,
        },
        {
          'accountId': toAccountId,
          'type': 'credit',
          'amount': amount,
          'description': description,
        },
      ],
    );
  }

  static Future<Map<String, dynamic>> escrowHold({
    required String userAccountId,
    required String escrowAccountId,
    required double amount,
    required String description,
    String? referenceId,
  }) async {
    return createTransaction(
      description: description,
      referenceId: referenceId,
      referenceType: 'ESCROW_HOLD',
      entries: [
        {
          'accountId': userAccountId,
          'type': 'debit',
          'amount': amount,
          'description': description,
        },
        {
          'accountId': escrowAccountId,
          'type': 'credit',
          'amount': amount,
          'description': description,
        },
      ],
    );
  }

  static Future<Map<String, dynamic>> escrowRelease({
    required String escrowAccountId,
    required String toAccountId,
    required double amount,
    required String description,
    String? referenceId,
  }) async {
    return createTransaction(
      description: description,
      referenceId: referenceId,
      referenceType: 'ESCROW_RELEASE',
      entries: [
        {
          'accountId': escrowAccountId,
          'type': 'debit',
          'amount': amount,
          'description': description,
        },
        {
          'accountId': toAccountId,
          'type': 'credit',
          'amount': amount,
          'description': description,
        },
      ],
    );
  }
}
