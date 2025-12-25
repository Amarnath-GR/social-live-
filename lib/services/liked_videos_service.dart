import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class LikedVideo {
  final String id;
  final String videoUrl;
  final String title;
  final String creator;
  final int likes;
  final DateTime likedAt;

  LikedVideo({
    required this.id,
    required this.videoUrl,
    required this.title,
    required this.creator,
    required this.likes,
    required this.likedAt,
  });
}

class LikedVideosService extends ChangeNotifier {
  static final LikedVideosService _instance = LikedVideosService._internal();
  factory LikedVideosService() => _instance;
  LikedVideosService._internal() {
    _loadLikedVideos();
  }

  static final ApiClient _apiClient = ApiClient();
  final List<LikedVideo> _likedVideos = [];

  List<LikedVideo> get likedVideos => List.unmodifiable(_likedVideos);

  Future<void> _loadLikedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('liked_videos');
    debugPrint('📂 Loading liked videos from storage...');
    if (data != null) {
      final List<dynamic> list = jsonDecode(data);
      _likedVideos.clear();
      _likedVideos.addAll(list.map((e) => LikedVideo(
        id: e['id'],
        videoUrl: e['videoUrl'],
        title: e['title'],
        creator: e['creator'],
        likes: e['likes'],
        likedAt: DateTime.parse(e['likedAt']),
      )));
      debugPrint('✅ Loaded ${_likedVideos.length} liked videos');
      notifyListeners();
    } else {
      debugPrint('ℹ️ No liked videos found in storage');
    }
  }

  Future<void> _saveLikedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_likedVideos.map((v) => {
      'id': v.id,
      'videoUrl': v.videoUrl,
      'title': v.title,
      'creator': v.creator,
      'likes': v.likes,
      'likedAt': v.likedAt.toIso8601String(),
    }).toList());
    await prefs.setString('liked_videos', data);
  }

  void likeVideo(String id, String videoUrl, String title, String creator, int likes) {
    if (_likedVideos.any((v) => v.id == id)) return;

    final likedVideo = LikedVideo(
      id: id,
      videoUrl: videoUrl,
      title: title,
      creator: creator,
      likes: likes,
      likedAt: DateTime.now(),
    );

    _likedVideos.insert(0, likedVideo);
    _saveLikedVideos();
    _syncToServer(id, true);
    notifyListeners();
    debugPrint('✅ Liked video saved: $id - Total liked: ${_likedVideos.length}');
  }

  void unlikeVideo(String id) {
    _likedVideos.removeWhere((v) => v.id == id);
    _saveLikedVideos();
    _syncToServer(id, false);
    notifyListeners();
  }

  Future<void> _syncToServer(String postId, bool isLike) async {
    try {
      if (isLike) {
        await _apiClient.post('/posts/$postId/like');
      } else {
        await _apiClient.delete('/posts/$postId/like');
      }
    } catch (e) {
      // Silently fail, data is saved locally
    }
  }

  bool isLiked(String id) {
    return _likedVideos.any((v) => v.id == id);
  }
}
