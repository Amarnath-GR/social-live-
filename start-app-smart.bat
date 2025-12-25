@echo off
echo 🔍 Checking backend status...

REM Check if backend is running on port 3000
netstat -an | findstr :3000 > nul
if %errorlevel% == 0 (
    echo ✅ Backend is already running
    goto start_app
) else (
    echo ❌ Backend not running, starting backend server...
    cd social-live-mvp
    start "Backend Server" cmd /k "npm run start:demo"
    cd ..
    echo ⏳ Waiting for backend to start...
    timeout /t 10 > nul
)

:start_app
echo 🚀 Starting Flutter app on Chrome...
cd social-live-flutter
flutter run -d chrome --web-port 8080