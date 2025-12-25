import 'package:flutter/material.dart';
import 'simple_video_feed_screen.dart';
import 'simple_profile_screen.dart';
import 'simple_wallet_screen.dart';
import 'simple_marketplace_screen.dart';
import 'enhanced_simple_camera_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});
  
  @override
  _MainAppScreenState createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;
  final GlobalKey<SimpleVideoFeedScreenState> _videoFeedKey = GlobalKey();
  
  List<Widget> get _screens => [
    SimpleVideoFeedScreen(key: _videoFeedKey), // Index 0 - Home
    SimpleMarketplaceScreen(), // Index 1 - Discover/Shop
    Container(), // Index 2 - Placeholder (camera opens directly)
    SimpleWalletScreen(), // Index 3 - Wallet
    SimpleProfileScreen(), // Index 4 - Profile
  ];

  void _onNavItemTapped(int index) {
    // Skip camera tab (index 2) since it opens directly
    if (index == 2) return;
    
    // Pause videos when leaving home screen
    if (_currentIndex == 0 && index != 0) {
      _videoFeedKey.currentState?.pauseVideos();
    }
    // Resume videos when returning to home screen
    if (index == 0 && _currentIndex != 0) {
      _videoFeedKey.currentState?.resumeVideos();
    }
    
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        // If not on home screen, go back to home instead of closing app
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return;
        }
        // If on home screen, show exit confirmation
        final shouldExit = await _showExitConfirmation(context);
        if (shouldExit && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        floatingActionButton: null,
        bottomNavigationBar: SafeArea(
          child: _buildBottomNavigationBar(),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Exit App?', style: TextStyle(color: Colors.white)),
        content: Text('Do you want to exit the app?', style: TextStyle(color: Colors.grey[400])),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Exit', style: TextStyle(color: Colors.purple[300])),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.purple[800]!, width: 0.5),
        ),
      ),
      padding: EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.shopping_bag,
            label: 'Shop',
            index: 1,
          ),
          _buildCameraButton(),
          _buildNavItem(
            icon: Icons.account_balance_wallet,
            label: 'Wallet',
            index: 3,
          ),
          _buildNavItem(
            icon: Icons.person,
            label: 'Profile',
            index: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    bool isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.purple[300] : Colors.grey[600],
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.purple[300] : Colors.grey[600],
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton() {
    bool isActive = _currentIndex == 2;
    
    return GestureDetector(
      onTap: () {
        print('Camera button tapped'); // Debug print
        // Always pause videos when opening camera, regardless of current screen
        _videoFeedKey.currentState?.pauseVideos();
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnhancedSimpleCameraScreen(),
          ),
        ).then((_) {
          // Resume videos only if we're back on the home screen
          if (_currentIndex == 0) {
            _videoFeedKey.currentState?.resumeVideos();
          }
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: isActive 
                  ? [Colors.purple, Colors.deepPurple]
                  : [Colors.grey[700]!, Colors.grey[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: isActive 
                ? Border.all(color: Colors.purple[300]!, width: 2)
                : null,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 2,
                  top: 2,
                  child: Container(
                    width: 18,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.purple[200] : Colors.grey[500],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 18,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.deepPurple[300] : Colors.grey[400],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Create',
            style: TextStyle(
              color: isActive ? Colors.purple[300] : Colors.grey[600],
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
