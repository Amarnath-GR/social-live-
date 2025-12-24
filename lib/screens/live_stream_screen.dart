import 'package:flutter/material.dart';
import '../services/live_stream_service.dart';
import '../models/gift_model.dart';

class LiveStreamScreen extends StatefulWidget {
  final String? streamId; // If null, creates new stream

  LiveStreamScreen({this.streamId});

  @override
  _LiveStreamScreenState createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  final LiveStreamService _liveStreamService = LiveStreamService();
  final TextEditingController _messageController = TextEditingController();
  
  bool _isStreaming = false;
  bool _isHost = false;
  int _viewerCount = 0;
  int _giftCount = 0;
  List<ChatMessage> _messages = [];
  List<GiftModel> _availableGifts = [];
  String _streamTitle = 'Demo Live Stream';

  @override
  void initState() {
    super.initState();
    _initializeStream();
    _loadGifts();
  }

  Future<void> _initializeStream() async {
    if (widget.streamId == null) {
      // Create new stream
      _isHost = true;
      setState(() {
        _isStreaming = true;
      });
    } else {
      // Join existing stream
      _isHost = false;
      // Load stream data
    }
  }

  Future<void> _loadGifts() async {
    _availableGifts = [
      GiftModel(id: '1', name: 'Heart', icon: '❤️', cost: 10),
      GiftModel(id: '2', name: 'Star', icon: '⭐', cost: 25),
      GiftModel(id: '3', name: 'Diamond', icon: '💎', cost: 50),
      GiftModel(id: '4', name: 'Crown', icon: '👑', cost: 100),
      GiftModel(id: '5', name: 'Rocket', icon: '🚀', cost: 200),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Stream Area
          _buildVideoArea(),
          
          // Top Bar
          _buildTopBar(),
          
          // Top Gifters Panel
          _buildTopGiftersPanel(),
          
          // Chat Messages
          _buildChatArea(),
          
          // Bottom Controls
          _buildBottomControls(),
          
          // Send Gift Button
          _buildSendGiftButton(),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.videocam_off,
                color: Colors.white,
                size: 60,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Live Stream',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Video player integration needed',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 40,
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
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          // Stream Title and Live Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _streamTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Coin Balance
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.yellow, size: 16),
                SizedBox(width: 4),
                Text(
                  '0', // Replace with actual balance
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopGiftersPanel() {
    return Positioned(
      top: 120,
      right: 16,
      child: Container(
        width: 200,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.leaderboard, color: Colors.yellow, size: 16),
                SizedBox(width: 6),
                Text(
                  'Top Gifters',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Spacer(),
                Text(
                  '$_giftCount',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'No gifts yet',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Positioned(
      bottom: 120,
      left: 16,
      right: 80,
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildChatMessage(_messages[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${message.username}: ',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            TextSpan(
              text: message.message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
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
        padding: EdgeInsets.all(16),
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
        child: Row(
          children: [
            // Menu Button
            IconButton(
              onPressed: _showStreamMenu,
              icon: Icon(Icons.menu, color: Colors.white),
            ),
            
            // Message Input
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Say something...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
            ),
            
            // Record Button (for host)
            if (_isHost)
              IconButton(
                onPressed: _toggleRecording,
                icon: Icon(
                  Icons.fiber_manual_record,
                  color: _isStreaming ? Colors.red : Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendGiftButton() {
    return Positioned(
      bottom: 80,
      right: 16,
      child: GestureDetector(
        onTap: _showGiftPanel,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink, Colors.purple],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.card_giftcard, color: Colors.white, size: 20),
              SizedBox(width: 6),
              Text(
                'Send Gift',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGiftPanel() {
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
              child: Row(
                children: [
                  Text(
                    'Send Gift',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.monetization_on, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '0', // Replace with actual balance
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _availableGifts.length,
                itemBuilder: (context, index) {
                  return _buildGiftItem(_availableGifts[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftItem(GiftModel gift) {
    return GestureDetector(
      onTap: () => _sendGift(gift),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              gift.icon,
              style: TextStyle(fontSize: 32),
            ),
            SizedBox(height: 8),
            Text(
              gift.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on, color: Colors.yellow, size: 12),
                SizedBox(width: 2),
                Text(
                  '${gift.cost}',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(
        username: 'You',
        message: message,
        timestamp: DateTime.now(),
      ));
    });
    
    _messageController.clear();
  }

  void _sendGift(GiftModel gift) {
    Navigator.pop(context);
    // Implement gift sending logic
    setState(() {
      _giftCount++;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent ${gift.name} gift!'),
        backgroundColor: Colors.pink,
      ),
    );
  }

  void _toggleRecording() {
    setState(() {
      _isStreaming = !_isStreaming;
    });
  }

  void _showStreamMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.share, color: Colors.white),
              title: Text('Share Stream', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _shareStream();
              },
            ),
            if (_isHost) ...[
              ListTile(
                leading: Icon(Icons.settings, color: Colors.white),
                title: Text('Stream Settings', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showStreamSettings();
                },
              ),
              ListTile(
                leading: Icon(Icons.stop, color: Colors.red),
                title: Text('End Stream', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _endStream();
                },
              ),
            ] else ...[
              ListTile(
                leading: Icon(Icons.report, color: Colors.red),
                title: Text('Report Stream', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _reportStream();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _shareStream() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stream shared!')),
    );
  }

  void _showStreamSettings() {
    // Implement stream settings
  }

  void _endStream() {
    Navigator.pop(context);
  }

  void _reportStream() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stream reported')),
    );
  }
}

class ChatMessage {
  final String username;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.username,
    required this.message,
    required this.timestamp,
  });
}