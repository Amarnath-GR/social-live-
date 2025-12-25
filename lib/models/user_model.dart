class UserModel {
  final String id;
  final String email;
  final String username;
  final String name;
  final String? avatar;
  final String? bio;
  final String role;
  final bool verified;
  final bool isBlocked;
  final bool isActive;
  final int followersCount;
  final int followingCount;
  final int likesCount;
  final int videosCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    this.avatar,
    this.bio,
    required this.role,
    required this.verified,
    required this.isBlocked,
    this.isActive = true,
    this.followersCount = 0,
    this.followingCount = 0,
    this.likesCount = 0,
    this.videosCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      name: json['name'],
      avatar: json['avatar'],
      bio: json['bio'],
      role: json['role'] ?? 'USER',
      verified: json['verified'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      isActive: json['isActive'] ?? true,
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      likesCount: json['likesCount'] ?? 0,
      videosCount: json['videosCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  factory UserModel.guest() {
    final now = DateTime.now();
    return UserModel(
      id: 'guest',
      email: 'guest@example.com',
      username: 'guest',
      name: 'Guest User',
      role: 'USER',
      verified: false,
      isBlocked: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  String get displayName => name;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'avatar': avatar,
      'bio': bio,
      'role': role,
      'verified': verified,
      'isBlocked': isBlocked,
      'isActive': isActive,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'likesCount': likesCount,
      'videosCount': videosCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? name,
    String? avatar,
    String? bio,
    String? role,
    bool? verified,
    bool? isBlocked,
    bool? isActive,
    int? followersCount,
    int? followingCount,
    int? likesCount,
    int? videosCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      verified: verified ?? this.verified,
      isBlocked: isBlocked ?? this.isBlocked,
      isActive: isActive ?? this.isActive,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      likesCount: likesCount ?? this.likesCount,
      videosCount: videosCount ?? this.videosCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}