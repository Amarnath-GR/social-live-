@echo off
setlocal enabledelayedexpansion

echo 🚀 Starting Social Live MVP - Synchronized Backend + Flutter
echo ================================================
echo.

REM Kill any existing processes
echo 🔄 Cleaning up existing processes...
for /f "tokens=5" %%a in ('netstat -aon ^| find ":3000" ^| find "LISTENING"') do (
    echo Killing process %%a on port 3000
    taskkill /f /pid %%a >nul 2>&1
)

REM Setup backend
echo 📦 Setting up backend...
cd social-live-mvp
call npm install --legacy-peer-deps --silent
if errorlevel 1 (
    echo ❌ Failed to install backend dependencies
    pause
    exit /b 1
)

echo 🗄️ Setting up database...
call npx prisma generate --silent
call npx prisma db push --silent

echo 🚀 Starting backend server...
start /min cmd /c "npm run start:simple > backend.log 2>&1"

echo ⏳ Waiting for backend to be ready...
set /a attempts=0
:wait_backend
set /a attempts+=1
if !attempts! gtr 30 (
    echo ❌ Backend failed to start after 30 attempts
    type backend.log
    pause
    exit /b 1
)

timeout /t 2 /nobreak >nul
curl -s http://localhost:3000/api/v1/health >nul 2>&1
if errorlevel 1 (
    echo Attempt !attempts!/30: Backend not ready yet...
    goto wait_backend
)

echo ✅ Backend server is ready!
echo 📡 Backend running at: http://localhost:3000/api/v1

REM Test backend connectivity
echo 🔍 Testing backend endpoints...
curl -s http://localhost:3000/api/v1/health
echo.
curl -s http://localhost:3000/api/v1/posts
echo.

cd ..

REM Start Flutter app
echo 📱 Starting Flutter app...
cd social-live-flutter

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter is not installed or not in PATH
    pause
    exit /b 1
)

echo 📦 Getting Flutter dependencies...
call flutter pub get

echo 🔧 Running Flutter app...
echo Backend is ready at http://localhost:3000/api/v1
echo Starting Flutter app now...
echo.

flutter run

echo.
echo 🛑 Flutter app closed. Stopping backend...
cd ..\social-live-mvp
taskkill /f /im node.exe >nul 2>&1
echo ✅ All services stopped.
pause