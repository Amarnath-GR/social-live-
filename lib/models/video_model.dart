import 'user_model.dart';

class VideoModel {
  final String id;
  final String content;
  final String videoUrl;
  final String? thumbnailUrl;
  final int? duration;
  final DateTime createdAt;
  final UserModel user;
  final List<String> hashtags;
  final VideoStats stats;
  bool isLiked;
  final bool autoPlay;

  VideoModel({
    required this.id,
    required this.content,
    required this.videoUrl,
    this.thumbnailUrl,
    this.duration,
    required this.createdAt,
    required this.user,
    required this.hashtags,
    required this.stats,
    required this.isLiked,
    this.autoPlay = true,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      content: json['content'] ?? '',
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      duration: json['duration'],
      createdAt: DateTime.parse(json['createdAt']),
      user: UserModel.fromJson(json['user']),
      hashtags: List<String>.from(json['hashtags'] ?? []),
      stats: VideoStats.fromJson(json['stats']),
      isLiked: json['isLiked'] ?? false,
      autoPlay: json['autoPlay'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      'user': user.toJson(),
      'hashtags': hashtags,
      'stats': stats.toJson(),
      'isLiked': isLiked,
      'autoPlay': autoPlay,
    };
  }

  // Add getter for views to fix the compilation error
  int get views => stats.views;
}

class VideoStats {
  int likes;
  int comments;
  int shares;
  int views;

  VideoStats({
    required this.likes,
    required this.comments,
    required this.shares,
    required this.views,
  });

  factory VideoStats.fromJson(Map<String, dynamic> json) {
    return VideoStats(
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      views: json['views'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'views': views,
    };
  }
}