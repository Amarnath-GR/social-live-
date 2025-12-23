import 'dart:io';
import 'api_client.dart';
import '../models/compliance_models.dart';

class KYBService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> startKYBVerification({
    required String businessName,
    required String businessType,
    required String registrationNumber,
    required String country,
    required Map<String, dynamic> businessAddress,
  }) async {
    try {
      final response = await _apiClient.post('/compliance/kyb/start', data: {
        'businessName': businessName,
        'businessType': businessType,
        'registrationNumber': registrationNumber,
        'country': country,
        'businessAddress': businessAddress,
      });

      if (response.data['success'] == true) {
        return {
          'success': true,
          'verification': ComplianceVerification.fromJson(response.data['data']),
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'KYB start failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> uploadDocument({
    required String verificationId,
    required DocumentType type,
    required File file,
  }) async {
    try {
      final response = await _apiClient.uploadFile(
        '/compliance/kyb/$verificationId/documents',
        file.path,
        data: {'type': type.name},
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'document': ComplianceDocument.fromJson(response.data['data']),
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Document upload failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> submitForReview(String verificationId) async {
    try {
      final response = await _apiClient.post('/compliance/kyb/$verificationId/submit');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'verification': ComplianceVerification.fromJson(response.data['data']),
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'KYB submission failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> getVerificationStatus(String verificationId) async {
    try {
      final response = await _apiClient.get('/compliance/kyb/$verificationId');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'verification': ComplianceVerification.fromJson(response.data['data']),
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Status check failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUserVerifications() async {
    try {
      final response = await _apiClient.get('/compliance/kyb/user');

      if (response.data['success'] == true) {
        final verifications = (response.data['data'] as List)
            .map((v) => ComplianceVerification.fromJson(v))
            .toList();
        return {'success': true, 'verifications': verifications};
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Fetch verifications failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> retryVerification(String verificationId) async {
    try {
      final response = await _apiClient.post('/compliance/kyb/$verificationId/retry');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'verification': ComplianceVerification.fromJson(response.data['data']),
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Retry failed: $e'};
    }
  }
}
