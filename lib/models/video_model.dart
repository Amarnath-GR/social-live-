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
  final String type; // 'VIDEO' or 'IMAGE'

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
    this.type = 'VIDEO',
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final postType = json['type']?.toString().toUpperCase() ?? 'VIDEO';
    return VideoModel(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      videoUrl: json['videoUrl'] ?? json['imageUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? json['imageUrl'],
      duration: json['duration'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : UserModel.guest(),
      hashtags: json['hashtags'] != null ? List<String>.from(json['hashtags']) : [],
      stats: json['stats'] != null ? VideoStats.fromJson(json['stats']) : VideoStats(likes: 0, comments: 0, shares: 0, views: 0),
      isLiked: json['isLiked'] ?? false,
      autoPlay: json['autoPlay'] ?? true,
      type: postType,
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
      'type': type,
    };
  }

  bool get isVideo => type == 'VIDEO' && videoUrl.isNotEmpty;
  bool get isImage => type == 'IMAGE' || (type == 'VIDEO' && videoUrl.isEmpty);

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