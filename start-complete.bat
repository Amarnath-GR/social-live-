@echo off
echo 🚀 Starting Complete Social Live Platform

echo Starting Backend Server...
start "Backend" cmd /k "cd social-live-mvp && npm run start:dev"

timeout /t 5 /nobreak >nul

echo Starting Web Portal...
start "Web Portal" cmd /k "cd social-live-web && npm run dev"

timeout /t 3 /nobreak >nul

echo Starting Flutter App...
start "Flutter App" cmd /k "cd social-live-flutter && flutter run"

echo.
echo ✅ All services are starting...
echo.
echo 🔗 Access URLs:
echo Backend API: http://localhost:3000
echo Web Portal: http://localhost:3002
echo Flutter App: Will open automatically
echo.
pause