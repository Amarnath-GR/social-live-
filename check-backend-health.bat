@echo off
echo Checking backend server health...
echo.

REM Check if backend is running on port 3000
netstat -an | findstr :3000 > nul
if %errorlevel% == 0 (
    echo ✅ Backend server is running on port 3000
) else (
    echo ❌ Backend server is NOT running on port 3000
    echo.
    echo Starting backend server...
    cd social-live-mvp
    start "Backend Server" cmd /k "npm run start:dev"
    timeout /t 5 > nul
)

echo.
echo Testing API endpoints...

REM Test health endpoint
curl -s http://localhost:3000/api/v1 > nul
if %errorlevel% == 0 (
    echo ✅ API base endpoint is accessible
) else (
    echo ❌ API base endpoint is not accessible
)

REM Test specific endpoints
echo.
echo Testing specific endpoints:
curl -s -o nul -w "Users endpoint: %%{http_code}\n" http://localhost:3000/api/v1/users/me
curl -s -o nul -w "Wallet endpoint: %%{http_code}\n" http://localhost:3000/api/v1/wallet
curl -s -o nul -w "Marketplace orders endpoint: %%{http_code}\n" http://localhost:3000/api/v1/marketplace/orders

echo.
echo Health check complete!
pause