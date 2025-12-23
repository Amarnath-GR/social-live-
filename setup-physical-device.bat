@echo off
echo ========================================
echo PHYSICAL DEVICE SETUP FOR FLUTTER APP
echo ========================================
echo.

echo [1/5] Getting current IP address...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do (
    for /f "tokens=1" %%b in ("%%a") do (
        set LOCAL_IP=%%b
        goto :found_ip
    )
)
:found_ip
echo Current IP: %LOCAL_IP%
echo.

echo [2/5] Adding Windows Firewall rules...
netsh advfirewall firewall delete rule name="Flutter Backend 2307" >nul 2>&1
netsh advfirewall firewall add rule name="Flutter Backend 2307" dir=in action=allow protocol=TCP localport=2307
echo Firewall rule added for port 2307
echo.

echo [3/5] Starting backend server...
cd social-live-mvp
start "Backend Server" cmd /k "npm start"
timeout /t 3 >nul
echo Backend server starting...
echo.

echo [4/5] Testing backend connection...
timeout /t 5 >nul
curl -s http://%LOCAL_IP%:2307/api/v1/health >nul 2>&1
if %errorlevel%==0 (
    echo ✓ Backend is accessible at http://%LOCAL_IP%:2307
) else (
    echo ✗ Backend connection failed - check if server is running
)
echo.

echo [5/5] Device connection instructions:
echo ========================================
echo 1. Connect your phone to the same WiFi network
echo 2. Your backend URL: http://%LOCAL_IP%:2307
echo 3. Make sure your phone can ping: %LOCAL_IP%
echo 4. Run: flutter run --release
echo ========================================
echo.

echo Backend should be accessible at: http://%LOCAL_IP%:2307/api/v1
echo Press any key to continue...
pause >nul