@echo off
echo Starting backend for physical device testing...
echo IP: 192.168.1.6:2307
echo.

cd social-live-mvp
if exist package.json (
    echo Installing dependencies...
    npm install
    echo.
    echo Starting server...
    npm start
) else (
    echo Error: package.json not found in social-live-mvp directory
    echo Make sure you're in the correct directory
    pause
)