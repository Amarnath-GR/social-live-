@echo off
title Social Live App Launcher
color 0A

echo.
echo  ███████╗ ██████╗  ██████╗██╗ █████╗ ██╗         ██╗     ██╗██╗   ██╗███████╗
echo  ██╔════╝██╔═══██╗██╔════╝██║██╔══██╗██║         ██║     ██║██║   ██║██╔════╝
echo  ███████╗██║   ██║██║     ██║███████║██║         ██║     ██║██║   ██║█████╗  
echo  ╚════██║██║   ██║██║     ██║██╔══██║██║         ██║     ██║╚██╗ ██╔╝██╔══╝  
echo  ███████║╚██████╔╝╚██████╗██║██║  ██║███████╗    ███████╗██║ ╚████╔╝ ███████╗
echo  ╚══════╝ ╚═════╝  ╚═════╝╚═╝╚═╝  ╚═╝╚══════╝    ╚══════╝╚═╝  ╚═══╝  ╚══════╝
echo.
echo                           Starting your app...
echo.

:: Kill any existing backend processes
taskkill /f /im node.exe >nul 2>&1

:: Start backend in background
echo [1/3] Starting backend server...
cd social-live-mvp
start /min "Backend" cmd /c "npm run start:dev"
cd ..

:: Wait for backend to be ready
echo [2/3] Waiting for backend to initialize...
:check_backend
timeout /t 3 >nul
curl -s http://localhost:3000 >nul 2>&1
if %errorlevel% neq 0 goto check_backend

echo [3/3] Launching Flutter app...
cd social-live-flutter
flutter run

echo.
echo App closed. Press any key to exit...
pause >nul