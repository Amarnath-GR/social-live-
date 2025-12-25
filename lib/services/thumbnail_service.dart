import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailService {
  static final ThumbnailService _instance = ThumbnailService._internal();
  factory ThumbnailService() => _instance;
  ThumbnailService._internal();

  Future<String> generateVideoThumbnail(String videoPath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final thumbnailDir = Directory('${directory.path}/thumbnails');
      if (!await thumbnailDir.exists()) {
        await thumbnailDir.create(recursive: true);
      }

      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: thumbnailDir.path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 300,
        quality: 75,
      );
      
      return thumbnailPath ?? videoPath;
    } catch (e) {
      return videoPath;
    }
  }

  Future<String> generatePhotoThumbnail(String photoPath) async {
    return photoPath;
  }
}