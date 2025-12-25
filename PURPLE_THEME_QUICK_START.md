# Purple Theme Quick Start Guide

## What's New

Your TikTok-style social media app now has:

1. **Purple Theme** - All UI elements use purple instead of red
2. **Smart Video Control** - Videos only play on Home tab, pause on other tabs
3. **Pull-to-Refresh Profile** - Swipe down to refresh your profile stats
4. **Fully Functional Camera** - Real camera with Photo/Video/Live modes
5. **Enhanced Create Button** - Access Photo, Video, and Live streaming

## How to Run

```bash
cd social-live-flutter
flutter pub get
flutter run
```

## Key Features to Test

### 1. Purple Theme
- Open the app - notice purple accents everywhere
- Tap navigation items - active items show in purple
- Open camera - recording progress is purple
- Check profile - buttons are purple

### 2. Video Pause/Play
- Go to Home tab - videos play automatically
- Tap Wallet tab - videos pause
- Return to Home - videos resume playing
- Try all tabs - videos only play on Home

### 3. Pull-to-Refresh Profile
- Go to Profile tab
- Swipe down from the top
- See purple loading indicator
- Stats update (followers +10, likes +100)
- See "Profile refreshed!" message

### 4. Camera Modes
- Tap Create (+) button
- See 3 dots at bottom (Photo/Video/Live)
- Tap left dot - Photo mode
- Tap middle dot - Video mode  
- Tap right dot - Live mode
- Active mode shows purple dot

### 5. Camera Features
- **Flash**: Tap flash icon (turns purple when on)
- **Switch Camera**: Tap flip icon to switch front/back
- **Effects**: Tap effects icon for filters
- **Speed**: Tap speed icon for 0.5x, 1x, 2x, 3x
- **Timer**: Tap timer icon for countdown
- **Music**: Tap music icon to add songs

### 6. Recording Flow
- Select Video mode (middle dot)
- Tap record button (white circle)
- Button turns purple and square while recording
- Purple progress bar shows at top
- Tap again to stop
- Automatically goes to description screen
- Fill in caption and tap "Post"
- Silently uploads and returns to Home

### 7. Photo Capture
- Select Photo mode (left dot)
- Tap capture button
- See "Photo captured" message
- Photo saved to device

### 8. Live Streaming
- Select Live mode (right dot)
- Tap button to start
- Opens live streaming screen

## Navigation Behavior

| Tab | Videos Play? | Description |
|-----|-------------|-------------|
| Home | ✅ Yes | Videos auto-play and auto-scroll |
| Discover | ❌ No | Videos paused |
| Create | ❌ No | Camera screen |
| Wallet | ❌ No | Videos paused |
| Profile | ❌ No | Videos paused |

## Purple Theme Elements

- ✅ Navigation bar active state
- ✅ Create button gradient
- ✅ Camera recording progress
- ✅ Flash indicator
- ✅ Mode indicators
- ✅ Profile buttons
- ✅ Tab indicators
- ✅ Loading spinners
- ✅ Snackbar backgrounds
- ✅ Action buttons
- ✅ Icons when active

## Troubleshooting

### Camera Not Working?
- Check camera permissions in device settings
- Restart the app
- App will fallback to mock camera if real camera unavailable

### Videos Not Pausing?
- Make sure you're using `main_simple.dart` as entry point
- Check that you're navigating between tabs
- Videos should pause immediately when leaving Home

### Pull-to-Refresh Not Working?
- Make sure you're on Profile tab
- Swipe down from the top of the screen
- Should see purple loading indicator

## File Structure

```
social-live-flutter/lib/
├── main_simple.dart (Entry point - purple theme)
├── screens/
│   ├── main_app_screen_purple.dart (Main navigation with video control)
│   ├── enhanced_simple_camera_screen.dart (Functional camera)
│   ├── simple_profile_screen_purple.dart (Profile with pull-to-refresh)
│   ├── simple_video_feed_screen.dart (Video feed)
│   ├── video_description_screen.dart (Post screen)
│   └── ... (other screens)
```

## Next Steps

1. Test all camera features
2. Verify video pause/play on navigation
3. Try pull-to-refresh on profile
4. Check purple theme throughout app
5. Test on physical device for best camera experience

## Notes

- Camera works best on physical device
- Emulator may have limited camera functionality
- All features maintain TikTok-style UX
- No instructional text or unnecessary popups
- Clean, production-ready interface
