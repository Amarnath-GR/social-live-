import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'video_preview_screen.dart';

class VideoRecordingScreen extends StatefulWidget {
  final String? currentVideoAudio;
  final String? currentVideoTitle;

  const VideoRecordingScreen({
    super.key,
    this.currentVideoAudio,
    this.currentVideoTitle,
  });

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isRecording = false;
  bool _isInitialized = false;
  bool _hasPermission = false;
  int _recordingDuration = 0;
  int _currentCameraIndex = 0;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  String? _selectedMusic;
  bool _showMusicSelector = false;

  @override
  void initState() {
    super.initState();
    _selectedMusic = widget.currentVideoAudio;
    _initializeCamera();
    
    // Show audio options automatically if current video has audio
    if (widget.currentVideoAudio != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAudioOptions();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameraPermission = await Permission.camera.request();
    final microphonePermission = await Permission.microphone.request();

    if (cameraPermission.isGranted && microphonePermission.isGranted) {
      setState(() {
        _hasPermission = true;
      });

      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        // Start with back camera (index 0) if available
        _currentCameraIndex = 0;
        await _setupCamera(_cameras[_currentCameraIndex]);
      }
    } else {
      setState(() {
        _hasPermission = false;
      });
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    _controller?.dispose();
    
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _controller!.initialize();
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      _currentZoom = _minZoom;
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _toggleRecording() async {
    if (!_isInitialized || _controller == null) return;

    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });
      
      _startTimer();
    } catch (e) {
      debugPrint('Recording start error: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final videoFile = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VideoPreviewScreen(
              videoFile: File(videoFile.path),
              selectedMusic: _selectedMusic,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Recording stop error: $e');
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        setState(() {
          _recordingDuration++;
        });
        if (_recordingDuration < 60) {
          _startTimer();
        } else {
          _stopRecording();
        }
      }
    });
  }

  Future<void> _onZoomChanged(double zoom) async {
    if (_controller == null || !_isInitialized) return;
    
    final clampedZoom = zoom.clamp(_minZoom, _maxZoom);
    await _controller!.setZoomLevel(clampedZoom);
    setState(() {
      _currentZoom = clampedZoom;
    });
  }

  void _showMusicSelection() {
    setState(() {
      _showMusicSelector = true;
    });
  }

  void _hideMusicSelection() {
    setState(() {
      _showMusicSelector = false;
    });
  }

  void _selectMusic(String? music) {
    setState(() {
      _selectedMusic = music;
      _showMusicSelector = false;
    });
  }

  void _showAudioOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Audio Options',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.music_video, color: Colors.white),
              ),
              title: Text(
                widget.currentVideoTitle ?? 'Current Video Audio',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Use this sound from the current video',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Use this sound',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                _selectMusic(widget.currentVideoAudio);
                Navigator.pop(context);
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.videocam, color: Colors.white),
              ),
              title: const Text(
                'Create without sound',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Record with original audio only',
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () {
                _selectMusic(null);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _setupCamera(_cameras[_currentCameraIndex]);
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildMusicTile(String title, String? musicFile, {bool isCurrentVideo = false}) {
    final isSelected = _selectedMusic == musicFile;
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : (isCurrentVideo ? Colors.orange : Colors.grey[800]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isSelected ? Icons.check : (isCurrentVideo ? Icons.music_video : Icons.music_note),
          color: Colors.white,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.red : (isCurrentVideo ? Colors.orange : Colors.white),
                fontWeight: isSelected || isCurrentVideo ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isCurrentVideo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Use this sound',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: musicFile != null
          ? const Text(
              'Tap to preview',
              style: TextStyle(color: Colors.grey),
            )
          : null,
      onTap: () => _selectMusic(musicFile),
      trailing: musicFile != null
          ? IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Preview: $title'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Camera and microphone permissions required',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initializeCamera,
                child: const Text('Grant Permissions'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview with zoom gesture
          GestureDetector(
            onScaleUpdate: (details) {
              final newZoom = _currentZoom * details.scale;
              _onZoomChanged(newZoom);
            },
            child: CameraPreview(_controller!),
          ),

          // Top overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26,
                    ),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
                if (_isRecording)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(_recordingDuration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                GestureDetector(
                  onTap: _switchCamera,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26,
                    ),
                    child: const Icon(Icons.flip_camera_ios, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Side controls
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              children: [
                // Zoom slider
                Container(
                  height: 200,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Slider(
                      value: _currentZoom,
                      min: _minZoom,
                      max: _maxZoom,
                      onChanged: _onZoomChanged,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Music selection button
                GestureDetector(
                  onTap: _showMusicSelection,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedMusic != null ? Colors.red : Colors.black26,
                    ),
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                if (_selectedMusic != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedMusic!.split('/').last.replaceAll('.mp3', ''),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Recording button
                GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: _isRecording ? Colors.red : Colors.transparent,
                    ),
                    child: Center(
                      child: Container(
                        width: _isRecording ? 24 : 60,
                        height: _isRecording ? 24 : 60,
                        decoration: BoxDecoration(
                          shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
                          color: _isRecording ? Colors.white : Colors.red,
                          borderRadius: _isRecording ? BorderRadius.circular(4) : null,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isRecording ? 'Tap to stop' : 'Tap to record',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Music selector overlay
          if (_showMusicSelector)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      title: const Text('Select Music', style: TextStyle(color: Colors.white)),
                      leading: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _hideMusicSelection,
                      ),
                      elevation: 0,
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (widget.currentVideoAudio != null) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red, width: 2),
                              ),
                              child: _buildMusicTile(
                                widget.currentVideoTitle ?? 'Current Video Audio',
                                widget.currentVideoAudio!,
                                isCurrentVideo: true,
                              ),
                            ),
                          ],
                          _buildMusicTile('No Music', null),
                          _buildMusicTile('Upbeat Pop', 'upbeat_pop.mp3'),
                          _buildMusicTile('Chill Vibes', 'chill_vibes.mp3'),
                          _buildMusicTile('Electronic Beat', 'electronic_beat.mp3'),
                          _buildMusicTile('Acoustic Guitar', 'acoustic_guitar.mp3'),
                          _buildMusicTile('Hip Hop Beat', 'hip_hop_beat.mp3'),
                          _buildMusicTile('Jazz Smooth', 'jazz_smooth.mp3'),
                          _buildMusicTile('Rock Energy', 'rock_energy.mp3'),
                          _buildMusicTile('Ambient Calm', 'ambient_calm.mp3'),
                        ],
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
}
