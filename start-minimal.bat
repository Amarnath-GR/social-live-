@echo off
echo 🔧 Starting minimal backend and Flutter app...

REM Kill any existing processes on port 3000
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :3000') do taskkill /f /pid %%a 2>nul

echo 🚀 Starting minimal backend server...
cd /d "C:\Users\Amarnath.G.Rathod\social-live-flutter-mvp"
start "Minimal Backend" cmd /k "node minimal-backend.js"

echo ⏳ Waiting for backend to start...
timeout /t 5 /nobreak > nul

echo 🌐 Starting Flutter app on Chrome...
cd /d "C:\Users\Amarnath.G.Rathod\social-live-flutter-mvp\social-live-flutter"
flutter run -d chrome --web-port 8081