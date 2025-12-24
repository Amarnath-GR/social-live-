import 'dart:io';
import 'package:flutter/material.dart';
import '../services/user_content_service.dart';

class PhotoPreviewScreen extends StatefulWidget {
  final String photoPath;
  
  PhotoPreviewScreen({required this.photoPath});
  
  @override
  _PhotoPreviewScreenState createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  final TextEditingController _captionController = TextEditingController();
  
  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
  
  void _postPhoto() {
    // Save to user content
    UserContentService().addPhoto(widget.photoPath);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Photo posted successfully!'),
        backgroundColor: Colors.purple,
        duration: Duration(seconds: 2),
      ),
    );
    
    // Go back to main screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  
  void _discardPhoto() {
    // Delete the photo file if it exists
    try {
      final file = File(widget.photoPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (e) {
      print('Error deleting photo: $e');
    }
    
    // Go back to camera
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Photo Preview
          Center(
            child: widget.photoPath.startsWith('photo_')
                ? Container(
                    color: Colors.grey[800],
                    child: Center(
                      child: Icon(
                        Icons.photo,
                        size: 100,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : Image.file(
                    File(widget.photoPath),
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
          ),
          
          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _discardPhoto,
                    icon: Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                  Text(
                    'Preview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 48), // Balance the close button
                ],
              ),
            ),
          ),
          
          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Caption Input
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _captionController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add a caption...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        icon: Icon(Icons.edit, color: Colors.purple, size: 20),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // Discard Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _discardPhoto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Discard',
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
                      
                      SizedBox(width: 16),
                      
                      // Post Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _postPhoto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Post Photo',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
