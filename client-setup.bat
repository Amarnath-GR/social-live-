@echo off
echo 🚀 Social Live MVP - Client Setup
echo.

echo Step 1: Setting up Backend Server...
cd social-live-mvp
call npm install
if errorlevel 1 (
    echo ❌ Backend setup failed
    pause
    exit /b 1
)

echo.
echo Step 2: Setting up Database...
call npm run db:generate
call npm run db:migrate
call npm run seed:demo
if errorlevel 1 (
    echo ❌ Database setup failed
    pause
    exit /b 1
)

echo.
echo Step 3: Setting up Flutter App...
cd ..\social-live-flutter
call flutter pub get
if errorlevel 1 (
    echo ❌ Flutter setup failed
    pause
    exit /b 1
)

echo.
echo ✅ Setup Complete!
echo.
echo 📋 Demo Accounts:
echo    Admin: admin@demo.com / Demo123!
echo    User:  john@demo.com / Demo123!
echo.
echo 🎯 To start demo:
echo    1. Run: start-backend.bat
echo    2. Run: start-flutter.bat
echo.
pause