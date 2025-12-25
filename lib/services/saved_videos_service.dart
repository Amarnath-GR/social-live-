import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavedVideosService {
  static const String _savedVideosKey = 'saved_videos';
  static final SavedVideosService _instance = SavedVideosService._internal();
  factory SavedVideosService() => _instance;
  SavedVideosService._internal();

  List<Map<String, dynamic>> _savedVideos = [];

  Future<void> loadSavedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_savedVideosKey);
    if (savedData != null) {
      _savedVideos = List<Map<String, dynamic>>.from(json.decode(savedData));
    }
  }

  Future<void> saveVideo(String id, String videoUrl, String title, String creator) async {
    final video = {
      'id': id,
      'videoUrl': videoUrl,
      'title': title,
      'creator': creator,
      'savedAt': DateTime.now().toIso8601String(),
    };
    _savedVideos.insert(0, video);
    await _persist();
  }

  Future<void> unsaveVideo(String id) async {
    _savedVideos.removeWhere((v) => v['id'] == id);
    await _persist();
  }

  bool isSaved(String id) {
    return _savedVideos.any((v) => v['id'] == id);
  }

  List<Map<String, dynamic>> get savedVideos => _savedVideos;

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedVideosKey, json.encode(_savedVideos));
  }
}
