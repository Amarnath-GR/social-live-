# Debug Guide: Liked Videos Not Showing

## Changes Made to Fix

### 1. Early Initialization (`lib/main.dart`)
- Initialize `LikedVideosService()` in main() before app starts
- Ensures saved data is loaded before any screen uses it

### 2. Debug Logging Added
- LikedVideosService: Logs when videos are saved/loaded
- Profile Screen: Logs when liked videos are displayed
- Video Feed: Logs when like/unlike buttons are pressed

## How to Test

### Step 1: Run the App
```bash
flutter run
```

### Step 2: Like a Video
1. Open the app
2. Go to the video feed (home screen)
3. **Double-tap** a video OR tap the **heart button**
4. Look for console output:
   ```
   ❤️ Double-tap like: video_0
   ✅ Liked video saved: video_0 - Total liked: 1
   ```

### Step 3: Check Profile
1. Navigate to **Profile** tab
2. Tap **Liked** tab
3. Look for console output:
   ```
   📂 Loading liked videos from storage...
   ✅ Loaded 1 liked videos
   📱 Profile loading 1 liked videos
   ✅ Profile liked tab updated with 1 videos
   ```
4. **You should see the liked video in the grid**

### Step 4: Test Persistence
1. Close the app completely
2. Reopen the app
3. Look for console output:
   ```
   📂 Loading liked videos from storage...
   ✅ Loaded 1 liked videos
   ```
4. Go to Profile → Liked tab
5. **Liked video should still be there**

## Troubleshooting

### If videos still don't show:

#### Check 1: Is the service loading?
Look for this in console when app starts:
```
📂 Loading liked videos from storage...
```

If you see:
```
ℹ️ No liked videos found in storage
```
Then no videos have been saved yet.

#### Check 2: Is the like being saved?
When you like a video, you should see:
```
❤️ Button like: video_0
✅ Liked video saved: video_0 - Total liked: 1
```

If you don't see this, the like button isn't working.

#### Check 3: Is the profile loading them?
When you open the Liked tab, you should see:
```
📱 Profile loading X liked videos
✅ Profile liked tab updated with X videos
```

If you see `Profile loading 0 liked videos`, the service has no data.

### Manual Test: Check SharedPreferences

Add this temporary code to check what's saved:

```dart
// In profile screen initState or anywhere
Future<void> _debugCheckStorage() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getString('liked_videos');
  debugPrint('🔍 Storage data: $data');
}
```

## Expected Console Output

### When Liking a Video:
```
❤️ Double-tap like: video_0
✅ Liked video saved: video_0 - Total liked: 1
```

### When Opening Profile Liked Tab:
```
📂 Loading liked videos from storage...
✅ Loaded 1 liked videos
📱 Profile loading 1 liked videos
✅ Profile liked tab updated with 1 videos
```

### When Unliking a Video:
```
💔 Unlike: video_0
```

## Common Issues

### Issue 1: Service not initialized
**Symptom**: No console logs at all
**Fix**: Ensure `LikedVideosService()` is called in main.dart

### Issue 2: Profile not listening to changes
**Symptom**: Videos liked but profile doesn't update
**Fix**: Profile screen already has listener in initState

### Issue 3: Data not persisting
**Symptom**: Videos disappear after app restart
**Fix**: Check if `_saveLikedVideos()` is being called

## Files Modified

1. `lib/main.dart` - Early service initialization
2. `lib/services/liked_videos_service.dart` - Debug logging
3. `lib/screens/enhanced_profile_screen.dart` - Debug logging
4. `lib/screens/simple_video_feed_screen.dart` - Debug logging

## Next Steps

1. Run the app with `flutter run`
2. Watch the console output
3. Like a video
4. Check if you see the success messages
5. Go to profile and check Liked tab
6. Share the console output if it still doesn't work
