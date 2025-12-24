import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  static CameraService? _instance;
  static CameraService get instance => _instance ??= CameraService._();
  CameraService._();

  List<CameraDescription>? _cameras;
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  bool _isRecording = false;
  bool _isInitialized = false;

  // Getters
  List<CameraDescription>? get cameras => _cameras;
  CameraController? get controller => _controller;
  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;
  bool get isFrontCamera => _selectedCameraIndex == 1;

  Future<bool> initialize() async {
    try {
      // Request permissions
      final cameraPermission = await Permission.camera.request();
      final microphonePermission = await Permission.microphone.request();
      
      if (cameraPermission != PermissionStatus.granted ||
          microphonePermission != PermissionStatus.granted) {
        return false;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        return false;
      }

      // Initialize with back camera first
      _selectedCameraIndex = 0;
      await _initializeCamera();
      
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing camera: $e');
      return false;
    }
  }

  Future<void> _initializeCamera() async {
    if (_cameras == null || _cameras!.isEmpty) return;

    // Dispose previous controller
    await _controller?.dispose();

    // Create new controller
    _controller = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
  }

  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    await _initializeCamera();
  }

  Future<String?> startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized || _isRecording) {
      return null;
    }

    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      
      await _controller!.startVideoRecording();
      _isRecording = true;
      
      return filePath;
    } catch (e) {
      print('Error starting recording: $e');
      return null;
    }
  }

  Future<String?> stopRecording() async {
    if (_controller == null || !_isRecording) return null;

    try {
      final videoFile = await _controller!.stopVideoRecording();
      _isRecording = false;
      return videoFile.path;
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  Future<String?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      final image = await _controller!.takePicture();
      return image.path;
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  void setFlashMode(FlashMode mode) {
    _controller?.setFlashMode(mode);
  }

  void setExposureMode(ExposureMode mode) {
    _controller?.setExposureMode(mode);
  }

  void setFocusMode(FocusMode mode) {
    _controller?.setFocusMode(mode);
  }

  Future<void> setZoomLevel(double zoom) async {
    if (_controller == null) return;
    
    final maxZoom = await _controller!.getMaxZoomLevel();
    final minZoom = await _controller!.getMinZoomLevel();
    
    final clampedZoom = zoom.clamp(minZoom, maxZoom);
    await _controller!.setZoomLevel(clampedZoom);
  }

  Future<void> setFocusPoint(Offset point) async {
    if (_controller == null) return;
    
    await _controller!.setFocusPoint(point);
    await _controller!.setExposurePoint(point);
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _isRecording = false;
  }
}