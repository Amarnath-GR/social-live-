enum ComplianceType { kyb, aml }
enum ComplianceStatus { pending, inProgress, approved, rejected, escalated, expired }
enum DocumentType { businessLicense, articlesOfIncorporation, taxId, bankStatement, ownershipStructure, proofOfAddress }
enum AMLRiskLevel { low, medium, high, prohibited }

class ComplianceVerification {
  final String id;
  final String userId;
  final ComplianceType type;
  final ComplianceStatus status;
  final String? externalId;
  final Map<String, dynamic>? externalData;
  final DateTime? submittedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final List<ComplianceDocument> documents;
  final List<ComplianceReview> reviews;

  ComplianceVerification({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    this.externalId,
    this.externalData,
    this.submittedAt,
    this.completedAt,
    required this.createdAt,
    this.documents = const [],
    this.reviews = const [],
  });

  factory ComplianceVerification.fromJson(Map<String, dynamic> json) => ComplianceVerification(
    id: json['id'],
    userId: json['userId'],
    type: ComplianceType.values.byName(json['type']),
    status: ComplianceStatus.values.byName(json['status']),
    externalId: json['externalId'],
    externalData: json['externalData'],
    submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt']) : null,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    createdAt: DateTime.parse(json['createdAt']),
    documents: (json['documents'] as List?)?.map((d) => ComplianceDocument.fromJson(d)).toList() ?? [],
    reviews: (json['reviews'] as List?)?.map((r) => ComplianceReview.fromJson(r)).toList() ?? [],
  );
}

class ComplianceDocument {
  final String id;
  final String verificationId;
  final DocumentType type;
  final String filename;
  final int fileSize;
  final String? externalId;
  final ComplianceStatus status;
  final DateTime createdAt;

  ComplianceDocument({
    required this.id,
    required this.verificationId,
    required this.type,
    required this.filename,
    required this.fileSize,
    this.externalId,
    required this.status,
    required this.createdAt,
  });

  factory ComplianceDocument.fromJson(Map<String, dynamic> json) => ComplianceDocument(
    id: json['id'],
    verificationId: json['verificationId'],
    type: DocumentType.values.byName(json['type']),
    filename: json['filename'],
    fileSize: json['fileSize'],
    externalId: json['externalId'],
    status: ComplianceStatus.values.byName(json['status']),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class ComplianceReview {
  final String id;
  final String verificationId;
  final String reviewerId;
  final ComplianceStatus status;
  final String? notes;
  final DateTime createdAt;

  ComplianceReview({
    required this.id,
    required this.verificationId,
    required this.reviewerId,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory ComplianceReview.fromJson(Map<String, dynamic> json) => ComplianceReview(
    id: json['id'],
    verificationId: json['verificationId'],
    reviewerId: json['reviewerId'],
    status: ComplianceStatus.values.byName(json['status']),
    notes: json['notes'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class AMLScreeningResult {
  final String id;
  final String userId;
  final AMLRiskLevel riskLevel;
  final List<String> matches;
  final Map<String, dynamic> screeningData;
  final DateTime screenedAt;

  AMLScreeningResult({
    required this.id,
    required this.userId,
    required this.riskLevel,
    required this.matches,
    required this.screeningData,
    required this.screenedAt,
  });

  factory AMLScreeningResult.fromJson(Map<String, dynamic> json) => AMLScreeningResult(
    id: json['id'],
    userId: json['userId'],
    riskLevel: AMLRiskLevel.values.byName(json['riskLevel']),
    matches: List<String>.from(json['matches']),
    screeningData: json['screeningData'],
    screenedAt: DateTime.parse(json['screenedAt']),
  );
}
