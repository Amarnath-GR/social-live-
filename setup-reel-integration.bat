@echo off
echo Setting up Reel Integration and Camera Features...
echo.

cd social-live-flutter

echo Installing Flutter dependencies...
flutter pub get

echo.
echo Cleaning Flutter build...
flutter clean

echo.
echo Getting dependencies again...
flutter pub get

echo.
echo Running code generation (if needed)...
flutter packages pub run build_runner build --delete-conflicting-outputs

echo.
echo Setup complete!
echo.
echo Camera and Reel integration features added:
echo - Camera service for recording videos
echo - Reel camera screen with full controls
echo - Reel preview screen for editing
echo - Enhanced video feed with reel support
echo - Proper permissions for Android and iOS
echo.
echo To test:
echo 1. Run: flutter run
echo 2. Navigate to video upload or feed
echo 3. Tap the camera/record button
echo 4. Grant camera and microphone permissions
echo.
pause