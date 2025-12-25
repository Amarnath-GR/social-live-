@echo off
cd /d "%~dp0"

echo Checking if backend is running...
curl -s http://localhost:3000/api/v1 >nul 2>&1
if %errorlevel% equ 0 (
    echo Backend already running!
) else (
    echo Starting backend server...
    start "Backend Server" cmd /k "cd backend && npm install && npm run dev"
    echo Waiting for backend to start...
    timeout /t 8 /nobreak >nul
)

echo Starting Flutter app...
flutter run
