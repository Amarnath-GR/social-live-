import 'package:flutter/foundation.dart';

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
  LikedVideosService._internal();

  final List<LikedVideo> _likedVideos = [];

  List<LikedVideo> get likedVideos => List.unmodifiable(_likedVideos);

  void likeVideo(String id, String videoUrl, String title, String creator, int likes) {
    // Check if already liked
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
    notifyListeners();
  }

  void unlikeVideo(String id) {
    _likedVideos.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  bool isLiked(String id) {
    return _likedVideos.any((v) => v.id == id);
  }
}
