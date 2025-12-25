import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'following_notifier.dart';

class FollowingService {
  static final FollowingService _instance = FollowingService._internal();
  factory FollowingService() => _instance;
  FollowingService._internal();

  static const String _followingKey = 'following_users';
  static const String _followingCountKey = 'following_count';

  List<Map<String, String>> _followingUsers = [];
  int _followingCount = 234;

  Future<void> loadFollowing() async {
    final prefs = await SharedPreferences.getInstance();
    final followingJson = prefs.getString(_followingKey);
    _followingCount = prefs.getInt(_followingCountKey) ?? 234;
    
    if (followingJson != null) {
      final List<dynamic> decoded = json.decode(followingJson);
      _followingUsers = decoded.map((e) => Map<String, String>.from(e)).toList();
    }
  }

  Future<void> _saveFollowing() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_followingKey, json.encode(_followingUsers));
    await prefs.setInt(_followingCountKey, _followingCount);
    FollowingNotifier().notifyFollowingChanged();
  }

  Future<void> followUser(String username, String displayName) async {
    if (!isFollowing(username)) {
      _followingUsers.insert(0, {
        'username': username,
        'displayName': displayName,
        'followedAt': DateTime.now().toIso8601String(),
      });
      _followingCount++;
      await _saveFollowing();
    }
  }

  Future<void> unfollowUser(String username) async {
    _followingUsers.removeWhere((user) => user['username'] == username);
    _followingCount--;
    await _saveFollowing();
  }

  bool isFollowing(String username) {
    return _followingUsers.any((user) => user['username'] == username);
  }

  int get followingCount => _followingCount;
  List<Map<String, String>> get followingUsers {
    // Sort by newest first (most recently followed)
    _followingUsers.sort((a, b) {
      final aTime = DateTime.tryParse(a['followedAt'] ?? '') ?? DateTime(2020);
      final bTime = DateTime.tryParse(b['followedAt'] ?? '') ?? DateTime(2020);
      return bTime.compareTo(aTime);
    });
    return _followingUsers;
  }
}