@echo off
echo ========================================
echo Production Data Setup Script
echo ========================================
echo.

cd social-live-mvp

echo Step 1: Installing dependencies...
call npm install
if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    exit /b 1
)
echo.

echo Step 2: Generating Prisma Client...
call npx prisma generate
if errorlevel 1 (
    echo ERROR: Failed to generate Prisma client
    exit /b 1
)
echo.

echo Step 3: Running database migrations...
call npx prisma migrate dev --name add_cart_system
if errorlevel 1 (
    echo ERROR: Failed to run migrations
    exit /b 1
)
echo.

echo Step 4: Seeding production data...
call npx ts-node src/seed/production-seed.ts
if errorlevel 1 (
    echo ERROR: Failed to seed production data
    exit /b 1
)
echo.

echo ========================================
echo Production data setup completed!
echo ========================================
echo.
echo Next steps:
echo 1. Configure your .env file with production credentials
echo 2. Start the backend: npm run start:dev
echo 3. Test the API endpoints
echo.

cd ..
pause
