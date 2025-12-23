import 'api_client.dart';

class GiftService {
  static final ApiClient _apiClient = ApiClient();

  static const List<Map<String, dynamic>> availableGifts = [
    {
      'id': 'heart',
      'name': 'Heart',
      'emoji': '❤️',
      'cost': 10,
      'color': 0xFFE91E63,
    },
    {
      'id': 'star',
      'name': 'Star',
      'emoji': '⭐',
      'cost': 25,
      'color': 0xFFFFD700,
    },
    {
      'id': 'diamond',
      'name': 'Diamond',
      'emoji': '💎',
      'cost': 50,
      'color': 0xFF00BCD4,
    },
    {
      'id': 'crown',
      'name': 'Crown',
      'emoji': '👑',
      'cost': 100,
      'color': 0xFFFF9800,
    },
    {
      'id': 'rocket',
      'name': 'Rocket',
      'emoji': '🚀',
      'cost': 200,
      'color': 0xFF9C27B0,
    },
  ];

  static Future<Map<String, dynamic>> sendGift({
    required String streamId,
    required String giftId,
    required int quantity,
  }) async {
    try {
      final response = await _apiClient.post('/streaming/$streamId/gift', data: {
        'giftId': giftId,
        'quantity': quantity,
      });

      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? '',
        'newBalance': response.data['data']?['newBalance'],
        'totalCost': response.data['data']?['totalCost'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to send gift: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> getStreamLeaderboard(String streamId) async {
    try {
      final response = await _apiClient.get('/streaming/$streamId/leaderboard');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'leaderboard': response.data['data']['leaderboard'] ?? [],
          'totalGifts': response.data['data']['totalGifts'] ?? 0,
        };
      }
      
      return {'success': false, 'message': response.data['message'] ?? 'Failed to get leaderboard'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Map<String, dynamic>? getGiftById(String giftId) {
    try {
      return availableGifts.firstWhere((gift) => gift['id'] == giftId);
    } catch (e) {
      return null;
    }
  }
}
