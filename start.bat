@echo off
echo Starting Social Live Backend and Flutter App...
echo.

REM Start backend in a new window
echo [1/2] Starting NestJS Backend...
start "Social Live Backend" cmd /k "cd ..\social-live-mvp && npm run start:dev"

REM Wait for backend to initialize
echo [2/2] Waiting for backend to start (5 seconds)...
timeout /t 5 /nobreak > nul

REM Start Flutter app
echo Starting Flutter App...
flutter run

pause
