@echo off
echo ========================================
echo STARTING FLUTTER APP FOR PHYSICAL DEVICE
echo ========================================
echo.
echo Backend URL: http://192.168.1.6:2307
echo Make sure:
echo 1. Your phone is connected to same WiFi
echo 2. Backend is running on port 2307
echo 3. Windows Firewall allows port 2307
echo.

echo Starting backend server...
cd social-live-mvp
start "Backend Server" cmd /k "npm start"
timeout /t 5 >nul

echo.
echo Starting Flutter app...
cd ..\social-live-flutter
flutter run --release

pause