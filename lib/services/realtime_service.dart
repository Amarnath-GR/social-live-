import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/api_config.dart';
import '../services/auth_service.dart';

class RealtimeService {
  static io.Socket? _socket;
  static final StreamController<Map<String, dynamic>> _giftController = 
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _leaderboardController = 
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<int> _walletController = 
      StreamController<int>.broadcast();

  static Stream<Map<String, dynamic>> get giftStream => _giftController.stream;
  static Stream<Map<String, dynamic>> get leaderboardStream => _leaderboardController.stream;
  static Stream<int> get walletStream => _walletController.stream;

  static Future<void> connect() async {
    if (_socket?.connected == true) return;

    final token = await AuthService().getToken();
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api/v1', '');

    _socket = io.io(baseUrl, io.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .build());

    _socket!.connect();

    _socket!.on('connect', (_) {
      debugPrint('Connected to realtime server');
    });

    _socket!.on('disconnect', (_) {
      debugPrint('Disconnected from realtime server');
    });

    _socket!.on('gift_received', (data) {
      _giftController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('leaderboard_updated', (data) {
      _leaderboardController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('wallet_updated', (data) {
      final balance = data['balance'] as int? ?? 0;
      _walletController.add(balance);
    });
  }

  static void joinStream(String streamId) {
    _socket?.emit('join_stream', {'streamId': streamId});
  }

  static void leaveStream(String streamId) {
    _socket?.emit('leave_stream', {'streamId': streamId});
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  static void dispose() {
    disconnect();
    _giftController.close();
    _leaderboardController.close();
    _walletController.close();
  }
}
