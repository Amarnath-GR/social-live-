@echo off
echo Starting Social Live MVP - Backend and Flutter App
echo.

REM Start backend server in a new window
echo Starting backend server...
start "Backend Server" cmd /k "cd /d social-live-mvp && npm start"

REM Wait a few seconds for backend to start
timeout /t 5 /nobreak >nul

REM Start Flutter app in a new window
echo Starting Flutter app...
start "Flutter App" cmd /k "cd /d social-live-flutter && flutter run"

echo.
echo Both services are starting...
echo Backend: http://localhost:3000
echo Flutter: Will open automatically
echo.
pause