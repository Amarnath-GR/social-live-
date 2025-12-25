import 'double_entry_ledger_service.dart';
import 'reconciliation_service.dart';
import '../models/compliance_models.dart';
import 'kyb_service.dart';

class LedgerService {
  static Future<Map<String, dynamic>> getBalance(String accountId) async {
    return await DoubleEntryLedgerService.getBalance(accountId);
  }

  static Future<Map<String, dynamic>> getJournalEntries({
    String? accountId,
    int page = 1,
    int limit = 20,
  }) async {
    return await DoubleEntryLedgerService.getJournalEntries(
      accountId: accountId,
      page: page,
      limit: limit,
    );
  }

  static Future<Map<String, dynamic>> recordPayment({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String paymentId,
    required String description,
  }) async {
    // Check compliance before processing payment
    final complianceCheck = await _checkComplianceForTransaction(fromAccountId, amount);
    if (!complianceCheck['allowed']) {
      return {'success': false, 'message': complianceCheck['reason']};
    }

    return await DoubleEntryLedgerService.payment(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      description: description,
      referenceId: paymentId,
    );
  }

  static Future<Map<String, dynamic>> recordPurchase({
    required String userAccountId,
    required String platformAccountId,
    required double amount,
    required String orderId,
    required String description,
  }) async {
    return await DoubleEntryLedgerService.payment(
      fromAccountId: userAccountId,
      toAccountId: platformAccountId,
      amount: amount,
      description: description,
      referenceId: orderId,
    );
  }

  static Future<Map<String, dynamic>> recordRefund({
    required String platformAccountId,
    required String userAccountId,
    required double amount,
    required String refundId,
    required String description,
  }) async {
    return await DoubleEntryLedgerService.payment(
      fromAccountId: platformAccountId,
      toAccountId: userAccountId,
      amount: amount,
      description: description,
      referenceId: refundId,
    );
  }

  static Future<Map<String, dynamic>> reconcileAccount(String accountId) async {
    return await DoubleEntryLedgerService.reconcileAccount(accountId);
  }

  static Future<Map<String, dynamic>> generateAuditReport({
    String? accountId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await ReconciliationService.generateAuditReport(
      accountId: accountId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  static Future<Map<String, dynamic>> _checkComplianceForTransaction(String accountId, double amount) async {
    // Check if user has valid KYB/AML verification for large transactions
    if (amount > 10000) {
      final kybStatus = await KYBService.getUserVerifications();
      if (kybStatus['success'] != true) {
        return {'allowed': false, 'reason': 'KYB verification required for large transactions'};
      }

      final verifications = kybStatus['verifications'] as List<ComplianceVerification>;
      final hasValidKYB = verifications.any((v) => 
        v.type == ComplianceType.kyb && v.status == ComplianceStatus.approved
      );

      if (!hasValidKYB) {
        return {'allowed': false, 'reason': 'Valid KYB verification required'};
      }
    }

    return {'allowed': true};
  }

  static String formatTransactionType(String entryType, String? referenceType) {
    if (referenceType != null) {
      switch (referenceType.toUpperCase()) {
        case 'PAYMENT':
          return entryType == 'CREDIT' ? 'Payment Received' : 'Payment Sent';
        case 'PURCHASE':
          return entryType == 'DEBIT' ? 'Purchase' : 'Purchase Refund';
        case 'REFUND':
          return 'Refund';
        case 'ESCROW_HOLD':
          return 'Escrow Hold';
        case 'ESCROW_RELEASE':
          return 'Escrow Release';
        default:
          return referenceType;
      }
    }
    return entryType == 'DEBIT' ? 'Debit' : 'Credit';
  }
}
