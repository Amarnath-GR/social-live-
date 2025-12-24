import 'package:flutter/material.dart';

class EnhancedLiveStreamScreen extends StatefulWidget {
  final bool isStreaming;
  
  const EnhancedLiveStreamScreen({Key? key, this.isStreaming = false}) : super(key: key);

  @override
  _EnhancedLiveStreamScreenState createState() => _EnhancedLiveStreamScreenState();
}

class _EnhancedLiveStreamScreenState extends State<EnhancedLiveStreamScreen> with TickerProviderStateMixin {
  bool _isLive = false;
  int _viewerCount = 0;
  int _likeCount = 0;
  bool _isFollowing = false;
  List<String> _comments = [];
  TextEditingController _commentController = TextEditingController();
  late AnimationController _pulseController;
  
  // Featured products during live stream
  List<Map<String, dynamic>> _featuredProducts = [
    {
      'id': 'prod_1',
      'name': 'Trendy T-Shirt',
      'price': 29.99,
      'tokens': 150,
      'image': 'https://via.placeholder.com/100x100/FF6B6B/FFFFFF?text=Shirt',
      'featured': true,
    },
    {
      'id': 'prod_2', 
      'name': 'Wireless Headphones',
      'price': 89.99,
      'tokens': 450,
      'image': 'https://via.placeholder.com/100x100/4ECDC4/FFFFFF?text=Headphones',
      'featured': false,
    },
    {
      'id': 'prod_3',
      'name': 'Phone Case',
      'price': 19.99,
      'tokens': 100,
      'image': 'https://via.placeholder.com/100x100/45B7D1/FFFFFF?text=Case',
      'featured': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    if (widget.isStreaming) {
      _startStream();
    }
  }

  void _startStream() {
    setState(() {
      _isLive = true;
      _viewerCount = 1;
    });
    
    // Simulate viewer count changes
    _simulateViewers();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔴 Live stream started!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _stopStream() {
    setState(() {
      _isLive = false;
    });
    
    // Save stream to profile
    _saveStreamToProfile();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stream ended and saved to your profile!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _saveStreamToProfile() {
    // Simulate saving stream recording to profile
    final streamData = {
      'id': 'stream_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Live Stream - ${DateTime.now().day}/${DateTime.now().month}',
      'duration': '${DateTime.now().difference(DateTime.now().subtract(Duration(minutes: 5))).inMinutes}m',
      'viewers': _viewerCount,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    print('Saving stream to profile: $streamData');
  }

  void _simulateViewers() {
    if (_isLive) {
      Future.delayed(Duration(seconds: 2), () {
        if (_isLive && mounted) {
          setState(() {
            _viewerCount += (1 + (DateTime.now().millisecond % 3));
          });
          _simulateViewers();
        }
      });
    }
  }

  void _addComment(String comment) {
    if (comment.isNotEmpty) {
      setState(() {
        _comments.add(comment);
        if (_comments.length > 10) {
          _comments.removeAt(0);
        }
      });
      _commentController.clear();
    }
  }

  void _featureProduct(int index) {
    setState(() {
      // Reset all products
      for (var product in _featuredProducts) {
        product['featured'] = false;
      }
      // Feature selected product
      _featuredProducts[index]['featured'] = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_featuredProducts[index]['name']} is now featured!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _buyWithTokens(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Buy with Tokens', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${product['name']}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Price: ${product['tokens']} tokens', style: TextStyle(color: Colors.orange)),
            SizedBox(height: 8),
            Text('Your balance: 1,250 tokens', style: TextStyle(color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Purchased ${product['name']} for ${product['tokens']} tokens!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Buy Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProductsPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
                  Icon(Icons.shopping_bag, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Featured Products',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _featuredProducts.length,
                itemBuilder: (context, index) {
                  final product = _featuredProducts[index];
                  final isFeatured = product['featured'];
                  
                  return GestureDetector(
                    onTap: () => _buyWithTokens(product),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        border: isFeatured ? Border.all(color: Colors.orange, width: 2) : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.shopping_bag, color: Colors.white, size: 40),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product['name'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isFeatured)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'FEATURED',
                                          style: TextStyle(color: Colors.white, fontSize: 10),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '\$${product['price']}',
                                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.monetization_on, color: Colors.orange, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      '${product['tokens']} tokens',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
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

  void _toggleLike() {
    setState(() {
      _likeCount++;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❤️ Liked!'),
        duration: Duration(milliseconds: 500),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFollowing ? 'Following!' : 'Unfollowed'),
        duration: Duration(milliseconds: 800),
        backgroundColor: _isFollowing ? Colors.green : Colors.grey,
      ),
    );
  }

  void _shareStream() {
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
              'Share Live Stream',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.link, color: Colors.white),
              title: Text('Copy Link', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Link copied to clipboard!')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.white),
              title: Text('Share via...', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening share options...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Live Stream Background (Camera view placeholder)
          Container(
            color: Colors.grey[900],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isLive ? Icons.videocam : Icons.videocam_off,
                    color: _isLive ? Colors.red : Colors.white,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    _isLive ? 'You are LIVE!' : 'Tap to start streaming',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isLive) ...[
                    SizedBox(height: 8),
                    Text(
                      'Camera feed will appear here',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Live indicator
          if (_isLive)
            Positioned(
              top: 50,
              left: 20,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8 + 0.2 * _pulseController.value),
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
                        Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Viewer count
          if (_isLive)
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('$_viewerCount', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),

          // Right Side Action Buttons
          Positioned(
            right: 10,
            bottom: 200,
            child: Column(
              children: [
                // Like Button
                GestureDetector(
                  onTap: _toggleLike,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.favorite, color: Colors.red, size: 28),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _likeCount > 0 ? '$_likeCount' : 'Like',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                
                // Follow Button
                GestureDetector(
                  onTap: _toggleFollow,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isFollowing ? Colors.purple : Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isFollowing ? Icons.person_remove : Icons.person_add,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _isFollowing ? 'Following' : 'Follow',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                
                // Share Button
                GestureDetector(
                  onTap: _shareStream,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.share, color: Colors.white, size: 28),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Share',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                
                // Products Button
                GestureDetector(
                  onTap: () => _showProductsPanel(),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.shopping_bag, color: Colors.white, size: 28),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Shop',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Comments section
          if (_isLive)
            Positioned(
              left: 10,
              right: 80,
              bottom: 100,
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 4),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _comments[index],
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (text) => _addComment(text),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _addComment(_commentController.text),
                          icon: Icon(Icons.send, color: Colors.purple, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Control buttons
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Close button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
                
                // Start/Stop stream button
                GestureDetector(
                  onTap: _isLive ? _stopStream : _startStream,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isLive ? Colors.red : Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isLive ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                
                // Flip camera button
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Camera flipped!'),
                        backgroundColor: Colors.purple,
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.flip_camera_ios, color: Colors.white, size: 24),
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