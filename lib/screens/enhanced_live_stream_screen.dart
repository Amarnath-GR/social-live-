import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:share_plus/share_plus.dart';
import '../services/wallet_service.dart';

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
  bool _isLiked = false;
  bool _isFollowing = false;
  List<String> _comments = [];
  TextEditingController _commentController = TextEditingController();
  late AnimationController _pulseController;
  final WalletService _walletService = WalletService();
  
  int get _userTokens => WalletService.tokenBalance;
  
  // Camera variables
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _cameraInitialized = false;
  
  // Featured products during live stream
  List<Map<String, dynamic>> _featuredProducts = [
    {
      'id': 'prod_1',
      'name': 'Trendy T-Shirt',
      'price': 29.99,
      'tokens': 150,
      'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=200&h=200&fit=crop',
      'featured': true,
    },
    {
      'id': 'prod_2', 
      'name': 'Wireless Headphones',
      'price': 89.99,
      'tokens': 450,
      'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200&h=200&fit=crop',
      'featured': false,
    },
    {
      'id': 'prod_3',
      'name': 'Phone Case',
      'price': 19.99,
      'tokens': 100,
      'image': 'https://images.unsplash.com/photo-1556656793-08538906a9f8?w=200&h=200&fit=crop',
      'featured': false,
    },
    {
      'id': 'prod_4',
      'name': 'Smart Watch',
      'price': 199.99,
      'tokens': 800,
      'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200&h=200&fit=crop',
      'featured': false,
    },
    {
      'id': 'prod_5',
      'name': 'Sunglasses',
      'price': 49.99,
      'tokens': 250,
      'image': 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=200&h=200&fit=crop',
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
    
    _initializeCamera();
    
    if (widget.isStreaming) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startStream();
      });
    }
  }
  
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: true,
        );
        
        await _cameraController!.initialize();
        
        if (mounted) {
          setState(() {
            _cameraInitialized = true;
          });
        }
      }
    } catch (e) {
      // Fallback to mock camera if real camera fails
      setState(() {
        _cameraInitialized = true;
      });
    }
  }

  void _startStream() {
    setState(() {
      _isLive = true;
      _viewerCount = 1;
    });
    
    _simulateViewers();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🔴 Live stream started!'), backgroundColor: Colors.red),
        );
      }
    });
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
    final requiredTokens = product['tokens'] as int;
    final canAfford = _userTokens >= requiredTokens;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Buy with Tokens', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product['image'],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey[700],
                  child: Icon(Icons.shopping_bag, color: Colors.white, size: 40),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('${product['name']}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🪙', style: TextStyle(fontSize: 20)),
                SizedBox(width: 4),
                Text('${product['tokens']} tokens', style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: canAfford ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: canAfford ? Colors.green : Colors.red),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your balance:', style: TextStyle(color: Colors.white)),
                  Text('$_userTokens 🪙', style: TextStyle(color: canAfford ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (!canAfford)
              SizedBox(height: 8),
            if (!canAfford)
              Text(
                'Need ${requiredTokens - _userTokens} more tokens',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          if (!canAfford)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showBuyMoreTokens();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: Text('Buy Tokens', style: TextStyle(color: Colors.white)),
            ),
          if (canAfford)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processPurchase(product, 'tokens');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Buy with Tokens', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  void _buyWithMoney(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Buy with Money', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product['image'],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey[700],
                  child: Icon(Icons.shopping_bag, color: Colors.white, size: 40),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('${product['name']}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attach_money, color: Colors.green, size: 20),
                Text('\$${product['price']}', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Text(
                'Payment will be processed securely',
                style: TextStyle(color: Colors.blue, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
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
              _processPurchase(product, 'money');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Buy Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPurchaseOptions(Map<String, dynamic> product) {
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product['image'],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[700],
                  child: Icon(Icons.shopping_bag, color: Colors.white, size: 40),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('${product['name']}', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _buyWithTokens(product);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Text('🪙', style: TextStyle(fontSize: 16)),
                    label: Text('${product['tokens']} Tokens', style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _buyWithMoney(product);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(Icons.attach_money, color: Colors.white),
                    label: Text('\$${product['price']}', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _processPurchase(Map<String, dynamic> product, [String paymentMethod = 'tokens']) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: paymentMethod == 'tokens' ? Colors.orange : Colors.green),
            SizedBox(height: 16),
            Text('Processing purchase...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
    
    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(context);
    
    if (paymentMethod == 'tokens') {
      final success = WalletService.spendTokens(product['tokens'] as int, 'Purchased ${product['name']} in live stream');
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction failed - insufficient tokens'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      final success = WalletService.spendCash(product['price'] as double, 'Purchased ${product['name']} in live stream');
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction failed - insufficient funds'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    // Show success
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Purchase Successful!', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product['image'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[700],
                  child: Icon(Icons.shopping_bag, color: Colors.white, size: 30),
                ),
              ),
            ),
            SizedBox(height: 12),
            Text('${product['name']}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              paymentMethod == 'tokens' 
                ? 'Paid: ${product['tokens']} tokens 🪙'
                : 'Paid: \$${product['price']}',
              style: TextStyle(color: paymentMethod == 'tokens' ? Colors.orange : Colors.green),
            ),
            if (paymentMethod == 'tokens')
              SizedBox(height: 8),
            if (paymentMethod == 'tokens')
              Text('Remaining: $_userTokens tokens', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Great!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBuyMoreTokens() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Need More Tokens?', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monetization_on, color: Colors.orange, size: 48),
            SizedBox(height: 16),
            Text(
              'You don\'t have enough tokens for this purchase.',
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Visit your wallet to buy more tokens with your cash balance.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Go to Wallet → Buy Tokens to purchase more tokens'),
                  backgroundColor: Colors.purple,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Go to Wallet', style: TextStyle(color: Colors.white)),
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
                    onTap: () => _showPurchaseOptions(product),
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product['image'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[700],
                                    child: Icon(Icons.shopping_bag, color: Colors.white, size: 40),
                                  );
                                },
                              ),
                            ),
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
                                Row(
                                  children: [
                                    Icon(Icons.attach_money, color: Colors.green, size: 14),
                                    Text(
                                      '\$${product['price']}',
                                      style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 8),
                                    Text('🪙', style: TextStyle(fontSize: 14)),
                                    SizedBox(width: 2),
                                    Text(
                                      '${product['tokens']}',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
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
      if (!_isLiked) {
        _isLiked = true;
        _likeCount++;
      } else {
        _isLiked = false;
        _likeCount--;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isLiked ? '❤️ Liked!' : 'Unliked'),
        duration: Duration(milliseconds: 500),
        backgroundColor: _isLiked ? Colors.red : Colors.grey,
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
                Share.share(
                  'https://sociallive.app/live/stream_${DateTime.now().millisecondsSinceEpoch}',
                  subject: 'Join my live stream!',
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.white),
              title: Text('Share via...', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Share.share(
                  'I\'m live now on Social Live! Join me at https://sociallive.app/live/stream_${DateTime.now().millisecondsSinceEpoch}',
                  subject: 'Join my live stream on Social Live!',
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
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
          // Live Stream Background (Camera view)
          Positioned.fill(
            child: _cameraInitialized && _cameraController != null && _cameraController!.value.isInitialized
                ? CameraPreview(_cameraController!)
                : Container(
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
                          if (_isLive)
                            SizedBox(height: 8),
                          if (_isLive)
                            Text(
                              _cameraInitialized ? 'Camera feed will appear here' : 'Initializing camera...',
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                        ],
                      ),
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

          // Featured Product Overlay
          if (_isLive && _featuredProducts.any((p) => p['featured']))
            Positioned(
              top: 100,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  final featuredProduct = _featuredProducts.firstWhere((p) => p['featured']);
                  _buyWithTokens(featuredProduct);
                },
                child: Container(
                  width: 200,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _featuredProducts.firstWhere((p) => p['featured'])['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[700],
                                child: Icon(Icons.shopping_bag, color: Colors.white, size: 25),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'FEATURED',
                                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _featuredProducts.firstWhere((p) => p['featured'])['name'],
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Text(
                                  '🪙',
                                  style: TextStyle(fontSize: 12),
                                ),
                                SizedBox(width: 2),
                                Text(
                                  '${_featuredProducts.firstWhere((p) => p['featured'])['tokens']}',
                                  style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


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
                        child: Icon(Icons.favorite, color: _isLiked ? Colors.red : Colors.white, size: 28),
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
      ),
    );
  }
}