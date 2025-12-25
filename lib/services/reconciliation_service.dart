import 'api_client.dart';
import '../models/ledger_models.dart';

class ReconciliationService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> reconcileAllAccounts() async {
    try {
      final response = await _apiClient.post('/ledger/reconcile/all');
      
      if (response.data['success'] == true) {
        return {
          'success': true,
          'results': response.data['data'],
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Reconciliation failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> generateAuditReport({
    String? accountId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (accountId != null) params['accountId'] = accountId;
      if (fromDate != null) params['fromDate'] = fromDate.toIso8601String();
      if (toDate != null) params['toDate'] = toDate.toIso8601String();

      final response = await _apiClient.post('/ledger/audit/report', data: params);
      
      if (response.data['success'] == true) {
        return {
          'success': true,
          'report': response.data['data'],
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Audit report failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> validateLedgerIntegrity() async {
    try {
      final response = await _apiClient.post('/ledger/validate/integrity');
      
      if (response.data['success'] == true) {
        return {
          'success': true,
          'validation': response.data['data'],
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Integrity validation failed: $e'};
    }
  }

  static double calculateBalanceFromEntries(List<JournalEntry> entries) {
    return entries.fold(0.0, (balance, entry) {
      return entry.type == EntryType.credit 
          ? balance + entry.amount 
          : balance - entry.amount;
    });
  }

  static Map<String, dynamic> detectDiscrepancies(
    List<JournalEntry> entries,
    double reportedBalance,
  ) {
    final calculatedBalance = calculateBalanceFromEntries(entries);
    final discrepancy = (calculatedBalance - reportedBalance).abs();
    
    return {
      'hasDiscrepancy': discrepancy > 0.01,
      'calculatedBalance': calculatedBalance,
      'reportedBalance': reportedBalance,
      'discrepancy': discrepancy,
    };
  }
}
