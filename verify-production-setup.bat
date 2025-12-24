@echo off
echo ========================================
echo Social Live - Production Verification
echo ========================================
echo.

echo Checking production setup...
echo.

cd social-live-mvp

echo [1/10] Checking Node.js installation...
where node >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo ✓ Node.js is installed
    node --version
) else (
    echo ✗ Node.js is NOT installed
    echo   Please install from https://nodejs.org/
)
echo.

echo [2/10] Checking npm installation...
where npm >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo ✓ npm is installed
    npm --version
) else (
    echo ✗ npm is NOT installed
)
echo.

echo [3/10] Checking dependencies...
if exist node_modules (
    echo ✓ Dependencies are installed
) else (
    echo ✗ Dependencies are NOT installed
    echo   Run: npm install
)
echo.

echo [4/10] Checking Prisma client...
if exist node_modules\.prisma (
    echo ✓ Prisma client is generated
) else (
    echo ✗ Prisma client is NOT generated
    echo   Run: npx prisma generate
)
echo.

echo [5/10] Checking environment configuration...
if exist .env (
    echo ✓ .env file exists
    echo   Checking required variables...
    findstr /C:"DATABASE_URL" .env >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo   ✓ DATABASE_URL is configured
    ) else (
        echo   ✗ DATABASE_URL is NOT configured
    )
    findstr /C:"AWS_ACCESS_KEY_ID" .env >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo   ✓ AWS credentials are configured
    ) else (
        echo   ⚠ AWS credentials are NOT configured
    )
    findstr /C:"STRIPE_SECRET_KEY" .env >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo   ✓ Stripe keys are configured
    ) else (
        echo   ⚠ Stripe keys are NOT configured
    )
) else (
    echo ✗ .env file does NOT exist
    echo   Copy .env.production.template to .env and configure it
)
echo.

echo [6/10] Checking database connection...
npx prisma db pull --force >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo ✓ Database connection successful
) else (
    echo ✗ Database connection FAILED
    echo   Check your DATABASE_URL in .env
)
echo.

echo [7/10] Checking production seed files...
if exist src\seed\production-seed.ts (
    echo ✓ Production seed file exists
) else (
    echo ✗ Production seed file is MISSING
)
echo.

echo [8/10] Checking production services...
if exist src\video\production-video.service.ts (
    echo ✓ Production video service exists
) else (
    echo ✗ Production video service is MISSING
)
if exist src\payments\production-payment.service.ts (
    echo ✓ Production payment service exists
) else (
    echo ✗ Production payment service is MISSING
)
echo.

echo [9/10] Checking build...
if exist dist (
    echo ✓ Application is built
) else (
    echo ⚠ Application is NOT built
    echo   Run: npm run build
)
echo.

echo [10/10] Testing API health (if running)...
curl -s http://localhost:3000/health >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo ✓ API is running and healthy
) else (
    echo ⚠ API is NOT running
    echo   Start with: npm run start:dev
)
echo.

cd ..

echo ========================================
echo Verification Complete
echo ========================================
echo.

echo Summary:
echo - Check the results above
echo - Fix any issues marked with ✗
echo - Configure items marked with ⚠
echo.

echo Next Steps:
echo 1. Configure .env file with production values
echo 2. Run: npm run seed:production
echo 3. Run: npm run start:dev
echo 4. Test the application
echo 5. Follow PRODUCTION_DEPLOYMENT_GUIDE.md for deployment
echo.

echo Documentation:
echo - PRODUCTION_READY_SUMMARY.md - Overview and quick start
echo - PRODUCTION_DEPLOYMENT_GUIDE.md - Detailed deployment steps
echo - PRODUCTION_CHECKLIST.md - Pre-launch checklist
echo.

pause
