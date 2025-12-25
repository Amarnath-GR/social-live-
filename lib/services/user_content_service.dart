import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'thumbnail_service.dart';
import 'api_client.dart';

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

  static final ApiClient _apiClient = ApiClient();
  final List<UserContent> _userContent = [];
  static const String _storageKey = 'user_content';

  List<UserContent> get allContent => List.unmodifiable(_userContent);
  List<UserContent> get photos => _userContent.where((c) => c.type == 'photo').toList();
  List<UserContent> get videos => _userContent.where((c) => c.type == 'video').toList();
  List<UserContent> get liveStreams => _userContent.where((c) => c.type == 'live').toList();
  int get totalContent => _userContent.length;

  // Load content from SharedPreferences
  Future<void> _loadContent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? contentJson = prefs.getString(_storageKey);
      
      if (contentJson != null) {
        final List<dynamic> contentList = json.decode(contentJson);
        _userContent.clear();
        // Filter out any sample content during load
        _userContent.addAll(
          contentList
              .map((item) => UserContent.fromJson(item))
              .where((content) => !content.id.startsWith('sample_'))
              .toList(),
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

  void addVideo(String path, int duration, {String? thumbnailPath}) async {
    final thumbnail = await ThumbnailService().generateVideoThumbnail(path);
    final content = UserContent(
      id: 'video_${DateTime.now().millisecondsSinceEpoch}',
      type: 'video',
      path: path,
      thumbnailPath: thumbnail,
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

  // Create sample content with real thumbnails
  Future<void> _createSampleContent() async {
    // Disabled - no sample content
  }

  Future<String> _generateSampleThumbnail(String type, Color color, String text, String path) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(300, 300);

      // Draw gradient background
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.4),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

      // Draw icon
      final iconPainter = TextPainter(
        text: TextSpan(
          text: type == 'video' ? '▶' : '📷',
          style: TextStyle(
            color: Colors.white,
            fontSize: 60,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      iconPainter.layout();
      iconPainter.paint(
        canvas,
        Offset(
          (size.width - iconPainter.width) / 2,
          (size.height - iconPainter.height) / 2 - 30,
        ),
      );

      // Draw text
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2 + 40,
        ),
      );

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      
      final file = File(path);
      await file.writeAsBytes(byteData!.buffer.asUint8List());
      
      return path;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return path;
    }
  }

  // Get user content in simple format for profile grids
  List<Map<String, dynamic>> getUserContent() {
    // Filter out sample content
    return _userContent
        .where((content) => !content.id.startsWith('sample_'))
        .map((content) => {
      'id': content.id,
      'type': content.type,
      'path': content.path,
      'duration': content.duration,
      'createdAt': content.createdAt,
      'views': content.views,
      'likes': content.likes,
    }).toList();
  }

  // Clear all sample content
  Future<void> clearSampleContent() async {
    _userContent.removeWhere((c) => c.id.startsWith('sample_'));
    await _saveContent();
    notifyListeners();
  }
}