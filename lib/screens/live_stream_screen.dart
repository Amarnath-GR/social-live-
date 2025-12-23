import 'package:flutter/material.dart';
import 'dart:async';
import '../services/realtime_service.dart';
import '../services/gift_service.dart';
import '../widgets/gift_animation.dart';
import '../widgets/gift_panel.dart';
import '../widgets/stream_leaderboard.dart';

class LiveStreamScreen extends StatefulWidget {
  final String streamId;
  final String streamTitle;

  const LiveStreamScreen({
    super.key,
    required this.streamId,
    required this.streamTitle,
  });

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  final List<Widget> _giftAnimations = [];
  List<Map<String, dynamic>> _leaderboard = [];
  int _totalGifts = 0;
  int _walletBalance = 0;
  bool _showLeaderboard = true;
  Timer? _leaderboardTimer;

  @override
  void initState() {
    super.initState();
    _initializeStream();
    _loadLeaderboard();
    _startLeaderboardUpdates();
  }

  @override
  void dispose() {
    RealtimeService.leaveStream(widget.streamId);
    _leaderboardTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeStream() async {
    await RealtimeService.connect();
    RealtimeService.joinStream(widget.streamId);

    // Listen to gift events
    RealtimeService.giftStream.listen((giftData) {
      _showGiftAnimation(giftData);
    });

    // Listen to leaderboard updates
    RealtimeService.leaderboardStream.listen((data) {
      setState(() {
        _leaderboard = List<Map<String, dynamic>>.from(data['leaderboard'] ?? []);
        _totalGifts = data['totalGifts'] ?? 0;
      });
    });

    // Listen to wallet updates
    RealtimeService.walletStream.listen((balance) {
      setState(() {
        _walletBalance = balance;
      });
    });
  }

  Future<void> _loadLeaderboard() async {
    final result = await GiftService.getStreamLeaderboard(widget.streamId);
    if (result['success']) {
      setState(() {
        _leaderboard = List<Map<String, dynamic>>.from(result['leaderboard']);
        _totalGifts = result['totalGifts'] ?? 0;
      });
    }
  }

  void _startLeaderboardUpdates() {
    _leaderboardTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadLeaderboard();
    });
  }

  void _showGiftAnimation(Map<String, dynamic> giftData) {
    final gift = GiftService.getGiftById(giftData['giftId']);
    if (gift == null) return;

    late Widget animationWidget;
    animationWidget = Positioned(
      left: MediaQuery.of(context).size.width * 0.3,
      top: MediaQuery.of(context).size.height * 0.4,
      child: GiftAnimation(
        emoji: gift['emoji'],
        color: Color(gift['color']),
        quantity: giftData['quantity'] ?? 1,
        onComplete: () {
          setState(() {
            _giftAnimations.removeWhere((widget) => widget == animationWidget);
          });
        },
      ),
    );

    setState(() {
      _giftAnimations.add(animationWidget);
    });

    // Remove animation after delay if not removed by onComplete
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _giftAnimations.removeWhere((widget) => widget == animationWidget);
        });
      }
    });
  }

  void _showGiftPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GiftPanel(
        streamId: widget.streamId,
        onGiftSent: (gift) {
          // Local gift animation for immediate feedback
          _showGiftAnimation({
            'giftId': gift['id'],
            'quantity': gift['quantity'],
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video placeholder (replace with actual video player)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.live_tv,
                    color: Colors.white,
                    size: 80,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Live Stream',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Video player integration needed',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.streamTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Wallet balance
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.account_balance_wallet, 
                           color: Colors.amber[700], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$_walletBalance',
                        style: TextStyle(
                          color: Colors.amber[700],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Leaderboard
          if (_showLeaderboard)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              right: 16,
              child: StreamLeaderboard(
                leaderboard: _leaderboard.take(5).toList(),
                totalGifts: _totalGifts,
              ),
            ),

          // Gift animations overlay
          ..._giftAnimations,

          // Bottom controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Toggle leaderboard
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showLeaderboard = !_showLeaderboard;
                    });
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: Icon(
                      _showLeaderboard ? Icons.leaderboard : Icons.leaderboard_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),

                // Gift button
                GestureDetector(
                  onTap: _showGiftPanel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink[400]!, Colors.purple[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.card_giftcard, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Send Gift',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
