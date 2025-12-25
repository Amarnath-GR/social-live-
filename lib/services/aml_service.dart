import 'api_client.dart';
import '../models/compliance_models.dart';

class AMLService {
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> screenUser({
    required String userId,
    required String fullName,
    required DateTime dateOfBirth,
    required String nationality,
    String? businessName,
  }) async {
    try {
      final response = await _apiClient.post('/compliance/aml/screen', data: {
        'userId': userId,
        'fullName': fullName,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'nationality': nationality,
        'businessName': businessName,
      });

      if (response.data['success'] == true) {
        return {
          'success': true,
          'result': AMLScreeningResult.fromJson(response.data['data']),
        };
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'AML screening failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> getScreeningHistory(String userId) async {
    try {
      final response = await _apiClient.get('/compliance/aml/history/$userId');

      if (response.data['success'] == true) {
        final results = (response.data['data'] as List)
            .map((r) => AMLScreeningResult.fromJson(r))
            .toList();
        return {'success': true, 'results': results};
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'History fetch failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateRiskAssessment({
    required String userId,
    required AMLRiskLevel riskLevel,
    required String reason,
  }) async {
    try {
      final response = await _apiClient.post('/compliance/aml/risk-update', data: {
        'userId': userId,
        'riskLevel': riskLevel.name,
        'reason': reason,
      });

      if (response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Risk update failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> schedulePeriodicScreening({
    required String userId,
    required Duration interval,
  }) async {
    try {
      final response = await _apiClient.post('/compliance/aml/schedule', data: {
        'userId': userId,
        'intervalDays': interval.inDays,
      });

      if (response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Scheduling failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> reportSuspiciousActivity({
    required String userId,
    required String activityType,
    required String description,
    required Map<String, dynamic> evidence,
  }) async {
    try {
      final response = await _apiClient.post('/compliance/aml/suspicious-activity', data: {
        'userId': userId,
        'activityType': activityType,
        'description': description,
        'evidence': evidence,
      });

      if (response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'SAR submission failed: $e'};
    }
  }
}
