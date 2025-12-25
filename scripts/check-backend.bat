@echo off
curl -s http://localhost:3000/api/v1 >nul 2>&1
if %errorlevel% neq 0 (
    start /B cmd /c "cd ..\social-live-mvp && npm run start:dev"
    timeout /t 8 /nobreak >nul
)
