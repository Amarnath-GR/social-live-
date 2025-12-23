import '../models/compliance_models.dart';

class ComplianceStateMachine {
  static const Map<ComplianceStatus, List<ComplianceStatus>> _allowedTransitions = {
    ComplianceStatus.pending: [ComplianceStatus.inProgress, ComplianceStatus.rejected],
    ComplianceStatus.inProgress: [ComplianceStatus.approved, ComplianceStatus.rejected, ComplianceStatus.escalated],
    ComplianceStatus.escalated: [ComplianceStatus.approved, ComplianceStatus.rejected],
    ComplianceStatus.approved: [ComplianceStatus.expired],
    ComplianceStatus.rejected: [ComplianceStatus.pending],
    ComplianceStatus.expired: [ComplianceStatus.pending],
  };

  static bool canTransition(ComplianceStatus from, ComplianceStatus to) {
    return _allowedTransitions[from]?.contains(to) ?? false;
  }

  static List<ComplianceStatus> getValidTransitions(ComplianceStatus current) {
    return _allowedTransitions[current] ?? [];
  }

  static bool isTerminalState(ComplianceStatus status) {
    return status == ComplianceStatus.approved || status == ComplianceStatus.rejected;
  }

  static bool requiresDocuments(ComplianceStatus status) {
    return status == ComplianceStatus.pending || status == ComplianceStatus.inProgress;
  }

  static bool requiresReview(ComplianceStatus status) {
    return status == ComplianceStatus.inProgress || status == ComplianceStatus.escalated;
  }

  static Duration? getExpirationPeriod(ComplianceType type) {
    switch (type) {
      case ComplianceType.kyb:
        return const Duration(days: 365); // 1 year
      case ComplianceType.aml:
        return const Duration(days: 90); // 3 months
    }
  }

  static ComplianceStatus getNextAutoStatus(ComplianceVerification verification) {
    if (verification.status == ComplianceStatus.pending && verification.documents.isNotEmpty) {
      return ComplianceStatus.inProgress;
    }
    
    if (verification.status == ComplianceStatus.approved) {
      final expiration = getExpirationPeriod(verification.type);
      if (expiration != null && verification.completedAt != null) {
        final expiryDate = verification.completedAt!.add(expiration);
        if (DateTime.now().isAfter(expiryDate)) {
          return ComplianceStatus.expired;
        }
      }
    }
    
    return verification.status;
  }

  static bool shouldEscalate(ComplianceVerification verification) {
    // Escalate if in progress for more than 5 days
    if (verification.status == ComplianceStatus.inProgress && verification.submittedAt != null) {
      return DateTime.now().difference(verification.submittedAt!).inDays > 5;
    }
    
    // Escalate if high-risk AML matches
    if (verification.type == ComplianceType.aml && verification.externalData != null) {
      final riskLevel = verification.externalData!['riskLevel'];
      return riskLevel == 'high' || riskLevel == 'prohibited';
    }
    
    return false;
  }

  static Map<String, dynamic> getRequiredDocuments(ComplianceType type) {
    switch (type) {
      case ComplianceType.kyb:
        return {
          'required': [
            DocumentType.businessLicense.name,
            DocumentType.articlesOfIncorporation.name,
            DocumentType.taxId.name,
          ],
          'optional': [
            DocumentType.bankStatement.name,
            DocumentType.ownershipStructure.name,
            DocumentType.proofOfAddress.name,
          ],
        };
      case ComplianceType.aml:
        return {
          'required': [],
          'optional': [DocumentType.proofOfAddress.name],
        };
    }
  }
}
