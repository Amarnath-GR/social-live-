import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserContent {
  final String id;
  final String type; // 'photo', 'video', 'live'
  final String path;
  final String? thumbnailPath;
  final DateTime createdAt;
  final int? duration; // for videos
  final int views;
  final int likes;

  UserContent({
    required this.id,
    required this.type,
    required this.path,
    this.thumbnailPath,
    required this.createdAt,
    this.duration,
    this.views = 0,
    this.likes = 0,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'path': path,
      'thumbnailPath': thumbnailPath,
      'createdAt': createdAt.toIso8601String(),
      'duration': duration,
      'views': views,
      'likes': likes,
    };
  }

  // Create from JSON
  factory UserContent.fromJson(Map<String, dynamic> json) {
    return UserContent(
      id: json['id'],
      type: json['type'],
      path: json['path'],
      thumbnailPath: json['thumbnailPath'],
      createdAt: DateTime.parse(json['createdAt']),
      duration: json['duration'],
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
    );
  }
}

class UserContentService extends ChangeNotifier {
  static final UserContentService _instance = UserContentService._internal();
  factory UserContentService() => _instance;
  UserContentService._internal() {
    _loadContent();
  }

  final List<UserContent> _userContent = [];
  static const String _storageKey = 'user_content';

  List<UserContent> get allContent => List.unmodifiable(_userContent);
  List<UserContent> get photos => _userContent.where((c) => c.type == 'photo').toList();
  List<UserContent> get videos => _userContent.where((c) => c.type == 'video').toList();
  List<UserContent> get liveStreams => _userContent.where((c) => c.type == 'live').toList();

  // Load content from SharedPreferences
  Future<void> _loadContent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? contentJson = prefs.getString(_storageKey);
      
      if (contentJson != null) {
        final List<dynamic> contentList = json.decode(contentJson);
        _userContent.clear();
        _userContent.addAll(
          contentList.map((item) => UserContent.fromJson(item)).toList(),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error loading content: $e');
    }
  }

  // Save content to SharedPreferences
  Future<void> _saveContent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String contentJson = json.encode(
        _userContent.map((content) => content.toJson()).toList(),
      );
      await prefs.setString(_storageKey, contentJson);
    } catch (e) {
      print('Error saving content: $e');
    }
  }

  void addPhoto(String path) {
    final content = UserContent(
      id: 'photo_${DateTime.now().millisecondsSinceEpoch}',
      type: 'photo',
      path: path,
      thumbnailPath: path,
      createdAt: DateTime.now(),
    );
    _userContent.insert(0, content);
    _saveContent();
    notifyListeners();
  }

  void addVideo(String path, int duration, {String? thumbnailPath}) {
    final content = UserContent(
      id: 'video_${DateTime.now().millisecondsSinceEpoch}',
      type: 'video',
      path: path,
      thumbnailPath: thumbnailPath ?? path,
      createdAt: DateTime.now(),
      duration: duration,
    );
    _userContent.insert(0, content);
    _saveContent();
    notifyListeners();
  }

  void addLiveStream(String streamId, {String? thumbnailPath}) {
    final content = UserContent(
      id: streamId,
      type: 'live',
      path: 'live_$streamId',
      thumbnailPath: thumbnailPath,
      createdAt: DateTime.now(),
    );
    _userContent.insert(0, content);
    _saveContent();
    notifyListeners();
  }

  void deleteContent(String id) {
    _userContent.removeWhere((c) => c.id == id);
    _saveContent();
    notifyListeners();
  }

  int get totalContent => _userContent.length;
}
