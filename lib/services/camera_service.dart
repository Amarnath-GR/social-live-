import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  static CameraService get instance => _instance;
  CameraService._internal();

  CameraController? controller;
  List<CameraDescription> cameras = [];
  int currentCameraIndex = 0;

  Future<bool> initialize() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) return false;

      controller = CameraController(
        cameras[currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: true,
      );

      await controller!.initialize();
      return true;
    } catch (e) {
      print('Camera initialization error: $e');
      return false;
    }
  }

  Future<void> switchCamera() async {
    if (cameras.length <= 1) return;

    currentCameraIndex = (currentCameraIndex + 1) % cameras.length;
    await controller?.dispose();

    controller = CameraController(
      cameras[currentCameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
    );

    await controller!.initialize();
  }

  Future<void> setFocusPoint(Offset point) async {
    if (controller != null && controller!.value.isInitialized) {
      await controller!.setFocusPoint(point);
    }
  }

  Future<void> setZoomLevel(double zoom) async {
    if (controller != null && controller!.value.isInitialized) {
      await controller!.setZoomLevel(zoom);
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller != null && controller!.value.isInitialized) {
      await controller!.setFlashMode(mode);
    }
  }

  Future<void> startRecording() async {
    if (controller != null && controller!.value.isInitialized) {
      try {
        await controller!.startVideoRecording();
      } catch (e) {
        print('Error starting recording: $e');
      }
    }
  }

  Future<XFile?> stopRecording() async {
    if (controller != null && controller!.value.isRecordingVideo) {
      try {
        return await controller!.stopVideoRecording();
      } catch (e) {
        print('Error stopping recording: $e');
        return null;
      }
    }
    return null;
  }

  bool get isFrontCamera => currentCameraIndex == 1;

  void dispose() {
    controller?.dispose();
  }
}