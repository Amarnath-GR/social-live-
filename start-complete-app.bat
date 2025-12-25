@echo off
echo 🚀 Starting Social Live MVP - Backend and Flutter App
echo.

REM Kill any existing processes on port 3000
echo 🔄 Cleaning up existing processes...
for /f "tokens=5" %%a in ('netstat -aon ^| find ":3000" ^| find "LISTENING"') do taskkill /f /pid %%a >nul 2>&1

echo 📦 Installing backend dependencies...
cd social-live-mvp
call npm install --legacy-peer-deps

echo 🗄️ Setting up database...
call npx prisma generate
call npx prisma db push

echo 🚀 Starting backend server...
start "Backend Server" cmd /k "npm run start:simple"

echo ⏳ Waiting for backend to start...
timeout /t 5 /nobreak >nul

echo 🔍 Testing backend connection...
cd ..
node test-backend-connection.js

echo.
echo 📱 Starting Flutter app...
cd social-live-flutter
start "Flutter App" cmd /k "flutter run"

echo.
echo ✅ Both backend and Flutter app are starting!
echo 📡 Backend: http://localhost:3000/api/v1
echo 📱 Flutter app will open in emulator/device
echo.
echo Press any key to stop all services...
pause >nul

echo 🛑 Stopping services...
taskkill /f /im node.exe >nul 2>&1
taskkill /f /im flutter.exe >nul 2>&1
echo ✅ All services stopped.