import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import '../services/camera_service.dart';
import '../services/video_service.dart';
import 'reel_preview_screen.dart';

class ReelCameraScreen extends StatefulWidget {
  @override
  _ReelCameraScreenState createState() => _ReelCameraScreenState();
}

class _ReelCameraScreenState extends State<ReelCameraScreen>
    with TickerProviderStateMixin {
  final CameraService _cameraService = CameraService.instance;
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isInitialized = false;
  bool _isRecording = false;
  String? _recordedVideoPath;
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  int _maxDuration = 60; // 60 seconds max
  
  // UI Controllers
  late AnimationController _recordButtonController;
  late AnimationController _timerController;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  
  // Recording settings
  FlashMode _flashMode = FlashMode.off;
  bool _isFrontCamera = false;
  double _recordingSpeed = 1.0;
  
  @override
  void initState() {
    super.initState();
    _recordButtonController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _timerController = AnimationController(
      duration: Duration(seconds: 60),
      vsync: this,
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final success = await _cameraService.initialize();
    if (success && mounted) {
      setState(() {
        _isInitialized = true;
      });
      _setupZoom();
    } else {
      _showError('Failed to initialize camera');
    }
  }

  Future<void> _setupZoom() async {
    if (_cameraService.controller != null) {
      _minZoom = await _cameraService.controller!.getMinZoomLevel();
      _maxZoom = await _cameraService.controller!.getMaxZoomLevel();
      setState(() {
        _currentZoom = _minZoom;
      });
    }
  }

  @override
  void dispose() {
    _recordButtonController.dispose();
    _timerController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Initializing Camera...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          _buildCameraPreview(),
          
          // Top Controls
          _buildTopControls(),
          
          // Side Controls
          _buildSideControls(),
          
          // Bottom Controls
          _buildBottomControls(),
          
          // Recording Timer
          if (_isRecording) _buildRecordingTimer(),
          
          // Zoom Slider
          if (_currentZoom != _minZoom) _buildZoomSlider(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Text(
            'Camera not available',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return GestureDetector(
      onTapUp: (details) => _onCameraViewTap(details),
      onScaleStart: (details) => _onScaleStart(details),
      onScaleUpdate: (details) => _onScaleUpdate(details),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: CameraPreview(controller),
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
          // Close Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 24),
            ),
          ),
          
          Spacer(),
          
          // Flash Toggle
          GestureDetector(
            onTap: _toggleFlash,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _flashMode == FlashMode.off 
                    ? Icons.flash_off 
                    : _flashMode == FlashMode.always
                        ? Icons.flash_on
                        : Icons.flash_auto,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          // Speed Control
          GestureDetector(
            onTap: _showSpeedOptions,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_recordingSpeed}x',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
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
          
          // Timer
          _buildSideButton(
            icon: Icons.timer,
            onTap: _showTimerOptions,
          ),
          
          SizedBox(height: 20),
          
          // Effects (placeholder)
          _buildSideButton(
            icon: Icons.auto_fix_high,
            onTap: _showEffects,
          ),
          
          SizedBox(height: 20),
          
          // Beauty Filter (placeholder)
          _buildSideButton(
            icon: Icons.face_retouching_natural,
            onTap: _showBeautyFilters,
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
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Duration Selector
          Container(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [15, 30, 60].map((duration) {
                final isSelected = _maxDuration == duration;
                return GestureDetector(
                  onTap: () => setState(() => _maxDuration = duration),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white 
                          : Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${duration}s',
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          SizedBox(height: 30),
          
          // Record Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Templates (placeholder)
              _buildBottomButton(
                icon: Icons.video_library,
                label: 'Templates',
                onTap: _showTemplates,
              ),
              
              // Main Record Button
              GestureDetector(
                onTap: _toggleRecording,
                child: AnimatedBuilder(
                  animation: _recordButtonController,
                  builder: (context, child) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _isRecording ? Colors.red : Colors.white,
                          shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
                          borderRadius: _isRecording ? BorderRadius.circular(8) : null,
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.videocam,
                          color: _isRecording ? Colors.white : Colors.black,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Upload from Gallery
              _buildBottomButton(
                icon: Icons.upload,
                label: 'Upload',
                onTap: _pickFromGallery,
              ),
            ],
          ),
        ],
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
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingTimer() {
    return Positioned(
      top: 100,
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
              '${(_recordingDuration ~/ 60).toString().padLeft(2, '0')}:${(_recordingDuration % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomSlider() {
    return Positioned(
      left: 20,
      top: 200,
      bottom: 200,
      child: RotatedBox(
        quarterTurns: 3,
        child: Slider(
          value: _currentZoom,
          min: _minZoom,
          max: _maxZoom,
          onChanged: (value) {
            setState(() {
              _currentZoom = value;
            });
            _cameraService.setZoomLevel(value);
          },
          activeColor: Colors.white,
          inactiveColor: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  // Camera Controls
  void _onCameraViewTap(TapUpDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final tapPosition = renderBox.globalToLocal(details.globalPosition);
    final focusPoint = Offset(
      tapPosition.dx / renderBox.size.width,
      tapPosition.dy / renderBox.size.height,
    );
    _cameraService.setFocusPoint(focusPoint);
  }

  void _onScaleStart(ScaleStartDetails details) {
    // Store initial zoom for pinch-to-zoom
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final newZoom = (_currentZoom * details.scale).clamp(_minZoom, _maxZoom);
    if (newZoom != _currentZoom) {
      setState(() {
        _currentZoom = newZoom;
      });
      _cameraService.setZoomLevel(newZoom);
    }
  }

  void _toggleFlash() {
    setState(() {
      switch (_flashMode) {
        case FlashMode.off:
          _flashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          _flashMode = FlashMode.always;
          break;
        case FlashMode.always:
          _flashMode = FlashMode.off;
          break;
        default:
          _flashMode = FlashMode.off;
      }
    });
    _cameraService.setFlashMode(_flashMode);
  }

  Future<void> _flipCamera() async {
    await _cameraService.switchCamera();
    setState(() {
      _isFrontCamera = _cameraService.isFrontCamera;
    });
    _setupZoom();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final videoPath = await _cameraService.startRecording();
    if (videoPath != null) {
      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });
      
      _recordButtonController.forward();
      _timerController.forward();
      
      _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration++;
        });
        
        if (_recordingDuration >= _maxDuration) {
          _stopRecording();
        }
      });
    }
  }

  Future<void> _stopRecording() async {
    final videoPath = await _cameraService.stopRecording();
    
    _recordingTimer?.cancel();
    _recordButtonController.reverse();
    _timerController.reset();
    
    setState(() {
      _isRecording = false;
      _recordedVideoPath = videoPath;
    });
    
    if (videoPath != null) {
      _navigateToPreview(videoPath);
    }
  }

  void _navigateToPreview(String videoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReelPreviewScreen(videoPath: videoPath),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await _imagePicker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: Duration(seconds: _maxDuration),
    );
    
    if (pickedFile != null) {
      _navigateToPreview(pickedFile.path);
    }
  }

  void _showSpeedOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        height: 200,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Recording Speed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [0.3, 0.5, 1.0, 2.0, 3.0].map((speed) {
                  return ListTile(
                    leading: Icon(
                      _recordingSpeed == speed ? Icons.check_circle : Icons.speed,
                      color: _recordingSpeed == speed ? Colors.blue : Colors.white,
                    ),
                    title: Text(
                      '${speed}x',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      setState(() {
                        _recordingSpeed = speed;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimerOptions() {
    // Implement timer options (3s, 10s countdown)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Timer options coming soon')),
    );
  }

  void _showEffects() {
    // Implement effects
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Effects coming soon')),
    );
  }

  void _showBeautyFilters() {
    // Implement beauty filters
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Beauty filters coming soon')),
    );
  }

  void _showTemplates() {
    // Implement templates
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Templates coming soon')),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}