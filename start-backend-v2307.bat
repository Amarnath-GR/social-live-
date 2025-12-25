@echo off
echo ========================================
echo   Backend Server Startup (Port 2307)
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

echo 🚀 Starting Backend Server on port 2307...
echo.
echo 📡 Server will be available at:
echo   - Local access:     http://localhost:2307/api/v1
echo   - Network access:   http://%LOCAL_IP%:2307/api/v1
echo   - Health check:     http://localhost:2307/api/v1/health
echo.
echo 📋 Demo Accounts:
echo   - Admin: admin@demo.com / Demo123!
echo   - User:  john@demo.com / Demo123!
echo.
echo 🔧 For Flutter app, use IP: %LOCAL_IP%
echo.

:: Check if Node.js is available
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js is not installed or not in PATH
    pause
    exit /b 1
)

:: Start the server
node quick-backend.js

pause