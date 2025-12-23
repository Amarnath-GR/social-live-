@echo off
echo ========================================
echo   Social Live App Startup (Port 2307)
echo ========================================
echo.

:: Get current IP address
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do (
    for /f "tokens=1" %%b in ("%%a") do (
        set LOCAL_IP=%%b
        goto :found_ip
    )
)
:found_ip

echo Current Machine IP: %LOCAL_IP%
echo Backend Port: 2307
echo.

:: Check if Node.js is available
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

:: Check if Flutter is available
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/
    pause
    exit /b 1
)

echo ✅ Node.js and Flutter are available
echo.

:: Start backend server
echo 🚀 Starting Backend Server on port 2307...
echo Backend will be available at:
echo   - Local: http://localhost:2307/api/v1
echo   - Network: http://%LOCAL_IP%:2307/api/v1
echo   - Health: http://localhost:2307/api/v1/health
echo.

start "Backend Server" cmd /k "cd /d %~dp0 && node quick-backend.js"

:: Wait for backend to start
echo ⏳ Waiting for backend to start...
timeout /t 3 /nobreak >nul

:: Test backend connection
echo 🔍 Testing backend connection...
curl -s http://localhost:2307/api/v1/health >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Backend might still be starting up...
    timeout /t 2 /nobreak >nul
) else (
    echo ✅ Backend is responding
)

echo.
echo 📱 Starting Flutter App...
echo Flutter app will connect to: http://%LOCAL_IP%:2307/api/v1
echo.

:: Start Flutter app
cd /d "%~dp0social-live-flutter"
start "Flutter App" cmd /k "flutter run"

echo.
echo ========================================
echo   🎉 Both services are starting up!
echo ========================================
echo.
echo 📋 Demo Accounts:
echo   - Admin: admin@demo.com / Demo123!
echo   - User:  john@demo.com / Demo123!
echo.
echo 🔗 API Endpoints:
echo   - Health: http://localhost:2307/api/v1/health
echo   - Login:  http://localhost:2307/api/v1/auth/login
echo   - Wallet: http://localhost:2307/api/v1/wallet/balance
echo.
echo Press any key to close this window...
pause >nul