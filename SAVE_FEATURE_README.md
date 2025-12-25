# Save Feature - Instagram Style

## 🎯 Overview
Added Instagram-style save functionality to reels and profile, allowing users to bookmark videos for later viewing.

## ✨ Features Implemented

### 1. **Save Button in Video Feed**
- **Location**: Right side action buttons (below comments, above share)
- **Icon**: Bookmark icon (filled when saved, outline when not saved)
- **Color**: Yellow when saved, white when not saved
- **Label**: "Save"
- **Feedback**: Toast notification on save/unsave

### 2. **Saved Tab in Profile**
- **Location**: Profile screen tabs (Feed | Videos | Saved)
- **Icon**: Bookmark icon
- **Grid Layout**: 3 columns, similar to Feed and Videos tabs
- **Empty State**: Shows bookmark icon with message "No saved videos yet"

### 3. **Saved Videos Service**
- **File**: `lib/services/saved_videos_service.dart`
- **Storage**: SharedPreferences (persistent across app restarts)
- **Data Stored**: Video ID, URL, title, creator, saved timestamp

## 🎨 UI Elements

### Video Feed Save Button:
```dart
_buildActionButton(
  icon: SavedVideosService().isSaved(video.id) ? Icons.bookmark : Icons.bookmark_border,
  color: SavedVideosService().isSaved(video.id) ? Colors.yellow : Colors.white,
  label: 'Save',
  onTap: () { /* Save/Unsave logic */ },
)
```

### Profile Saved Tab:
- **3 Tabs**: Feed, Videos, Saved
- **Grid View**: 3x3 grid with video thumbnails
- **Bookmark Badge**: Yellow bookmark icon on saved videos
- **Creator Name**: Displayed at bottom of each thumbnail

## 📱 User Flow

### Saving a Video:
1. User watches video in feed
2. Taps bookmark button on right side
3. Icon turns yellow and fills
4. Toast shows "Saved to collection"
5. Video appears in Profile → Saved tab

### Unsaving a Video:
1. User taps filled bookmark button
2. Icon turns white and becomes outline
3. Toast shows "Removed from saved"
4. Video removed from Saved tab

### Viewing Saved Videos:
1. Navigate to Profile
2. Tap "Saved" tab
3. View grid of all saved videos
4. Tap video to play

## 🔧 Technical Details

### SavedVideosService Methods:
- `loadSavedVideos()` - Load saved videos from storage
- `saveVideo(id, url, title, creator)` - Save a video
- `unsaveVideo(id)` - Remove a saved video
- `isSaved(id)` - Check if video is saved
- `savedVideos` - Get list of all saved videos

### Data Structure:
```dart
{
  'id': 'video_1',
  'videoUrl': 'https://...',
  'title': 'Video Title',
  'creator': 'Creator Name',
  'savedAt': '2024-01-01T12:00:00.000Z'
}
```

## 🎯 Features

### Video Feed:
- ✅ Save button with bookmark icon
- ✅ Visual feedback (yellow when saved)
- ✅ Toast notifications
- ✅ Persistent state across videos

### Profile:
- ✅ Saved tab (3rd tab)
- ✅ Grid layout matching other tabs
- ✅ Empty state with icon and message
- ✅ Bookmark badge on thumbnails
- ✅ Creator name display

### Service:
- ✅ Persistent storage (SharedPreferences)
- ✅ Singleton pattern
- ✅ JSON serialization
- ✅ Timestamp tracking

## 🎨 Design Consistency

### Colors:
- **Saved Icon**: Yellow (#FFEB3B)
- **Unsaved Icon**: White
- **Background**: Black/Dark Grey
- **Toast**: Purple (save), Grey (unsave)

### Icons:
- **Saved**: `Icons.bookmark` (filled)
- **Unsaved**: `Icons.bookmark_border` (outline)
- **Empty State**: `Icons.bookmark_border` (large)

## 📊 Storage

### Location:
- SharedPreferences key: `'saved_videos'`
- Format: JSON array
- Persistence: Survives app restarts

### Example Storage:
```json
[
  {
    "id": "video_1",
    "videoUrl": "https://...",
    "title": "Amazing Video",
    "creator": "Creator 1",
    "savedAt": "2024-01-01T12:00:00.000Z"
  }
]
```

## 🚀 Usage

### Save a Video:
```dart
SavedVideosService().saveVideo(
  video.id,
  video.videoUrl,
  video.title,
  video.creator,
);
```

### Check if Saved:
```dart
bool isSaved = SavedVideosService().isSaved(video.id);
```

### Get All Saved:
```dart
List<Map<String, dynamic>> saved = SavedVideosService().savedVideos;
```

---

**Note**: This implementation uses local storage. For production, consider syncing with backend API.
