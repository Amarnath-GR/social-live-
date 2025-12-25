import 'api_client.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FeedService {
  static final ApiClient _apiClient = ApiClient();

  // Mock video data
  static final List<Map<String, dynamic>> _mockPosts = [
    {
      'id': '1',
      'title': 'Amazing Gaming Highlights',
      'description': 'Check out these epic gaming moments!',
      'videoUrl': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      'thumbnailUrl': 'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Gaming',
      'creator': {
        'id': '1',
        'username': 'gamer_pro',
        'name': 'Pro Gamer',
        'avatar': 'https://via.placeholder.com/50x50/4ECDC4/FFFFFF?text=PG'
      },
      'stats': {
        'views': 1250,
        'likes': 89,
        'comments': 23,
        'shares': 12
      },
      'createdAt': '2024-01-15T10:30:00Z',
      'duration': 180
    },
    {
      'id': '2',
      'title': 'Live Stream Highlights',
      'description': 'Best moments from yesterday\'s stream',
      'videoUrl': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
      'thumbnailUrl': 'https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Stream',
      'creator': {
        'id': '2',
        'username': 'streamer_jane',
        'name': 'Jane Streamer',
        'avatar': 'https://via.placeholder.com/50x50/96CEB4/FFFFFF?text=JS'
      },
      'stats': {
        'views': 2100,
        'likes': 156,
        'comments': 45,
        'shares': 28
      },
      'createdAt': '2024-01-14T15:45:00Z',
      'duration': 240
    },
    {
      'id': '3',
      'title': 'Tutorial: Advanced Techniques',
      'description': 'Learn pro-level strategies',
      'videoUrl': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      'thumbnailUrl': 'https://via.placeholder.com/300x200/FFEAA7/FFFFFF?text=Tutorial',
      'creator': {
        'id': '3',
        'username': 'tutorial_master',
        'name': 'Tutorial Master',
        'avatar': 'https://via.placeholder.com/50x50/DDA0DD/FFFFFF?text=TM'
      },
      'stats': {
        'views': 890,
        'likes': 67,
        'comments': 15,
        'shares': 8
      },
      'createdAt': '2024-01-13T09:20:00Z',
      'duration': 320
    },
    {
      'id': '4',
      'title': 'Epic Fail Compilation',
      'description': 'Funny moments and fails',
      'videoUrl': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
      'thumbnailUrl': 'https://via.placeholder.com/300x200/FD79A8/FFFFFF?text=Fails',
      'creator': {
        'id': '4',
        'username': 'funny_clips',
        'name': 'Funny Clips',
        'avatar': 'https://via.placeholder.com/50x50/FDCB6E/FFFFFF?text=FC'
      },
      'stats': {
        'views': 3200,
        'likes': 245,
        'comments': 78,
        'shares': 45
      },
      'createdAt': '2024-01-12T18:10:00Z',
      'duration': 150
    },
    {
      'id': '5',
      'title': 'New Game Review',
      'description': 'First impressions of the latest release',
      'videoUrl': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      'thumbnailUrl': 'https://via.placeholder.com/300x200/A29BFE/FFFFFF?text=Review',
      'creator': {
        'id': '5',
        'username': 'game_reviewer',
        'name': 'Game Reviewer',
        'avatar': 'https://via.placeholder.com/50x50/6C5CE7/FFFFFF?text=GR'
      },
      'stats': {
        'views': 1800,
        'likes': 134,
        'comments': 56,
        'shares': 22
      },
      'createdAt': '2024-01-11T14:30:00Z',
      'duration': 480
    }
  ];

  static Future<Map<String, dynamic>> getPersonalizedFeed({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.get('/posts', queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });
      return {'success': true, 'data': {'posts': response.data}};
    } catch (e) {
      // Return empty posts array when backend is not available
      return {
        'success': true,
        'data': {'posts': []}
      };
    }
  }

  static Future<Map<String, dynamic>> getChronologicalFeed({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.get('/posts', queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      // Return mock posts when backend is not available
      final mockPosts = List<Map<String, dynamic>>.from(_mockPosts);
      return {
        'success': true,
        'data': mockPosts.take(limit).toList()
      };
    }
  }

  static Future<Map<String, dynamic>> getTrendingPosts({int limit = 20}) async {
    try {
      final response = await _apiClient.get('/posts', queryParameters: {
        'limit': limit.toString(),
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      final trending = List<Map<String, dynamic>>.from(_mockPosts);
      trending.sort((a, b) => (b['stats']['views'] as int).compareTo(a['stats']['views'] as int));
      return {
        'success': true,
        'data': trending.take(limit).toList()
      };
    }
  }

  static Future<Map<String, dynamic>> recordView(String postId, {int? duration}) async {
    return {'success': true};
  }

  static Future<Map<String, dynamic>> recordLike(String postId) async {
    try {
      final response = await _apiClient.post('/posts/$postId/like');
      if (response.data['success'] == true) {
        await _saveLikedPost(postId);
      }
      return {'success': response.data['success'] ?? false};
    } catch (e) {
      await _saveLikedPost(postId);
      return {'success': true};
    }
  }

  static Future<Map<String, dynamic>> recordUnlike(String postId) async {
    try {
      final response = await _apiClient.delete('/posts/$postId/like');
      if (response.data['success'] == true) {
        await _removeLikedPost(postId);
      }
      return {'success': response.data['success'] ?? false};
    } catch (e) {
      await _removeLikedPost(postId);
      return {'success': true};
    }
  }

  static Future<void> _saveLikedPost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final liked = prefs.getStringList('liked_posts') ?? [];
    if (!liked.contains(postId)) {
      liked.add(postId);
      await prefs.setStringList('liked_posts', liked);
    }
  }

  static Future<void> _removeLikedPost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final liked = prefs.getStringList('liked_posts') ?? [];
    liked.remove(postId);
    await prefs.setStringList('liked_posts', liked);
  }

  static Future<List<String>> getLikedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('liked_posts') ?? [];
  }

  static Future<Map<String, dynamic>> recordComment(String postId, String content) async {
    return {'success': true, 'data': {'id': '1', 'content': content}};
  }

  static Future<Map<String, dynamic>> recordShare(String postId) async {
    return {'success': true};
  }

  static Future<Map<String, dynamic>> recordEngagement(String postId, String engagementType, {int? duration}) async {
    return {'success': true};
  }

  static Future<Map<String, dynamic>> getFeatureFlags() async {
    return {
      'success': true,
      'data': {
        'personalizedFeed': true,
        'engagementRanking': true,
        'videoAutoplay': true
      }
    };
  }

  static Future<Map<String, dynamic>> getPostAnalytics(String postId) async {
    return {
      'success': true,
      'data': {
        'views': 100,
        'likes': 10,
        'comments': 5,
        'shares': 2
      }
    };
  }

  // Legacy methods for backward compatibility
  static Future<Map<String, dynamic>> trackEngagement(int postId, String type) async {
    return recordEngagement(postId.toString(), type);
  }

  static Future<void> trackView(int postId) async {
    await recordView(postId.toString());
  }

  static Future<void> trackLike(int postId) async {
    await recordLike(postId.toString());
  }

  static Future<void> trackComment(int postId) async {
    await recordEngagement(postId.toString(), 'COMMENT');
  }

  static Future<void> trackShare(int postId) async {
    await recordShare(postId.toString());
  }
}
