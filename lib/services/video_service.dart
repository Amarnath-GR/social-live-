import '../models/video_model.dart';
import '../models/user_model.dart';
import 'post_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoService {
  // Mock data for demonstration
  static final List<VideoModel> _mockVideos = [];

  Future<List<VideoModel>> getUserVideos(String? userId) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // Return mock user videos
    return _mockVideos.where((video) => video.user.id == (userId ?? 'current_user')).toList();
  }

  Future<List<VideoModel>> getLikedVideos(String? userId) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // Return mock liked videos
    return _mockVideos.where((video) => video.isLiked).toList();
  }

  Future<List<VideoModel>> getFeedVideos() async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 800));
    
    // Generate mock videos if empty
    if (_mockVideos.isEmpty) {
      _generateMockVideos();
    }
    
    return List.from(_mockVideos);
  }

  Future<VideoModel?> uploadVideo({
    required String videoPath,
    required String content,
    required List<String> hashtags,
    int? duration,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('user_id') ?? 'current_user';
      await prefs.setString('user_id', userId);
      
      final videoId = 'video_${DateTime.now().millisecondsSinceEpoch}';
      
      await PostStorageService.savePost(
        userId: userId,
        postId: videoId,
        videoPath: videoPath,
        thumbnailPath: '',
        description: content,
        hashtags: hashtags,
        duration: duration ?? 30,
      );
      
      final video = VideoModel(
        id: videoId,
        content: content,
        videoUrl: videoPath,
        duration: duration,
        createdAt: DateTime.now(),
        user: _getCurrentUser(),
        hashtags: hashtags,
        stats: VideoStats(likes: 0, comments: 0, shares: 0, views: 0),
        isLiked: false,
      );
      
      _mockVideos.insert(0, video);
      return video;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<void> likeVideo(String videoId) async {
    final videoIndex = _mockVideos.indexWhere((v) => v.id == videoId);
    if (videoIndex != -1) {
      _mockVideos[videoIndex].isLiked = true;
      _mockVideos[videoIndex].stats.likes++;
    }
  }

  Future<void> unlikeVideo(String videoId) async {
    final videoIndex = _mockVideos.indexWhere((v) => v.id == videoId);
    if (videoIndex != -1) {
      _mockVideos[videoIndex].isLiked = false;
      _mockVideos[videoIndex].stats.likes--;
    }
  }

  void _generateMockVideos() {
    final mockUser = _getCurrentUser();
    
    for (int i = 0; i < 10; i++) {
      _mockVideos.add(VideoModel(
        id: 'mock_video_$i',
        content: 'This is mock video content #$i #trending #viral',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        duration: 30 + (i * 5),
        createdAt: DateTime.now().subtract(Duration(hours: i)),
        user: mockUser,
        hashtags: ['trending', 'viral', 'mock'],
        stats: VideoStats(
          likes: 100 + (i * 50),
          comments: 10 + (i * 5),
          shares: 5 + i,
          views: 1000 + (i * 100),
        ),
        isLiked: i % 3 == 0,
      ));
    }
  }

  UserModel _getCurrentUser() {
    return UserModel(
      id: 'current_user',
      email: 'user@example.com',
      username: 'myusername',
      name: 'My Name',
      role: 'USER',
      verified: false,
      isBlocked: false,
      createdAt: DateTime.now().subtract(Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }
}