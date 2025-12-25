# Profile Picture Edit Feature

## Overview
The profile edit screen now includes profile picture editing with native camera and gallery support.

## Features
- ✅ Profile picture display with circular avatar
- ✅ Camera capture for new profile pictures
- ✅ Gallery selection for existing photos
- ✅ Image optimization (800x800, 85% quality)
- ✅ Bottom sheet picker for source selection
- ✅ Visual feedback with purple camera button overlay

## Usage

### For Users
1. Navigate to Edit Profile screen
2. Tap the camera icon on the profile picture
3. Choose "Camera" or "Gallery" from the bottom sheet
4. Select/capture your new profile picture
5. Save to update your profile

### For Developers
```dart
// Navigate to edit profile with current data
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProfileEditScreen(
      currentUsername: 'username',
      currentBio: 'bio text',
      currentProfilePicture: 'https://example.com/profile.jpg',
    ),
  ),
).then((result) {
  if (result != null) {
    // result contains: username, bio, profileImage (File?)
    final username = result['username'];
    final bio = result['bio'];
    final profileImage = result['profileImage'] as File?;
  }
});
```

## Implementation Details

### Dependencies Used
- `image_picker: ^1.0.7` (already in pubspec.yaml)

### Permissions
All required permissions are already configured:

**Android** (AndroidManifest.xml):
- `CAMERA`
- `READ_MEDIA_IMAGES`
- `READ_EXTERNAL_STORAGE`

**iOS** (Info.plist):
- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`

### Image Optimization
- Max dimensions: 800x800 pixels
- Quality: 85%
- Reduces file size while maintaining quality

## UI Components

### Profile Picture Display
- Circular avatar (120px diameter)
- Shows selected image, network image, or placeholder icon
- Purple camera button overlay in bottom-right corner

### Image Source Picker
- Modal bottom sheet with rounded corners
- Two options: Camera and Gallery
- Purple accent color for consistency
- Dark theme matching app design

## Return Data
The screen returns a Map with:
- `username`: String
- `bio`: String
- `profileImage`: File? (null if not changed)

## Next Steps
To complete the integration:
1. Update profile service to handle image upload
2. Add multipart/form-data support in API client
3. Update backend endpoint to accept profile picture
4. Display updated profile picture in profile screen
