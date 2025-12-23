@echo off
echo Starting Flutter app for physical device...
echo Backend URL: http://192.168.1.6:2307
echo.

cd social-live-flutter

echo Checking connected devices...
flutter devices
echo.

echo Building and running on physical device...
flutter run --release

pause