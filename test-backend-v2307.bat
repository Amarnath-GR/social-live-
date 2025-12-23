@echo off
echo ========================================
echo   Testing Backend Connection (Port 2307)
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

echo Testing connection to backend on port 2307...
echo Local IP: %LOCAL_IP%
echo.

:: Test health endpoint
echo 🔍 Testing health endpoint...
curl -s http://localhost:2307/api/v1/health
if errorlevel 1 (
    echo ❌ Health check failed - Backend may not be running
    echo.
    echo To start backend, run: start-backend-v2307.bat
) else (
    echo ✅ Health check passed
)

echo.
echo 🔍 Testing login endpoint...
curl -s -X POST http://localhost:2307/api/v1/auth/login -H "Content-Type: application/json" -d "{\"email\":\"john@demo.com\",\"password\":\"Demo123!\"}"
if errorlevel 1 (
    echo ❌ Login test failed
) else (
    echo ✅ Login test passed
)

echo.
echo ========================================
echo   Connection Test Complete
echo ========================================
echo.
echo If tests passed, your Flutter app should connect to:
echo http://%LOCAL_IP%:2307/api/v1
echo.
pause