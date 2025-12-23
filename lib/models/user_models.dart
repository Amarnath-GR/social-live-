class User {
  final String id;
  final String email;
  final String username;
  final String name;
  final String? avatar;
  final String? bio;
  final String role;
  final bool isBlocked;
  final bool kycVerified;
  final bool kybVerified;
  final bool amlVerified;
  final DateTime? kycVerifiedAt;
  final DateTime? kybVerifiedAt;
  final DateTime? amlVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserStats? stats;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    this.avatar,
    this.bio,
    required this.role,
    required this.isBlocked,
    required this.kycVerified,
    required this.kybVerified,
    required this.amlVerified,
    this.kycVerifiedAt,
    this.kybVerifiedAt,
    this.amlVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.stats,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
      bio: json['bio'],
      role: json['role'] ?? 'USER',
      isBlocked: json['isBlocked'] ?? false,
      kycVerified: json['kycVerified'] ?? false,
      kybVerified: json['kybVerified'] ?? false,
      amlVerified: json['amlVerified'] ?? false,
      kycVerifiedAt: json['kycVerifiedAt'] != null 
          ? DateTime.parse(json['kycVerifiedAt']) 
          : null,
      kybVerifiedAt: json['kybVerifiedAt'] != null 
          ? DateTime.parse(json['kybVerifiedAt']) 
          : null,
      amlVerifiedAt: json['amlVerifiedAt'] != null 
          ? DateTime.parse(json['amlVerifiedAt']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      stats: json['_count'] != null ? UserStats.fromJson(json['_count']) : null,
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      isFollowing: json['isFollowing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'avatar': avatar,
      'bio': bio,
      'role': role,
      'isBlocked': isBlocked,
      'kycVerified': kycVerified,
      'kybVerified': kybVerified,
      'amlVerified': amlVerified,
      'kycVerifiedAt': kycVerifiedAt?.toIso8601String(),
      'kybVerifiedAt': kybVerifiedAt?.toIso8601String(),
      'amlVerifiedAt': amlVerifiedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'followersCount': followersCount,
      'followingCount': followingCount,
      'isFollowing': isFollowing,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? name,
    String? avatar,
    String? bio,
    String? role,
    bool? isBlocked,
    bool? kycVerified,
    bool? kybVerified,
    bool? amlVerified,
    DateTime? kycVerifiedAt,
    DateTime? kybVerifiedAt,
    DateTime? amlVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserStats? stats,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      isBlocked: isBlocked ?? this.isBlocked,
      kycVerified: kycVerified ?? this.kycVerified,
      kybVerified: kybVerified ?? this.kybVerified,
      amlVerified: amlVerified ?? this.amlVerified,
      kycVerifiedAt: kycVerifiedAt ?? this.kycVerifiedAt,
      kybVerifiedAt: kybVerifiedAt ?? this.kybVerifiedAt,
      amlVerifiedAt: amlVerifiedAt ?? this.amlVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stats: stats ?? this.stats,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

class UserStats {
  final int posts;
  final int likes;
  final int comments;
  final int followers;
  final int following;

  const UserStats({
    required this.posts,
    required this.likes,
    required this.comments,
    this.followers = 0,
    this.following = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      posts: json['posts'] ?? 0,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
    );
  }
}

class UpdateProfileRequest {
  final String? name;
  final String? username;
  final String? avatar;
  final String? bio;

  const UpdateProfileRequest({
    this.name,
    this.username,
    this.avatar,
    this.bio,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (username != null) data['username'] = username;
    if (avatar != null) data['avatar'] = avatar;
    if (bio != null) data['bio'] = bio;
    return data;
  }
}
