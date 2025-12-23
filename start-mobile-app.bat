@echo off
echo Starting Social Live App for Mobile Device...
echo Current IP: 192.168.1.6
echo Backend Port: 3000

echo.
echo 1. Starting Backend Server...
cd social-live-mvp
start "Backend Server" cmd /k "npm start"

echo.
echo 2. Waiting for backend to initialize...
timeout /t 15 /nobreak

echo.
echo 3. Starting Flutter App for Mobile...
cd ..\social-live-flutter
flutter run --release

echo.
echo ✅ Setup Complete!
echo 📱 Make sure your phone is connected via USB
echo 📡 Backend running at: http://192.168.1.6:3000/api/v1/health
echo 🔥 Add firewall rule manually: netsh advfirewall firewall add rule name="Flutter Backend 3000" dir=in action=allow protocol=TCP localport=3000
pause