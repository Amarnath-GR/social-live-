@echo off
echo ========================================
echo   Social Live Backend Quick Start
echo ========================================
echo.

echo Step 1: Starting backend server...
start "Backend Server" cmd /k "node quick-backend.js"

echo Waiting for server to start...
timeout /t 3 /nobreak > nul

echo.
echo Step 2: Testing backend connection...
node test-backend.js

echo.
echo ========================================
echo Backend should now be running on:
echo http://localhost:3000/api/v1/health
echo ========================================
echo.
echo Next steps:
echo 1. Keep this backend window open
echo 2. Run 'flutter run' in social-live-flutter folder
echo 3. Use demo accounts:
echo    - admin@demo.com / Demo123!
echo    - john@demo.com / Demo123!
echo.
pause