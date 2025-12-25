class PostModel {
  final String id;
  final String content;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? imageUrl;
  final int? duration;
  final DateTime createdAt;
  final String userId;
  final List<String> hashtags;
  final PostStats stats;
  bool isLiked;
  final String type; // 'video', 'image', 'text'

  PostModel({
    required this.id,
    required this.content,
    this.videoUrl,
    this.thumbnailUrl,
    this.imageUrl,
    this.duration,
    required this.createdAt,
    required this.userId,
    required this.hashtags,
    required this.stats,
    required this.isLiked,
    required this.type,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      content: json['content'] ?? json['description'] ?? '',
      videoUrl: json['videoUrl'] ?? json['videoPath'],
      thumbnailUrl: json['thumbnailUrl'] ?? json['thumbnailPath'],
      imageUrl: json['imageUrl'] ?? json['videoPath'],
      duration: json['duration'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      userId: json['userId'] ?? json['user']?['id'] ?? '',
      hashtags: List<String>.from(json['hashtags'] ?? []),
      stats: PostStats.fromJson(json['stats'] ?? json),
      isLiked: json['isLiked'] ?? false,
      type: json['type'] ?? 'video',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'imageUrl': imageUrl,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'hashtags': hashtags,
      'stats': stats.toJson(),
      'isLiked': isLiked,
      'type': type,
    };
  }

  int get views => stats.views;
  int get likes => stats.likes;
}

class PostStats {
  int likes;
  int comments;
  int shares;
  int views;

  PostStats({
    required this.likes,
    required this.comments,
    required this.shares,
    required this.views,
  });

  factory PostStats.fromJson(Map<String, dynamic> json) {
    return PostStats(
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