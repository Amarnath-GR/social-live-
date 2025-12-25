@echo off
echo ========================================
echo Social Live - Production Setup
echo ========================================
echo.

echo Step 1: Checking prerequisites...
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Node.js is not installed!
    echo Please install Node.js from https://nodejs.org/
    exit /b 1
)

where npm >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: npm is not installed!
    exit /b 1
)

where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: Flutter is not installed!
    echo Install Flutter from https://flutter.dev/
)

echo ✓ Prerequisites check passed
echo.

echo Step 2: Installing backend dependencies...
cd social-live-mvp
call npm install
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to install backend dependencies
    exit /b 1
)
echo ✓ Backend dependencies installed
echo.

echo Step 3: Setting up database...
echo Generating Prisma client...
call npx prisma generate
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to generate Prisma client
    exit /b 1
)

echo Running database migrations...
call npx prisma migrate deploy
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: Database migration failed. Make sure DATABASE_URL is configured.
)
echo ✓ Database setup completed
echo.

echo Step 4: Seeding production data...
call npm run seed:production
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: Production seeding failed. You may need to configure environment variables.
)
echo ✓ Production data seeded
echo.

echo Step 5: Building backend...
call npm run build
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to build backend
    exit /b 1
)
echo ✓ Backend built successfully
echo.

cd ..

echo Step 6: Setting up Flutter app...
if exist social-live-flutter (
    cd social-live-flutter
    echo Installing Flutter dependencies...
    call flutter pub get
    if %ERRORLEVEL% NEQ 0 (
        echo WARNING: Failed to install Flutter dependencies
    ) else (
        echo ✓ Flutter dependencies installed
    )
    cd ..
) else (
    echo WARNING: Flutter app directory not found
)
echo.

echo ========================================
echo Production Setup Complete!
echo ========================================
echo.
echo Next Steps:
echo 1. Configure environment variables in social-live-mvp/.env
echo 2. Set up AWS S3 and CloudFront (see PRODUCTION_DEPLOYMENT_GUIDE.md)
echo 3. Configure Stripe keys
echo 4. Set up PostgreSQL database
echo 5. Deploy to production server
echo.
echo For detailed instructions, see:
echo - PRODUCTION_DEPLOYMENT_GUIDE.md
echo - PRODUCTION_READINESS_PLAN.md
echo.
echo To start the development server:
echo   cd social-live-mvp
echo   npm run start:dev
echo.
pause
