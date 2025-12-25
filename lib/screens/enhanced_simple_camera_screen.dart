import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'enhanced_live_stream_screen.dart';
import 'video_description_screen.dart';
import 'photo_preview_screen.dart';
import '../services/user_content_service.dart';

class EnhancedSimpleCameraScreen extends StatefulWidget {
  final bool autoStartRecording;
  final bool isLiveMode;
  
  const EnhancedSimpleCameraScreen({
    super.key,
    this.autoStartRecording = false,
    this.isLiveMode = false,
  });
  
  @override
  _EnhancedSimpleCameraScreenState createState() => _EnhancedSimpleCameraScreenState();
}

class _EnhancedSimpleCameraScreenState extends State<EnhancedSimpleCameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool isRecording = false;
  bool isFlashOn = false;
  bool isFrontCamera = false;
  double recordingProgress = 0.0;
  bool _cameraInitialized = false;
  String _currentMode = 'Video'; // Photo, Video, Live
  int _selectedCameraIndex = 0;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 8.0;

  @override
  void initState() {
    super.initState();
    if (widget.isLiveMode) {
      _currentMode = 'Live';
    }
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _selectedCameraIndex = isFrontCamera ? 1 : 0;
        if (_selectedCameraIndex >= _cameras!.length) {
          _selectedCameraIndex = 0;
        }
        
        _cameraController = CameraController(
          _cameras![_selectedCameraIndex],
          ResolutionPreset.high,
          enableAudio: true,
        );
        
        await _cameraController!.initialize();
        
        // Get zoom limits
        _minZoom = await _cameraController!.getMinZoomLevel();
        _maxZoom = await _cameraController!.getMaxZoomLevel();
        _currentZoom = _minZoom;
        
        if (mounted) {
          setState(() {
            _cameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
      // Fallback to mock camera
      setState(() {
        _cameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    
    setState(() {
      _cameraInitialized = false;
      isFrontCamera = !isFrontCamera;
    });
    
    await _cameraController?.dispose();
    
    _selectedCameraIndex = isFrontCamera ? 1 : 0;
    if (_selectedCameraIndex >= _cameras!.length) {
      _selectedCameraIndex = 0;
    }
    
    _cameraController = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
    );
    
    await _cameraController!.initialize();
    
    // Get zoom limits
    _minZoom = await _cameraController!.getMinZoomLevel();
    _maxZoom = await _cameraController!.getMaxZoomLevel();
    _currentZoom = _minZoom;
    
    if (mounted) {
      setState(() {
        _cameraInitialized = true;
      });
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      setState(() {
        isFlashOn = !isFlashOn;
      });
      return;
    }
    
    setState(() {
      isFlashOn = !isFlashOn;
    });
    
    try {
      await _cameraController!.setFlashMode(
        isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  void _adjustZoom(double increment) {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final zoomRange = _maxZoom - _minZoom;
      final adjustedIncrement = increment * (zoomRange / 10); // Scale increment based on zoom range
      final newZoom = (_currentZoom + adjustedIncrement).clamp(_minZoom, _maxZoom);
      _cameraController!.setZoomLevel(newZoom);
      setState(() {
        _currentZoom = newZoom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
          // Camera Preview (Real or Mock)
          GestureDetector(
            onScaleUpdate: (details) {
              if (_cameraController != null && _cameraController!.value.isInitialized) {
                final newZoom = (_minZoom + (details.scale - 1.0) * (_maxZoom - _minZoom) * 0.1).clamp(_minZoom, _maxZoom);
                _cameraController!.setZoomLevel(newZoom);
                setState(() {
                  _currentZoom = newZoom;
                });
              }
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: _cameraInitialized
                  ? (_cameraController != null && _cameraController!.value.isInitialized
                      ? CameraPreview(_cameraController!)
                      : Center(
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.grey[700],
                            size: 80,
                          ),
                        ))
                  : Center(
                      child: CircularProgressIndicator(color: Colors.purple),
                    ),
            ),
          ),

          // Top Controls
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close, color: Colors.white, size: 28),
                ),
                IconButton(
                  onPressed: _toggleFlash,
                  icon: Icon(
                    isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: isFlashOn ? Colors.purple : Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          // Recording Progress
          if (isRecording)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: LinearProgressIndicator(
                value: recordingProgress,
                backgroundColor: Colors.grey[700],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            ),

          // Side Controls
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              children: [
                _buildSideButton(
                  icon: Icons.flip_camera_ios,
                  onTap: _switchCamera,
                ),
                SizedBox(height: 20),
                _buildSideButton(
                  icon: Icons.speed,
                  onTap: () {
                    _showSpeedOptions();
                  },
                ),
                SizedBox(height: 20),
                _buildSideButton(
                  icon: Icons.timer,
                  onTap: () {
                    _showTimerOptions();
                  },
                ),
                SizedBox(height: 20),
                _buildSideButton(
                  icon: Icons.music_note,
                  onTap: () {
                    _showMusicSelector();
                  },
                ),
                SizedBox(height: 20),
                _buildSideButton(
                  icon: Icons.zoom_in,
                  onTap: () {
                    _adjustZoom(0.2);
                  },
                ),
              ],
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Recording modes with text labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeButton('Photo', Icons.camera_alt),
                    SizedBox(width: 20),
                    _buildModeButton('Video', Icons.videocam),
                    SizedBox(width: 20),
                    _buildModeButton('Live', Icons.sensors),
                  ],
                ),
                SizedBox(height: 30),
                
                // Main controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery - single option
                    GestureDetector(
                      onTap: () {
                        _showGallery();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[600]!, width: 1),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(Icons.photo_library, color: Colors.white, size: 24),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.add, color: Colors.white, size: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Record Button
                    GestureDetector(
                      onTap: () {
                        _toggleRecording();
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.purple, width: 4),
                        ),
                        child: Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isRecording ? Colors.purple : Colors.white,
                            shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
                            borderRadius: isRecording ? BorderRadius.circular(8) : null,
                          ),
                        ),
                      ),
                    ),
                    
                    // Effects - removed
                    SizedBox(width: 50),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildModeButton(String mode, IconData icon) {
    final isActive = _currentMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentMode = mode;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.purple : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.purple : Colors.grey[600]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey[400],
              size: 18,
            ),
            SizedBox(width: 6),
            Text(
              mode,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[400],
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  void _toggleRecording() {
    // Initialize camera for all modes when user first interacts
    if (!_cameraInitialized) {
      _initializeCamera().then((_) {
        if (mounted) {
          _performAction();
        }
      });
      return;
    }
    
    _performAction();
  }
  
  void _performAction() {
    if (_currentMode == 'Photo') {
      _takePhoto();
      return;
    }
    
    if (_currentMode == 'Live') {
      _startLiveStream();
      return;
    }
    
    // Video recording
    if (isRecording) {
      _stopRecording();
    } else {
      setState(() {
        isRecording = true;
        recordingProgress = 0.0;
      });
      _startRecording();
    }
  }

  void _startRecording() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        if (!_cameraController!.value.isRecordingVideo) {
          await _cameraController!.startVideoRecording();
        }
      } catch (e) {
        print('Error starting recording: $e');
      }
    }
    
    // Update recording progress
    _updateRecordingProgress();
  }
  
  void _updateRecordingProgress() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted && isRecording && recordingProgress < 1.0) {
        setState(() {
          recordingProgress += 0.01;
        });
        _updateRecordingProgress();
      }
    });
  }

  Future<void> _stopRecording() async {
    setState(() {
      isRecording = false;
    });
    
    if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
      try {
        final videoFile = await _cameraController!.stopVideoRecording();
        final videoDuration = (recordingProgress * 60).toInt();
        
        // Save to user content
        UserContentService().addVideo(videoFile.path, videoDuration);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoDescriptionScreen(
              videoPath: videoFile.path,
              videoDuration: videoDuration,
            ),
          ),
        );
      } catch (e) {
        print('Error stopping recording: $e');
        // Fallback on error
        final videoDuration = (recordingProgress * 60).toInt();
        final videoPath = 'recorded_video_${DateTime.now().millisecondsSinceEpoch}';
        UserContentService().addVideo(videoPath, videoDuration);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoDescriptionScreen(
              videoPath: videoPath,
              videoDuration: videoDuration,
            ),
          ),
        );
      }
    } else {
      // Fallback for mock camera
      final videoDuration = (recordingProgress * 60).toInt();
      final videoPath = 'recorded_video_${DateTime.now().millisecondsSinceEpoch}';
      UserContentService().addVideo(videoPath, videoDuration);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoDescriptionScreen(
            videoPath: videoPath,
            videoDuration: videoDuration,
          ),
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    if (!_cameraInitialized) {
      await _initializeCamera();
    }
    
    String photoPath;
    
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final image = await _cameraController!.takePicture();
        photoPath = image.path;
        
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoPreviewScreen(photoPath: photoPath),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error taking photo: $e')),
          );
        }
      }
    } else {
      // Use image picker as fallback
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.camera);
        
        if (image != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoPreviewScreen(photoPath: image.path),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Camera not available')),
          );
        }
      }
    }
  }

  void _startLiveStream() {
    // Directly navigate to live stream screen and start streaming immediately
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedLiveStreamScreen(
          isStreaming: true,
        ),
      ),
    );
  }

  void _showGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Show options for photo or video
      final result = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.grey[900],
        builder: (context) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo, color: Colors.purple),
                title: Text('Select Photo', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, 'photo'),
              ),
              ListTile(
                leading: Icon(Icons.video_library, color: Colors.purple),
                title: Text('Select Video', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, 'video'),
              ),
            ],
          ),
        ),
      );
      
      if (result == 'photo') {
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoPreviewScreen(photoPath: image.path),
            ),
          );
        }
      } else if (result == 'video') {
        final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
        if (video != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoDescriptionScreen(
                videoPath: video.path,
                videoDuration: 30,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showEffectsPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Effects & Filters',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  final effects = ['Normal', 'Beauty', 'Vintage', 'B&W', 'Warm', 'Cool', 'Bright', 'Dark'];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${effects[index]} effect applied!')),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.filter, color: Colors.purple, size: 24),
                          SizedBox(height: 4),
                          Text(
                            effects[index],
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeedOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Recording Speed',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpeedOption('0.5x'),
                _buildSpeedOption('1x'),
                _buildSpeedOption('2x'),
                _buildSpeedOption('3x'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedOption(String speed) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speed set to $speed')),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple),
        ),
        child: Text(speed, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showTimerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Timer',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimerOption('Off'),
                _buildTimerOption('3s'),
                _buildTimerOption('10s'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerOption(String timer) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Timer set to $timer')),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple),
        ),
        child: Text(timer, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showMusicSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Add Music',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.music_note, color: Colors.purple),
                    ),
                    title: Text('Song ${index + 1}', style: TextStyle(color: Colors.white)),
                    subtitle: Text('Artist ${index + 1}', style: TextStyle(color: Colors.grey[400])),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Song ${index + 1} added!')),
                        );
                      },
                      icon: Icon(Icons.add, color: Colors.purple),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}