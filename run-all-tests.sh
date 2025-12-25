#!/bin/bash

echo "🧪 Running Comprehensive Test Suite for Social Live Platform"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
BACKEND_UNIT_RESULT=0
BACKEND_E2E_RESULT=0
FRONTEND_UNIT_RESULT=0
FRONTEND_E2E_RESULT=0
LOAD_TEST_RESULT=0

echo "📋 Test Plan:"
echo "1. Backend Unit Tests"
echo "2. Backend Integration Tests"
echo "3. Frontend Unit Tests"
echo "4. Frontend E2E Tests"
echo "5. Load Tests"
echo ""

# Backend Tests
echo "🔧 Running Backend Tests..."
cd social-live-mvp

echo "📦 Installing backend dependencies..."
npm install

echo "🌱 Seeding test data..."
npm run test:seed

echo "🧪 Running backend unit tests..."
npm run test
BACKEND_UNIT_RESULT=$?

if [ $BACKEND_UNIT_RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ Backend unit tests passed${NC}"
else
    echo -e "${RED}❌ Backend unit tests failed${NC}"
fi

echo "🔗 Running backend integration tests..."
npm run test:e2e
BACKEND_E2E_RESULT=$?

if [ $BACKEND_E2E_RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ Backend integration tests passed${NC}"
else
    echo -e "${RED}❌ Backend integration tests failed${NC}"
fi

# Frontend Tests
echo "🌐 Running Frontend Tests..."
cd ../social-live-web

echo "📦 Installing frontend dependencies..."
npm install

echo "🧪 Running frontend unit tests..."
npm run test
FRONTEND_UNIT_RESULT=$?

if [ $FRONTEND_UNIT_RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ Frontend unit tests passed${NC}"
else
    echo -e "${RED}❌ Frontend unit tests failed${NC}"
fi

echo "🎭 Running frontend E2E tests..."
npm run test:e2e
FRONTEND_E2E_RESULT=$?

if [ $FRONTEND_E2E_RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ Frontend E2E tests passed${NC}"
else
    echo -e "${RED}❌ Frontend E2E tests failed${NC}"
fi

# Load Tests (optional - only if services are running)
echo "⚡ Running Load Tests..."
cd ../social-live-mvp

echo "🚀 Starting services for load testing..."
# Start services in background
npm run start:dev &
BACKEND_PID=$!

# Wait for services to start
sleep 10

echo "📊 Running authentication load test..."
npm run test:load
LOAD_AUTH_RESULT=$?

echo "🔥 Running API stress test..."
npm run test:stress
LOAD_STRESS_RESULT=$?

echo "💾 Running database load test..."
npm run test:db-load
LOAD_DB_RESULT=$?

# Calculate overall load test result
if [ $LOAD_AUTH_RESULT -eq 0 ] && [ $LOAD_STRESS_RESULT -eq 0 ] && [ $LOAD_DB_RESULT -eq 0 ]; then
    LOAD_TEST_RESULT=0
    echo -e "${GREEN}✅ Load tests completed successfully${NC}"
else
    LOAD_TEST_RESULT=1
    echo -e "${YELLOW}⚠️ Some load tests had issues (check reports)${NC}"
fi

# Cleanup
echo "🧹 Cleaning up..."
kill $BACKEND_PID 2>/dev/null

# Test Summary
echo ""
echo "📊 Test Results Summary:"
echo "========================"

if [ $BACKEND_UNIT_RESULT -eq 0 ]; then
    echo -e "Backend Unit Tests:      ${GREEN}PASSED${NC}"
else
    echo -e "Backend Unit Tests:      ${RED}FAILED${NC}"
fi

if [ $BACKEND_E2E_RESULT -eq 0 ]; then
    echo -e "Backend Integration:     ${GREEN}PASSED${NC}"
else
    echo -e "Backend Integration:     ${RED}FAILED${NC}"
fi

if [ $FRONTEND_UNIT_RESULT -eq 0 ]; then
    echo -e "Frontend Unit Tests:     ${GREEN}PASSED${NC}"
else
    echo -e "Frontend Unit Tests:     ${RED}FAILED${NC}"
fi

if [ $FRONTEND_E2E_RESULT -eq 0 ]; then
    echo -e "Frontend E2E Tests:      ${GREEN}PASSED${NC}"
else
    echo -e "Frontend E2E Tests:      ${RED}FAILED${NC}"
fi

if [ $LOAD_TEST_RESULT -eq 0 ]; then
    echo -e "Load Tests:              ${GREEN}PASSED${NC}"
else
    echo -e "Load Tests:              ${YELLOW}WARNING${NC}"
fi

# Overall result
TOTAL_FAILURES=$((BACKEND_UNIT_RESULT + BACKEND_E2E_RESULT + FRONTEND_UNIT_RESULT + FRONTEND_E2E_RESULT))

if [ $TOTAL_FAILURES -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All critical tests passed! Platform is ready for deployment.${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}💥 $TOTAL_FAILURES test suite(s) failed. Please fix issues before deployment.${NC}"
    exit 1
fi