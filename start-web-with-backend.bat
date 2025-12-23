@echo off
echo Starting Social Live App with Backend for Web...

echo.
echo 1. Starting Backend Server...
cd social-live-mvp
start "Backend Server" cmd /k "npm start"

echo.
echo 2. Waiting for backend to start...
timeout /t 10 /nobreak

echo.
echo 3. Starting Flutter Web App on Chrome...
cd ..\social-live-flutter
start "Flutter Web" cmd /k "flutter run -d chrome --web-port 8080"

echo.
echo ✅ Both services starting...
echo 📡 Backend: http://localhost:3000/api/v1/health
echo 🌐 Flutter Web: http://localhost:8080
echo.
pause