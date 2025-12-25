@echo off
echo Starting backend server...
cd social-live-mvp
start "Backend Server" cmd /k "npm run start:dev"
timeout /t 5
echo Starting Flutter app...
cd ..\social-live-flutter
flutter run -d V2307