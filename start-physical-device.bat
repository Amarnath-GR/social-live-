@echo off
echo ========================================
echo Starting App on Physical Device V2307
echo ========================================
echo.

echo [1/4] Checking backend status...
netstat -an | findstr :2307 >nul
if %errorlevel% equ 0 (
    echo Backend is already running on port 2307
) else (
    echo Starting backend server...
    start /B node quick-backend.js
    timeout /t 3 /nobreak >nul
)

echo.
echo [2/4] Your machine IP: 172.29.212.108
echo Backend URL: http://172.29.212.108:2307/api/v1
echo.

echo [3/4] IMPORTANT: Firewall Configuration
echo If this is your first time, you need to allow port 2307 through Windows Firewall.
echo Right-click 'add-firewall-rule.bat' and select 'Run as administrator'
echo.
echo Press any key to continue after adding firewall rule...
pause >nul

echo.
echo [4/4] Starting Flutter app on V2307...
echo.
cd social-live-flutter
flutter run -d V2307

pause
