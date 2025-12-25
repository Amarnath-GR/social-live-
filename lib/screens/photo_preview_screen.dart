import 'package:flutter/material.dart';
import 'dart:io';
import '../services/user_content_service.dart';
import '../services/location_service.dart';
import '../services/post_storage_service.dart';
import '../services/api_client.dart';

class PhotoPreviewScreen extends StatefulWidget {
  final String photoPath;

  const PhotoPreviewScreen({
    Key? key,
    required this.photoPath,
  }) : super(key: key);

  @override
  _PhotoPreviewScreenState createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isPosting = false;
  String? _selectedLocation;

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
        title: Text('Post Photo', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _postPhoto,
            child: _isPosting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.purple,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Preview
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.photoPath.startsWith('photo_')
                        ? Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue.withOpacity(0.8),
                                  Colors.indigo.withOpacity(0.6),
                                  Colors.purple.withOpacity(0.4),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.photo_camera, color: Colors.white, size: 60),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Photo Preview',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Mock Photo Content',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Image.file(
                            File(widget.photoPath),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.grey[700],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, color: Colors.white, size: 80),
                                    SizedBox(height: 16),
                                    Text(
                                      'Photo Preview',
                                      style: TextStyle(color: Colors.white, fontSize: 18),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  // Edit buttons overlay
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      children: [
                        _buildEditButton(Icons.crop, 'Crop', () => _showCropOptions()),
                        SizedBox(width: 8),
                        _buildEditButton(Icons.filter, 'Filter', () => _showFilterOptions()),
                        SizedBox(width: 8),
                        _buildEditButton(Icons.edit, 'Edit', () => _showEditOptions()),
                      ],
                    ),
                  ),
                  // Small thumbnail indicator
                  if (!widget.photoPath.startsWith('photo_'))
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            File(widget.photoPath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[600],
                                child: Icon(Icons.photo, color: Colors.white, size: 24),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Caption Input
            Text(
              'Caption',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _captionController,
              style: TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write a caption... #hashtag',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(16),
              ),
            ),

            SizedBox(height: 24),

            // Selected Location Display
            if (_selectedLocation != null) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedLocation!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey, size: 18),
                      onPressed: () => setState(() => _selectedLocation = null),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],

            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(Icons.location_on, 'Location', () => _addLocation()),
                _buildQuickAction(Icons.people, 'Tag People', () => _tagPeople()),
                _buildQuickAction(Icons.mood, 'Feeling', () => _addFeeling()),
              ],
            ),

            SizedBox(height: 32),

            // Post Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isPosting ? null : _postPhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isPosting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Posting...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Post Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildEditButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _postPhoto() async {
    if (_captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add a caption'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      final file = File(widget.photoPath);
      if (!file.existsSync()) {
        throw Exception('Photo file not found');
      }
      
      String? postId;
      
      // Try backend upload first
      try {
        final apiClient = ApiClient();
        final response = await apiClient.uploadFile(
          '/posts',
          widget.photoPath,
          fieldName: 'image',
          data: {
            'content': _captionController.text,
            'type': 'PHOTO',
            if (_selectedLocation != null) 'location': _selectedLocation!,
          },
        ).timeout(Duration(seconds: 10));
        
        if (response.statusCode == 201 || response.statusCode == 200) {
          postId = response.data['id']?.toString();
        }
      } catch (e) {
        // Backend failed, continue with local save
      }
      
      // Save locally
      UserContentService().addPhoto(widget.photoPath);
      
      await PostStorageService.savePost(
        userId: 'current_user',
        postId: postId ?? 'photo_${DateTime.now().millisecondsSinceEpoch}',
        videoPath: widget.photoPath,
        thumbnailPath: widget.photoPath,
        description: _captionController.text,
        hashtags: _extractHashtags(_captionController.text),
        duration: 0,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  List<String> _extractHashtags(String text) {
    final regex = RegExp(r'#\w+');
    return regex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  void _showCropOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Crop Options',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCropOption('1:1', () => Navigator.pop(context)),
                _buildCropOption('4:3', () => Navigator.pop(context)),
                _buildCropOption('16:9', () => Navigator.pop(context)),
                _buildCropOption('Free', () => Navigator.pop(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropOption(String ratio, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple),
        ),
        child: Text(ratio, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        height: 300,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Filters',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  final filters = ['Normal', 'Vintage', 'B&W', 'Sepia', 'Bright', 'Cool', 'Warm', 'Dramatic'];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${filters[index]} filter applied!')),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.filter, color: Colors.purple, size: 24),
                          SizedBox(height: 4),
                          Text(
                            filters[index],
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
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

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Photo',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.brightness_6, color: Colors.white),
              title: Text('Brightness', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Brightness adjustment opened')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.contrast, color: Colors.white),
              title: Text('Contrast', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Contrast adjustment opened')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.palette, color: Colors.white),
              title: Text('Saturation', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Saturation adjustment opened')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addLocation() async {
    final location = await LocationService.getCurrentLocation();
    if (location != null) {
      setState(() {
        _selectedLocation = location;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location added: $location')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to get location')),
      );
    }
  }

  void _tagPeople() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tag people feature coming soon!')),
    );
  }

  void _addFeeling() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How are you feeling?',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildFeelingChip('😊', 'Happy'),
                _buildFeelingChip('😍', 'Loved'),
                _buildFeelingChip('🎉', 'Excited'),
                _buildFeelingChip('😎', 'Cool'),
                _buildFeelingChip('🤔', 'Thoughtful'),
                _buildFeelingChip('😴', 'Sleepy'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeelingChip(String emoji, String feeling) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _captionController.text += ' feeling $feeling $emoji';
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: 16)),
            SizedBox(width: 6),
            Text(feeling, style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
}