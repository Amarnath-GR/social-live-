@echo off
title Social Live App Launcher
color 0A

echo ========================================
echo    Social Live App Professional Setup
echo ========================================
echo.
echo Current IP: 192.168.1.6
echo Backend Port: 3000
echo.

echo [1/4] Starting Backend Server...
cd social-live-mvp
start "Backend Server - Port 3000" cmd /k "echo Backend Starting... && npm start"
echo ✓ Backend server starting in new window

echo.
echo [2/4] Waiting for backend initialization...
timeout /t 8 /nobreak > nul

echo.
echo [3/4] Adding firewall rule (if needed)...
netsh advfirewall firewall delete rule name="Flutter Backend 3000" > nul 2>&1
netsh advfirewall firewall add rule name="Flutter Backend 3000" dir=in action=allow protocol=TCP localport=3000 > nul 2>&1
if %errorlevel%==0 (
    echo ✓ Firewall rule added successfully
) else (
    echo ! Run as Administrator to add firewall rule
)

echo.
echo [4/4] Choose your platform:
echo 1. Chrome Web App
echo 2. Android Mobile App  
echo 3. Both (Web + Mobile)
echo.
set /p choice="Enter choice (1-3): "

cd ..\social-live-flutter

if "%choice%"=="1" (
    echo Starting Flutter Web App on Chrome...
    start "Flutter Web - Chrome" cmd /k "flutter run -d chrome --web-port 8080"
) else if "%choice%"=="2" (
    echo Starting Flutter Mobile App...
    start "Flutter Mobile - V2307" cmd /k "flutter run -d V2307 --release"
) else if "%choice%"=="3" (
    echo Starting both Web and Mobile apps...
    start "Flutter Web - Chrome" cmd /k "flutter run -d chrome --web-port 8080"
    timeout /t 3 /nobreak > nul
    start "Flutter Mobile - V2307" cmd /k "flutter run -d V2307 --release"
) else (
    echo Invalid choice. Starting Web app by default...
    start "Flutter Web - Chrome" cmd /k "flutter run -d chrome --web-port 8080"
)

echo.
echo ========================================
echo           Setup Complete!
echo ========================================
echo Backend Health: http://localhost:3000/api/v1/health
echo Web App: http://localhost:8080
echo Mobile: Connected to V2307 device
echo.
echo Press any key to exit launcher...
pause > nul