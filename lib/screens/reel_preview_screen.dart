import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';
import '../services/reel_service.dart';

class ReelPreviewScreen extends StatefulWidget {
  final String videoPath;

  const ReelPreviewScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  _ReelPreviewScreenState createState() => _ReelPreviewScreenState();
}

class _ReelPreviewScreenState extends State<ReelPreviewScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  final ReelService _reelService = ReelService();
  
  final TextEditingController _captionController = TextEditingController();
  bool _isUploading = false;
  String _privacy = 'Public';
  List<String> _hashtags = [];
  String _selectedSound = 'Original Sound';
  
  // Video editing controls
  double _volume = 1.0;
  bool _isMuted = false;
  
  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.file(File(widget.videoPath));
    await _videoController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: true,
      showControls: false,
      aspectRatio: _videoController.value.aspectRatio,
    );
    
    setState(() {});
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Preview
          _buildVideoPreview(),
          
          // Top Controls
          _buildTopControls(),
          
          // Side Controls
          _buildSideControls(),
          
          // Bottom Sheet for Caption and Settings
          _buildBottomSheet(),
          
          // Upload Progress
          if (_isUploading) _buildUploadProgress(),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_chewieController == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Center(
        child: AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
            ),
          ),
          
          Spacer(),
          
          // Sound Selection
          GestureDetector(
            onTap: _showSoundPicker,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.music_note, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    _selectedSound,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          // Volume Control
          GestureDetector(
            onTap: _toggleMute,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideControls() {
    return Positioned(
      right: 16,
      top: 120,
      bottom: 300,
      child: Column(
        children: [
          // Trim Video
          _buildSideButton(
            icon: Icons.content_cut,
            label: 'Trim',
            onTap: _showTrimOptions,
          ),
          
          SizedBox(height: 20),
          
          // Add Text
          _buildSideButton(
            icon: Icons.text_fields,
            label: 'Text',
            onTap: _addText,
          ),
          
          SizedBox(height: 20),
          
          // Add Stickers
          _buildSideButton(
            icon: Icons.emoji_emotions,
            label: 'Stickers',
            onTap: _addStickers,
          ),
          
          SizedBox(height: 20),
          
          // Filters
          _buildSideButton(
            icon: Icons.filter,
            label: 'Filters',
            onTap: _showFilters,
          ),
          
          SizedBox(height: 20),
          
          // Effects
          _buildSideButton(
            icon: Icons.auto_fix_high,
            label: 'Effects',
            onTap: _showEffects,
          ),
        ],
      ),
    );
  }

  Widget _buildSideButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Caption Input
                  TextField(
                    controller: _captionController,
                    style: TextStyle(color: Colors.white),
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Write a caption...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Hashtag Suggestions
                  Text(
                    'Suggested Hashtags',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '#fyp', '#viral', '#trending', '#reels', '#fun', '#dance',
                      '#comedy', '#music', '#lifestyle', '#fashion'
                    ].map((tag) {
                      final isSelected = _hashtags.contains(tag);
                      return GestureDetector(
                        onTap: () => _toggleHashtag(tag),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Colors.blue 
                                : Colors.grey[700],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Privacy Settings
                  Row(
                    children: [
                      Text(
                        'Who can see this:',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Spacer(),
                      DropdownButton<String>(
                        value: _privacy,
                        dropdownColor: Colors.grey[800],
                        style: TextStyle(color: Colors.white),
                        items: ['Public', 'Friends', 'Private'].map((privacy) {
                          return DropdownMenuItem(
                            value: privacy,
                            child: Text(privacy),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _privacy = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Additional Options
                  _buildOption(
                    icon: Icons.comment,
                    title: 'Allow comments',
                    value: true,
                    onChanged: (value) {},
                  ),
                  
                  _buildOption(
                    icon: Icons.download,
                    title: 'Allow downloads',
                    value: false,
                    onChanged: (value) {},
                  ),
                  
                  _buildOption(
                    icon: Icons.share,
                    title: 'Allow sharing',
                    value: true,
                    onChanged: (value) {},
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Post Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _uploadVideo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'Post Reel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Uploading your reel...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'This may take a few moments',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePlayPause() {
    if (_videoController.value.isPlaying) {
      _videoController.pause();
    } else {
      _videoController.play();
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _videoController.setVolume(_isMuted ? 0.0 : _volume);
    });
  }

  void _toggleHashtag(String hashtag) {
    setState(() {
      if (_hashtags.contains(hashtag)) {
        _hashtags.remove(hashtag);
        _captionController.text = _captionController.text.replaceAll(' $hashtag', '');
      } else {
        _hashtags.add(hashtag);
        _captionController.text += ' $hashtag';
      }
    });
  }

  void _showSoundPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        height: 400,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Choose Sound',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildSoundItem('Original Sound', _selectedSound == 'Original Sound'),
                  _buildSoundItem('Trending Song 1', _selectedSound == 'Trending Song 1'),
                  _buildSoundItem('Trending Song 2', _selectedSound == 'Trending Song 2'),
                  _buildSoundItem('Popular Beat', _selectedSound == 'Popular Beat'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundItem(String soundName, bool isSelected) {
    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.music_note,
        color: isSelected ? Colors.blue : Colors.white,
      ),
      title: Text(soundName, style: TextStyle(color: Colors.white)),
      subtitle: Text('Trending', style: TextStyle(color: Colors.grey[400])),
      onTap: () {
        setState(() {
          _selectedSound = soundName;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showTrimOptions() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Video trimming coming soon')),
    );
  }

  void _addText() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Text overlay coming soon')),
    );
  }

  void _addStickers() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stickers coming soon')),
    );
  }

  void _showFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Filters coming soon')),
    );
  }

  void _showEffects() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Effects coming soon')),
    );
  }

  Future<void> _uploadVideo() async {
    if (_captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add a caption'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await _reelService.uploadReel(
        videoFile: File(widget.videoPath),
        caption: _captionController.text,
        hashtags: _hashtags,
        privacy: _privacy,
        sound: _selectedSound,
        duration: _videoController.value.duration.inSeconds.toDouble(),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reel posted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload reel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}