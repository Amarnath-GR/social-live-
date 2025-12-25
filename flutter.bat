@echo off
if "%1"=="run" (
    curl -s http://localhost:3000/api/v1 >nul 2>&1
    if %errorlevel% neq 0 (
        echo Starting backend...
        start /B cmd /c "cd ..\social-live-mvp && npm run start:dev"
        timeout /t 8 /nobreak >nul
    )
)
flutter %*
