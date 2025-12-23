@echo off
echo 🧪 Running Comprehensive Test Suite for Social Live Platform

set BACKEND_UNIT_RESULT=0
set BACKEND_E2E_RESULT=0
set FRONTEND_UNIT_RESULT=0
set FRONTEND_E2E_RESULT=0
set LOAD_TEST_RESULT=0

echo 📋 Test Plan:
echo 1. Backend Unit Tests
echo 2. Backend Integration Tests
echo 3. Frontend Unit Tests
echo 4. Frontend E2E Tests
echo 5. Load Tests
echo.

REM Backend Tests
echo 🔧 Running Backend Tests...
cd social-live-mvp

echo 📦 Installing backend dependencies...
call npm install

echo 🌱 Seeding test data...
call npm run test:seed

echo 🧪 Running backend unit tests...
call npm run test
set BACKEND_UNIT_RESULT=%ERRORLEVEL%

if %BACKEND_UNIT_RESULT%==0 (
    echo ✅ Backend unit tests passed
) else (
    echo ❌ Backend unit tests failed
)

echo 🔗 Running backend integration tests...
call npm run test:e2e
set BACKEND_E2E_RESULT=%ERRORLEVEL%

if %BACKEND_E2E_RESULT%==0 (
    echo ✅ Backend integration tests passed
) else (
    echo ❌ Backend integration tests failed
)

REM Frontend Tests
echo 🌐 Running Frontend Tests...
cd ..\social-live-web

echo 📦 Installing frontend dependencies...
call npm install

echo 🧪 Running frontend unit tests...
call npm run test
set FRONTEND_UNIT_RESULT=%ERRORLEVEL%

if %FRONTEND_UNIT_RESULT%==0 (
    echo ✅ Frontend unit tests passed
) else (
    echo ❌ Frontend unit tests failed
)

echo 🎭 Running frontend E2E tests...
call npm run test:e2e
set FRONTEND_E2E_RESULT=%ERRORLEVEL%

if %FRONTEND_E2E_RESULT%==0 (
    echo ✅ Frontend E2E tests passed
) else (
    echo ❌ Frontend E2E tests failed
)

REM Load Tests
echo ⚡ Running Load Tests...
cd ..\social-live-mvp

echo 🚀 Starting services for load testing...
start "Backend Service" cmd /k "npm run start:dev"

REM Wait for services to start
timeout /t 10 /nobreak >nul

echo 📊 Running authentication load test...
call npm run test:load
set LOAD_AUTH_RESULT=%ERRORLEVEL%

echo 🔥 Running API stress test...
call npm run test:stress
set LOAD_STRESS_RESULT=%ERRORLEVEL%

echo 💾 Running database load test...
call npm run test:db-load
set LOAD_DB_RESULT=%ERRORLEVEL%

REM Calculate load test result
if %LOAD_AUTH_RESULT%==0 if %LOAD_STRESS_RESULT%==0 if %LOAD_DB_RESULT%==0 (
    set LOAD_TEST_RESULT=0
    echo ✅ Load tests completed successfully
) else (
    set LOAD_TEST_RESULT=1
    echo ⚠️ Some load tests had issues
)

echo.
echo 📊 Test Results Summary:
echo ========================

if %BACKEND_UNIT_RESULT%==0 (
    echo Backend Unit Tests:      PASSED
) else (
    echo Backend Unit Tests:      FAILED
)

if %BACKEND_E2E_RESULT%==0 (
    echo Backend Integration:     PASSED
) else (
    echo Backend Integration:     FAILED
)

if %FRONTEND_UNIT_RESULT%==0 (
    echo Frontend Unit Tests:     PASSED
) else (
    echo Frontend Unit Tests:     FAILED
)

if %FRONTEND_E2E_RESULT%==0 (
    echo Frontend E2E Tests:      PASSED
) else (
    echo Frontend E2E Tests:      FAILED
)

if %LOAD_TEST_RESULT%==0 (
    echo Load Tests:              PASSED
) else (
    echo Load Tests:              WARNING
)

set /a TOTAL_FAILURES=%BACKEND_UNIT_RESULT%+%BACKEND_E2E_RESULT%+%FRONTEND_UNIT_RESULT%+%FRONTEND_E2E_RESULT%

if %TOTAL_FAILURES%==0 (
    echo.
    echo 🎉 All critical tests passed! Platform is ready for deployment.
) else (
    echo.
    echo 💥 %TOTAL_FAILURES% test suite(s) failed. Please fix issues before deployment.
)

pause