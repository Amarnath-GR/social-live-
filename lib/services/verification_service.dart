import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

enum VerificationType {
  KYC,
  KYB,
  AML,
}

enum VerificationStatus {
  PENDING,
  IN_REVIEW,
  APPROVED,
  REJECTED,
  REQUIRES_ACTION,
}

enum DocumentType {
  PASSPORT,
  DRIVERS_LICENSE,
  ID_CARD,
  UTILITY_BILL,
  BANK_STATEMENT,
  BUSINESS_REGISTRATION,
  TAX_CERTIFICATE,
  ARTICLES_OF_INCORPORATION,
  BENEFICIAL_OWNERSHIP,
}

class VerificationService {
  static final String _baseUrl = ApiConfig.baseUrl;

  static Future<Map<String, dynamic>> initiateVerification({
    required VerificationType type,
    Map<String, dynamic>? businessInfo,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/verification/initiate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': type.name,
          'businessInfo': businessInfo,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'verificationId': data['data']['verificationId'],
          'sumsubApplicantId': data['data']['sumsubApplicantId'],
          'accessToken': data['data']['accessToken'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to initiate verification',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error initiating verification: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> uploadDocument({
    required String verificationId,
    required DocumentType documentType,
    required File file,
  }) async {
    try {
      final token = await AuthService.getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/verification/$verificationId/documents'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['documentType'] = documentType.name;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'document': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to upload document',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error uploading document: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> submitForReview(String verificationId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/verification/$verificationId/submit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to submit for review',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error submitting for review: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getVerificationStatus({
    VerificationType? type,
  }) async {
    try {
      final token = await AuthService.getToken();
      final uri = Uri.parse('$_baseUrl/verification/status').replace(
        queryParameters: type != null ? {'type': type.name} : null,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'verifications': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get verification status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting verification status: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getDocumentTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/verification/document-types'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'documentTypes': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get document types',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting document types: $e',
      };
    }
  }

  static String getVerificationStatusText(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.PENDING:
        return 'Pending';
      case VerificationStatus.IN_REVIEW:
        return 'In Review';
      case VerificationStatus.APPROVED:
        return 'Approved';
      case VerificationStatus.REJECTED:
        return 'Rejected';
      case VerificationStatus.REQUIRES_ACTION:
        return 'Requires Action';
    }
  }

  static Color getVerificationStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.PENDING:
        return Colors.orange;
      case VerificationStatus.IN_REVIEW:
        return Colors.blue;
      case VerificationStatus.APPROVED:
        return Colors.green;
      case VerificationStatus.REJECTED:
        return Colors.red;
      case VerificationStatus.REQUIRES_ACTION:
        return Colors.amber;
    }
  }

  static String getDocumentTypeText(DocumentType type) {
    switch (type) {
      case DocumentType.PASSPORT:
        return 'Passport';
      case DocumentType.DRIVERS_LICENSE:
        return 'Driver\'s License';
      case DocumentType.ID_CARD:
        return 'ID Card';
      case DocumentType.UTILITY_BILL:
        return 'Utility Bill';
      case DocumentType.BANK_STATEMENT:
        return 'Bank Statement';
      case DocumentType.BUSINESS_REGISTRATION:
        return 'Business Registration';
      case DocumentType.TAX_CERTIFICATE:
        return 'Tax Certificate';
      case DocumentType.ARTICLES_OF_INCORPORATION:
        return 'Articles of Incorporation';
      case DocumentType.BENEFICIAL_OWNERSHIP:
        return 'Beneficial Ownership';
    }
  }

  static VerificationStatus parseVerificationStatus(String status) {
    return VerificationStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => VerificationStatus.PENDING,
    );
  }

  static DocumentType parseDocumentType(String type) {
    return DocumentType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => DocumentType.ID_CARD,
    );
  }
}
