import 'package:flutter/material.dart';

class VideoDescriptionScreen extends StatefulWidget {
  final String videoPath;
  final int videoDuration;

  VideoDescriptionScreen({
    required this.videoPath,
    required this.videoDuration,
  });

  @override
  _VideoDescriptionScreenState createState() => _VideoDescriptionScreenState();
}

class _VideoDescriptionScreenState extends State<VideoDescriptionScreen> {
  final TextEditingController _captionController = TextEditingController();
  String _selectedVisibility = 'Public';
  bool _allowComments = true;
  bool _allowDuet = true;
  bool _allowStitch = true;
  bool _isUploading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text('Post', style: TextStyle(color: Colors.white)),
        actions: [
          if (_isUploading)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _postVideo,
              child: Text(
                'Post',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video preview thumbnail
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Video Duration',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                          Text(
                            '${widget.videoDuration}s',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Caption input
              Text(
                'Caption',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _captionController,
                style: TextStyle(color: Colors.white),
                maxLines: 4,
                maxLength: 150,
                decoration: InputDecoration(
                  hintText: 'Add a caption... #hashtags @mentions',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  counterStyle: TextStyle(color: Colors.grey[600]),
                ),
              ),
              SizedBox(height: 24),

              // Visibility
              _buildSettingTile(
                icon: Icons.public,
                title: 'Who can view this video',
                value: _selectedVisibility,
                onTap: _showVisibilityOptions,
              ),
              SizedBox(height: 16),

              // Allow comments
              _buildSwitchTile(
                icon: Icons.comment,
                title: 'Allow comments',
                value: _allowComments,
                onChanged: (value) {
                  setState(() {
                    _allowComments = value;
                  });
                },
              ),
              SizedBox(height: 16),

              // Allow duet
              _buildSwitchTile(
                icon: Icons.people,
                title: 'Allow Duet',
                value: _allowDuet,
                onChanged: (value) {
                  setState(() {
                    _allowDuet = value;
                  });
                },
              ),
              SizedBox(height: 16),

              // Allow stitch
              _buildSwitchTile(
                icon: Icons.cut,
                title: 'Allow Stitch',
                value: _allowStitch,
                onChanged: (value) {
                  setState(() {
                    _allowStitch = value;
                  });
                },
              ),
              SizedBox(height: 32),

              // Additional options
              Text(
                'More Options',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              _buildOptionTile(
                icon: Icons.music_note,
                title: 'Add sound',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Add sound feature')),
                  );
                },
              ),
              _buildOptionTile(
                icon: Icons.location_on,
                title: 'Add location',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Add location feature')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            Text(
              value,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showVisibilityOptions() {
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
              'Who can view this video',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildVisibilityOption('Public', 'Everyone can watch your video'),
            _buildVisibilityOption('Friends', 'Only friends can watch'),
            _buildVisibilityOption('Private', 'Only you can watch'),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityOption(String title, String subtitle) {
    final isSelected = _selectedVisibility == title;
    return ListTile(
      onTap: () {
        setState(() {
          _selectedVisibility = title;
        });
        Navigator.pop(context);
      },
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? Colors.purple : Colors.grey[400],
      ),
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
    );
  }

  void _postVideo() async {
    setState(() {
      _isUploading = true;
    });

    // Simulate upload
    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      // Navigate back to home without showing any popup
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
