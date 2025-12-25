import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';
import '../services/live_stream_service.dart';
import '../models/gift_model.dart';

class LiveCameraStreamScreen extends StatefulWidget {
  final bool isHost;
  final String? streamId;

  const LiveCameraStreamScreen({
    Key? key,
    this.isHost = true,
    this.streamId,
  }) : super(key: key);

  @override
  _LiveCameraStreamScreenState createState() => _LiveCameraStreamScreenState();
}

class _LiveCameraStreamScreenState extends State<LiveCameraStreamScreen> {
  final CameraService _cameraService = CameraService.instance;
  final LiveStreamService _liveStreamService = LiveStreamService();
  final TextEditingController _messageController = TextEditingController();

  bool _isStreaming = false;
  bool _isInitialized = false;
  int _viewerCount = 0;
  int _giftCount = 0;
  List<ChatMessage> _messages = [];
  List<GiftModel> _availableGifts = [];
  String _streamTitle = 'Live Stream';
  double _currentZoom = 1.0;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadGifts();
  }

  Future<void> _initializeCamera() async {
    final success = await _cameraService.initialize();
    if (success) {
      setState(() {
        _isInitialized = true;
      });
    } else {
      _showError('Failed to initialize camera');
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
          // Camera Preview
          _buildCameraPreview(),
          
          // Top Bar
          _buildTopBar(),
          
          // Camera Controls (Right Side)
          _buildCameraControls(),
          
          // Chat Messages
          _buildChatArea(),
          
          // Bottom Controls
          _buildBottomControls(),
          
          // Send Gift Button
          if (!widget.isHost) _buildSendGiftButton(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isInitialized || _cameraService.controller == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
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

    return GestureDetector(
      onTapUp: (details) => _onCameraViewTap(details),
      onScaleUpdate: (details) => _handleZoom(details),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: CameraPreview(_cameraService.controller!),
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
              child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          
          SizedBox(width: 12),
          
          // Stream Info
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
                if (_isStreaming)
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
          ),
          
          // Viewer Count
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.visibility, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  '$_viewerCount',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraControls() {
    return Positioned(
      top: 120,
      right: 16,
      child: Column(
        children: [
          // Switch Camera
          _buildControlButton(
            icon: Icons.flip_camera_ios,
            onTap: _switchCamera,
          ),
          SizedBox(height: 12),
          
          // Flash Toggle
          _buildControlButton(
            icon: _flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on,
            onTap: _toggleFlash,
          ),
          SizedBox(height: 12),
          
          // Zoom Controls
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _adjustZoom(0.1),
                  child: Icon(Icons.zoom_in, color: Colors.white, size: 20),
                ),
                SizedBox(height: 8),
                Text(
                  '${_currentZoom.toStringAsFixed(1)}x',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _adjustZoom(-0.1),
                  child: Icon(Icons.zoom_out, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildChatArea() {
    return Positioned(
      bottom: 120,
      left: 16,
      right: widget.isHost ? 16 : 80,
      height: 200,
      child: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) => _buildChatMessage(_messages[index]),
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
              style: TextStyle(color: Colors.white, fontSize: 12),
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
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        child: Row(
          children: [
            // Stream Toggle Button
            if (widget.isHost)
              GestureDetector(
                onTap: _toggleStream,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isStreaming ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    _isStreaming ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            
            SizedBox(width: 12),
            
            // Message Input
            Expanded(
              child: Container(
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
            
            SizedBox(width: 12),
            
            // Menu Button
            GestureDetector(
              onTap: _showStreamMenu,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(Icons.more_vert, color: Colors.white),
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
            gradient: LinearGradient(colors: [Colors.pink, Colors.purple]),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.card_giftcard, color: Colors.white, size: 20),
              SizedBox(width: 6),
              Text(
                'Gift',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Camera Control Methods
  void _onCameraViewTap(TapUpDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPoint = renderBox.globalToLocal(details.globalPosition);
    final Offset relativePoint = Offset(
      localPoint.dx / renderBox.size.width,
      localPoint.dy / renderBox.size.height,
    );
    _cameraService.setFocusPoint(relativePoint);
  }

  void _handleZoom(ScaleUpdateDetails details) {
    _currentZoom = (_currentZoom * details.scale).clamp(1.0, 5.0);
    _cameraService.setZoomLevel(_currentZoom);
  }

  void _adjustZoom(double delta) {
    setState(() {
      _currentZoom = (_currentZoom + delta).clamp(1.0, 5.0);
    });
    _cameraService.setZoomLevel(_currentZoom);
  }

  void _switchCamera() async {
    await _cameraService.switchCamera();
    setState(() {});
  }

  void _toggleFlash() {
    setState(() {
      _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    });
    _cameraService.setFlashMode(_flashMode);
  }

  void _toggleStream() {
    setState(() {
      _isStreaming = !_isStreaming;
    });
    
    if (_isStreaming) {
      _startStream();
    } else {
      _stopStream();
    }
  }

  void _startStream() {
    // Implement stream start logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Live stream started!')),
    );
  }

  void _stopStream() {
    // Implement stream stop logic and return recording data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Live stream stopped and saved!')),
    );
    
    // Return recording information when stream ends
    Navigator.pop(context, {
      'recorded': true,
      'videoPath': 'live_recording_${widget.streamId}',
      'duration': 60, // Mock duration
    });
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
                itemBuilder: (context, index) => _buildGiftItem(_availableGifts[index]),
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
            Text(gift.icon, style: TextStyle(fontSize: 32)),
            SizedBox(height: 8),
            Text(
              gift.name,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on, color: Colors.yellow, size: 12),
                SizedBox(width: 2),
                Text(
                  '${gift.cost}',
                  style: TextStyle(color: Colors.yellow, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendGift(GiftModel gift) {
    Navigator.pop(context);
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

  void _showStreamMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isHost) ...[
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
                  _stopStream();
                },
              ),
            ],
            ListTile(
              leading: Icon(Icons.share, color: Colors.white),
              title: Text('Share Stream', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _shareStream();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStreamSettings() {
    // Implement stream settings
  }

  void _shareStream() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stream shared!')),
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

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
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