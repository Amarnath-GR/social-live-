import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';
import '../models/user_model.dart';

class RealVideoService {
  // Public video APIs that provide real content
  static const String _pixabayApiKey = 'YOUR_PIXABAY_API_KEY'; // Get from pixabay.com
  static const String _pexelsApiKey = 'YOUR_PEXELS_API_KEY'; // Get from pexels.com
  
  // Curated list of high-quality, royalty-free videos
  static const List<Map<String, dynamic>> _curatedVideos = [
    {
      'id': 'big_buck_bunny',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'thumbnail': 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
      'title': 'Big Buck Bunny',
      'description': 'A large and lovable rabbit deals with three tiny bullies',
      'duration': 596000,
      'creator': 'Blender Foundation',
      'tags': ['animation', '3d', 'bunny', 'comedy']
    },
    {
      'id': 'elephants_dream',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      'thumbnail': 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
      'title': 'Elephants Dream',
      'description': 'The first open movie from the Blender Foundation',
      'duration': 653000,
      'creator': 'Blender Foundation',
      'tags': ['animation', 'surreal', 'dream', 'artistic']
    },
    {
      'id': 'for_bigger_blazes',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'thumbnail': 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg',
      'title': 'For Bigger Blazes',
      'description': 'Epic outdoor adventure and stunning landscapes',
      'duration': 15000,
      'creator': 'Google',
      'tags': ['nature', 'adventure', 'landscape', 'outdoor']
    },
    {
      'id': 'for_bigger_escapes',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'thumbnail': 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg',
      'title': 'For Bigger Escapes',
      'description': 'Escape to beautiful destinations around the world',
      'duration': 15000,
      'creator': 'Google',
      'tags': ['travel', 'escape', 'beautiful', 'destinations']
    },
    {
      'id': 'for_bigger_fun',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      'thumbnail': 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg',
      'title': 'For Bigger Fun',
      'description': 'Fun activities and exciting moments',
      'duration': 60000,
      'creator': 'Google',
      'tags': ['fun', 'activities', 'exciting', 'entertainment']
    },
    {
      'id': 'for_bigger_joyrides',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
      'thumbnail': 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg',
      'title': 'For Bigger Joyrides',
      'description': 'Thrilling rides and automotive adventures',
      'duration': 15000,
      'creator': 'Google',
      'tags': ['cars', 'joyride', 'automotive', 'thrilling']
    },
    {
      'id': 'for_bigger_meltdowns',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
      'thumbnail': 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerMeltdowns.jpg',
      'title': 'For Bigger Meltdowns',
      'description': 'Ice and snow melting in spectacular fashion',
      'duration': 15000,
      'creator': 'Google',
      'tags': ['ice', 'snow', 'melting', 'nature']
    },
    {
      'id': 'sintel',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
      'thumbnail': 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg',
      'title': 'Sintel',
      'description': 'A lonely young woman, Sintel, helps and befriends a dragon',
      'duration': 888000,
      'creator': 'Blender Foundation',
      'tags': ['animation', 'dragon', 'fantasy', 'adventure']
    },
    {
      'id': 'subaru_outback',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
      'thumbnail': 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg',
      'title': 'Subaru Outback',
      'description': 'Subaru Outback on street and dirt roads',
      'duration': 15000,
      'creator': 'Subaru',
      'tags': ['cars', 'subaru', 'outback', 'driving']
    },
    {
      'id': 'tears_of_steel',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      'thumbnail': 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg',
      'title': 'Tears of Steel',
      'description': 'A sci-fi short film about robots and humanity',
      'duration': 734000,
      'creator': 'Blender Foundation',
      'tags': ['scifi', 'robots', 'humanity', 'future']
    },
  ];

  // Additional short-form vertical videos (TikTok-style)
  static const List<Map<String, dynamic>> _shortFormVideos = [
    {
      'id': 'vertical_1',
      'url': 'https://sample-videos.com/zip/10/mp4/SampleVideo_360x640_1mb.mp4',
      'thumbnail': 'https://via.placeholder.com/360x640/FF6B6B/FFFFFF?text=Vertical+1',
      'title': 'Vertical Video 1',
      'description': 'Amazing vertical content perfect for mobile viewing 📱',
      'duration': 30000,
      'creator': 'Mobile Creator',
      'tags': ['vertical', 'mobile', 'short', 'trending']
    },
    {
      'id': 'vertical_2',
      'url': 'https://sample-videos.com/zip/10/mp4/SampleVideo_360x640_2mb.mp4',
      'thumbnail': 'https://via.placeholder.com/360x640/4ECDC4/FFFFFF?text=Vertical+2',
      'title': 'Vertical Video 2',
      'description': 'Quick and engaging content that keeps you scrolling 🔥',
      'duration': 25000,
      'creator': 'Content Pro',
      'tags': ['quick', 'engaging', 'viral', 'content']
    },
  ];

  static Future<List<VideoModel>> getRealVideos({int limit = 20}) async {
    try {
      // Combine curated and short-form videos
      final allVideos = [..._curatedVideos, ..._shortFormVideos];
      
      // Shuffle for variety
      allVideos.shuffle();
      
      // Take requested limit
      final selectedVideos = allVideos.take(limit).toList();
      
      // Convert to VideoModel objects
      final videoModels = selectedVideos.asMap().entries.map((entry) {
        final index = entry.key;
        final videoData = entry.value;
        
        return VideoModel(
          id: videoData['id'],
          content: '${videoData['description']} ${_generateHashtags(videoData['tags'])}',
          videoUrl: videoData['url'],
          thumbnailUrl: videoData['thumbnail'],
          duration: videoData['duration'],
          createdAt: DateTime.now().subtract(Duration(hours: index)),
          user: _generateCreator(videoData['creator'], index),
          hashtags: List<String>.from(videoData['tags']),
          stats: _generateStats(index),
          isLiked: false,
          autoPlay: true,
        );
      }).toList();
      
      return videoModels;
    } catch (e) {
      print('Error fetching real videos: $e');
      return _getFallbackVideos();
    }
  }

  static UserModel _generateCreator(String creatorName, int index) {
    final avatarColors = ['FF6B6B', '4ECDC4', '45B7D1', 'FFA07A', '98D8C8', 'F7DC6F'];
    final color = avatarColors[index % avatarColors.length];
    
    return UserModel(
      id: 'creator_$index',
      email: '${creatorName.toLowerCase().replaceAll(' ', '_')}@example.com',
      username: creatorName.toLowerCase().replaceAll(' ', '_'),
      name: creatorName,
      avatar: 'https://via.placeholder.com/100x100/$color/FFFFFF?text=${creatorName[0]}',
      role: 'CREATOR',
      verified: index % 4 == 0, // 25% verified creators
      isBlocked: false,
      createdAt: DateTime.now().subtract(Duration(days: index * 30)),
      updatedAt: DateTime.now(),
    );
  }

  static VideoStats _generateStats(int index) {
    final baseViews = 10000 + (index * 5000);
    final baseLikes = (baseViews * 0.05).round() + (index * 50);
    final baseComments = (baseLikes * 0.1).round() + (index * 10);
    final baseShares = (baseComments * 0.2).round() + (index * 2);
    
    return VideoStats(
      views: baseViews,
      likes: baseLikes,
      comments: baseComments,
      shares: baseShares,
    );
  }

  static String _generateHashtags(List<dynamic> tags) {
    return tags.map((tag) => '#$tag').join(' ');
  }

  static List<VideoModel> _getFallbackVideos() {
    // Fallback videos in case of network issues
    return [
      VideoModel(
        id: 'fallback_1',
        content: 'Welcome to our amazing social platform! 🎉 #welcome #social #platform',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        thumbnailUrl: 'https://via.placeholder.com/300x400/FF6B6B/FFFFFF?text=Welcome',
        duration: 30000,
        createdAt: DateTime.now(),
        user: UserModel(
          id: 'platform_official',
          email: 'official@platform.com',
          username: 'official',
          name: 'Platform Official',
          avatar: 'https://via.placeholder.com/100x100/4ECDC4/FFFFFF?text=P',
          role: 'ADMIN',
          verified: true,
          isBlocked: false,
          createdAt: DateTime.now().subtract(Duration(days: 365)),
          updatedAt: DateTime.now(),
        ),
        hashtags: ['welcome', 'social', 'platform'],
        stats: VideoStats(views: 50000, likes: 2500, comments: 150, shares: 75),
        isLiked: false,
        autoPlay: true,
      ),
    ];
  }

  // Method to fetch videos from Pixabay (requires API key)
  static Future<List<VideoModel>> getPixabayVideos({int limit = 10}) async {
    if (_pixabayApiKey == 'YOUR_PIXABAY_API_KEY') {
      print('Pixabay API key not configured');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('https://pixabay.com/api/videos/?key=$_pixabayApiKey&per_page=$limit&category=all'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final videos = data['hits'] as List;

        return videos.map((video) {
          return VideoModel(
            id: video['id'].toString(),
            content: '${video['tags']} #pixabay #video',
            videoUrl: video['videos']['medium']['url'],
            thumbnailUrl: video['webformatURL'],
            duration: video['duration'] * 1000, // Convert to milliseconds
            createdAt: DateTime.now(),
            user: UserModel(
              id: video['user_id'].toString(),
              email: '${video['user']}@pixabay.com',
              username: video['user'],
              name: video['user'],
              avatar: video['userImageURL'] ?? 'https://via.placeholder.com/100x100/4ECDC4/FFFFFF?text=U',
              role: 'CREATOR',
              verified: false,
              isBlocked: false,
              createdAt: DateTime.now().subtract(Duration(days: 100)),
              updatedAt: DateTime.now(),
            ),
            hashtags: video['tags'].split(', '),
            stats: VideoStats(
              views: video['views'],
              likes: video['likes'],
              comments: video['comments'],
              shares: video['downloads'],
            ),
            isLiked: false,
            autoPlay: true,
          );
        }).toList();
      }
    } catch (e) {
      print('Error fetching Pixabay videos: $e');
    }

    return [];
  }

  // Method to fetch videos from Pexels (requires API key)
  static Future<List<VideoModel>> getPexelsVideos({int limit = 10}) async {
    if (_pexelsApiKey == 'YOUR_PEXELS_API_KEY') {
      print('Pexels API key not configured');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.pexels.com/videos/popular?per_page=$limit'),
        headers: {'Authorization': _pexelsApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final videos = data['videos'] as List;

        return videos.map((video) {
          return VideoModel(
            id: video['id'].toString(),
            content: 'Amazing video content from Pexels #pexels #video #trending',
            videoUrl: video['video_files'][0]['link'],
            thumbnailUrl: video['image'],
            duration: video['duration'] * 1000, // Convert to milliseconds
            createdAt: DateTime.parse(video['created_at'] ?? DateTime.now().toIso8601String()),
            user: UserModel(
              id: video['user']['id'].toString(),
              email: '${video['user']['name'].toLowerCase().replaceAll(' ', '_')}@pexels.com',
              username: video['user']['name'].toLowerCase().replaceAll(' ', '_'),
              name: video['user']['name'],
              avatar: 'https://via.placeholder.com/100x100/4ECDC4/FFFFFF?text=${video['user']['name'][0]}',
              role: 'CREATOR',
              verified: false,
              isBlocked: false,
              createdAt: DateTime.now().subtract(Duration(days: 50)),
              updatedAt: DateTime.now(),
            ),
            hashtags: ['pexels', 'video', 'trending'],
            stats: VideoStats(
              views: (video['id'] * 100), // Mock views based on ID
              likes: (video['id'] * 5), // Mock likes
              comments: (video['id'] * 2), // Mock comments
              shares: video['id'], // Mock shares
            ),
            isLiked: false,
            autoPlay: true,
          );
        }).toList();
      }
    } catch (e) {
      print('Error fetching Pexels videos: $e');
    }

    return [];
  }
}