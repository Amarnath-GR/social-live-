@echo off
echo Starting backend...
cd social-live-mvp
start "Backend" cmd /c "npm start"
timeout /t 3
cd ..\social-live-flutter
echo Starting Flutter app on device V2307...
flutter run -d V2307