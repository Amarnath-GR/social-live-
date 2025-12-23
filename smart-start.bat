@echo off
echo 🔍 Checking if backend is running on port 3000...

netstat -an | findstr :3000 > nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Backend is already running on port 3000
    echo 🚀 Starting Flutter app on Chrome...
    cd social-live-flutter
    flutter run -d chrome --web-port 8080
) else (
    echo ❌ Backend not running. Starting backend server first...
    
    REM Start backend in a new window
    cd social-live-mvp
    start "Social Live Backend" cmd /c "echo Starting backend... && npm run start:demo"
    cd ..
    
    echo ⏳ Waiting 15 seconds for backend to initialize...
    timeout /t 15 /nobreak > nul
    
    REM Verify backend started
    netstat -an | findstr :3000 > nul 2>&1
    if %errorlevel% == 0 (
        echo ✅ Backend started successfully
        echo 🚀 Now starting Flutter app on Chrome...
        cd social-live-flutter
        flutter run -d chrome --web-port 8080
    ) else (
        echo ❌ Backend failed to start. Please check the backend window for errors.
        pause
    )
)