@echo off
curl -s http://localhost:3000 >nul 2>&1
if %errorlevel% neq 0 (
    cd social-live-mvp
    start /min cmd /c "npm run start:dev"
    cd ..
    timeout /t 5
)
cd social-live-flutter
flutter run