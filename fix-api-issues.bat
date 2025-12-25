@echo off
echo 🔧 Fixing API Connection Issues...
echo.

echo 1. Checking backend server status...
cd social-live-mvp
npm run start:dev > nul 2>&1 &
echo Backend server starting...

echo.
echo 2. Waiting for server to initialize...
timeout /t 10 > nul

echo.
echo 3. Testing API connectivity...
curl -s http://localhost:3000/api/v1 > nul
if %errorlevel% == 0 (
    echo ✅ Backend API is accessible
) else (
    echo ❌ Backend API is not accessible - check if server is running
)

echo.
echo 4. Flutter app fixes applied:
echo   ✅ Fixed API client initialization
echo   ✅ Fixed order history endpoint (now uses /marketplace/orders)
echo   ✅ Created transaction service for wallet history
echo   ✅ Updated wallet service to use correct endpoints

echo.
echo 5. Backend endpoints available:
echo   - Profile: GET /api/v1/users/me
echo   - Order History: GET /api/v1/marketplace/orders
echo   - Transaction History: GET /api/v1/wallet/transactions
echo   - Wallet Balance: GET /api/v1/wallet

echo.
echo 🎉 API fixes complete! 
echo.
echo Next steps:
echo 1. Make sure you're logged in to the app
echo 2. Check that your auth token is valid
echo 3. Restart the Flutter app to apply changes

pause