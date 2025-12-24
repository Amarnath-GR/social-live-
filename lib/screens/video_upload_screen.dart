import 'package:flutter/material.dart';
import 'dart:io';
import '../services/video_service.dart';
import 'reel_camera_screen.dart';

class VideoUploadScreen extends StatefulWidget {
  @override
  _VideoUploadScreenState createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  final VideoService _videoService = VideoService();
  final TextEditingController _captionController = TextEditingController();
  
  File? _selectedVideo;
  bool _isRecording = false;
  bool _isUploading = false;
  bool _isFrontCamera = false;
  String _selectedSound = 'Original Sound';
  List<String> _hashtags = [];
  String _privacy = 'Public';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera/Video Preview Area
          _buildVideoPreview(),
          
          // Top Controls
          _buildTopControls(),
          
          // Side Controls (Right)
          _buildSideControls(),
          
          // Bottom Controls
          _buildBottomControls(),
          
          // Upload Progress
          if (_isUploading) _buildUploadProgress(),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: _selectedVideo != null
          ? _buildVideoPlayer()
          : _buildCameraPreview(),
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player would go here
        Container(
          color: Colors.grey[900],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 80,
                ),
                SizedBox(height: 16),
                Text(
                  'Video Preview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Play/Pause Button
        Center(
          child: GestureDetector(
            onTap: _toggleVideoPlayback,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReelCameraScreen()),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview placeholder
          Container(
            color: Colors.grey[900],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam,
                    color: Colors.white,
                    size: 80,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tap to open Camera',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Record amazing reels',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Recording Indicator
          if (_isRecording)
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'REC',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // Close Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          // Timer
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '00:15',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
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
      bottom: 200,
      child: Column(
        children: [
          // Flip Camera
          _buildSideButton(
            icon: Icons.flip_camera_ios,
            onTap: _flipCamera,
          ),
          
          SizedBox(height: 20),
          
          // Speed Control
          _buildSideButton(
            icon: Icons.speed,
            label: '1x',
            onTap: _showSpeedOptions,
          ),
          
          SizedBox(height: 20),
          
          // Beauty Filter
          _buildSideButton(
            icon: Icons.face_retouching_natural,
            onTap: _showBeautyFilters,
          ),
          
          SizedBox(height: 20),
          
          // Effects
          _buildSideButton(
            icon: Icons.auto_fix_high,
            onTap: _showEffects,
          ),
          
          SizedBox(height: 20),
          
          // Timer
          _buildSideButton(
            icon: Icons.timer,
            onTap: _showTimerOptions,
          ),
          
          Spacer(),
          
          // Gallery
          _buildSideButton(
            icon: Icons.photo_library,
            onTap: _pickFromGallery,
          ),
        ],
      ),
    );
  }

  Widget _buildSideButton({
    required IconData icon,
    String? label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            if (label != null) ...[
              SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            // Record Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Templates
                _buildBottomButton(
                  icon: Icons.video_library,
                  label: 'Templates',
                  onTap: _showTemplates,
                ),
                
                // Record Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReelCameraScreen()),
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                
                // Upload
                _buildBottomButton(
                  icon: Icons.upload,
                  label: 'Upload',
                  onTap: _pickFromGallery,
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Caption Input (if video selected)
            if (_selectedVideo != null) _buildCaptionInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptionInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _captionController,
            style: TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write a caption...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
            ),
          ),
          
          SizedBox(height: 12),
          
          // Hashtag suggestions
          Wrap(
            spacing: 8,
            children: ['#fyp', '#viral', '#trending', '#fun'].map((tag) {
              return GestureDetector(
                onTap: () => _addHashtag(tag),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          SizedBox(height: 12),
          
          // Privacy and Post Button
          Row(
            children: [
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
              
              Spacer(),
              
              ElevatedButton(
                onPressed: _uploadVideo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Post',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
              'Uploading your video...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _flipCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    
    if (_isRecording) {
      // Start recording
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recording started')),
      );
    } else {
      // Stop recording and simulate video selection
      setState(() {
        _selectedVideo = File('dummy_path'); // Simulate recorded video
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recording stopped')),
      );
    }
  }

  void _toggleVideoPlayback() {
    // Implement video playback toggle
  }

  void _pickFromGallery() async {
    // Implement gallery picker
    setState(() {
      _selectedVideo = File('dummy_path'); // Simulate selected video
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
                  _buildSoundItem('Original Sound', true),
                  _buildSoundItem('Trending Song 1', false),
                  _buildSoundItem('Trending Song 2', false),
                  _buildSoundItem('Trending Song 3', false),
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
      title: Text(
        soundName,
        style: TextStyle(color: Colors.white),
      ),
      onTap: () {
        setState(() {
          _selectedSound = soundName;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showSpeedOptions() {
    // Implement speed options
  }

  void _showBeautyFilters() {
    // Implement beauty filters
  }

  void _showEffects() {
    // Implement effects
  }

  void _showTimerOptions() {
    // Implement timer options
  }

  void _showTemplates() {
    // Implement templates
  }

  void _showUploadOptions() {
    // Show upload options when video is ready
  }

  void _addHashtag(String hashtag) {
    if (!_hashtags.contains(hashtag)) {
      setState(() {
        _hashtags.add(hashtag);
      });
      _captionController.text += ' $hashtag';
    }
  }

  void _uploadVideo() async {
    if (_selectedVideo == null) return;
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      await _videoService.uploadVideo(
        videoFile: _selectedVideo!,
        caption: _captionController.text,
        hashtags: _hashtags,
        privacy: _privacy,
        sound: _selectedSound,
      );
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload video: $e'),
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