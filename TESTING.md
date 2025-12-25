# Testing Documentation

## Overview

This document outlines the comprehensive testing strategy for the Social Live platform, covering unit tests, integration tests, end-to-end tests, and load testing scenarios.

## Test Structure

```
social-live-flutter-mvp/
├── social-live-mvp/          # Backend tests
│   ├── test/                 # Unit & integration tests
│   │   ├── setup.ts         # Test setup and utilities
│   │   ├── auth.service.spec.ts
│   │   ├── recommendation.service.spec.ts
│   │   ├── auth.e2e-spec.ts
│   │   └── feed.e2e-spec.ts
│   ├── load-tests/          # Load testing scenarios
│   │   ├── auth-load-test.yml
│   │   ├── api-stress-test.yml
│   │   └── database-load-test.yml
│   └── scripts/
│       └── seed-test-data.ts # Test data seeding
├── social-live-web/         # Frontend tests
│   ├── src/__tests__/       # Unit tests
│   │   ├── useAuth.test.tsx
│   │   └── dashboard.test.tsx
│   ├── e2e/                 # E2E tests
│   │   ├── auth.spec.ts
│   │   ├── dashboard.spec.ts
│   │   └── admin.spec.ts
│   ├── jest.config.js       # Jest configuration
│   └── playwright.config.ts # Playwright configuration
└── .github/workflows/       # CI/CD automation
    └── test.yml
```

## Test Categories

### 1. Unit Tests

**Backend Unit Tests**
- Service layer testing (AuthService, RecommendationService, etc.)
- Utility function testing
- Business logic validation
- Mock external dependencies

**Frontend Unit Tests**
- React component testing
- Custom hooks testing (useAuth)
- Utility function testing
- State management testing

**Coverage Requirements:**
- Minimum 80% code coverage
- 100% coverage for critical paths (authentication, payments)

### 2. Integration Tests

**Backend Integration Tests**
- API endpoint testing
- Database integration
- Authentication flow
- Cache integration
- External service integration

**Test Scenarios:**
- User authentication and authorization
- Feed generation and caching
- ML recommendation pipeline
- Error handling and recovery

### 3. End-to-End Tests

**Frontend E2E Tests**
- Complete user workflows
- Cross-browser compatibility
- Mobile responsiveness
- Authentication flows
- Admin functionality

**Test Scenarios:**
- User login/logout flow
- Dashboard navigation
- Admin user management
- System monitoring access
- Role-based access control

### 4. Load Testing

**Performance Testing Scenarios:**

1. **Authentication Load Test**
   - 100 concurrent users
   - Login/logout cycles
   - Token refresh operations
   - Session management

2. **API Stress Test**
   - 500 concurrent users
   - Mixed read/write operations
   - Cache performance
   - Database load

3. **Database Load Test**
   - Heavy read operations
   - Write-intensive scenarios
   - Analytics queries
   - Concurrent transactions

**Performance Targets:**
- Response time: < 200ms (95th percentile)
- Throughput: > 1000 requests/second
- Error rate: < 0.1%
- Memory usage: < 1GB

## Running Tests

### Backend Tests

```bash
# Unit tests
npm run test

# Integration tests
npm run test:e2e

# Coverage report
npm run test:cov

# Watch mode
npm run test:watch
```

### Frontend Tests

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Coverage report
npm run test:coverage

# E2E with UI
npm run test:e2e:ui
```

### Load Tests

```bash
# Seed test data first
npm run test:seed

# Authentication load test
npm run test:load

# API stress test
npm run test:stress

# Database load test
npm run test:db-load
```

### Complete Test Suite

```bash
# Run all tests (Windows)
./run-all-tests.bat

# Run all tests (Linux/Mac)
./run-all-tests.sh
```

## Test Data Management

### Test Database
- Separate SQLite database for testing
- Automatic cleanup between tests
- Seeded with realistic test data

### Test Users
- 1000 test users with different roles
- Admin: admin@sociallive.com / admin123
- Regular users: test1@example.com / password123
- Creators: creator1@example.com / password123

### Test Data Seeding
```bash
npm run test:seed
```

Creates:
- 1000 test users
- 500 test posts
- 2000 engagement records
- Feature flags
- Admin accounts

## Continuous Integration

### GitHub Actions Workflow
- Automated testing on push/PR
- Parallel test execution
- Coverage reporting
- Load testing validation
- Security scanning

### Test Stages
1. **Backend Tests** - Unit and integration tests
2. **Frontend Tests** - Component and E2E tests
3. **Load Tests** - Performance validation
4. **Security Scan** - Vulnerability assessment

## Test Environment Setup

### Prerequisites
- Node.js 18+
- Redis server
- SQLite database
- Artillery (for load testing)
- Playwright browsers

### Environment Variables
```bash
# Backend
DATABASE_URL=file:./test.db
REDIS_URL=redis://localhost:6379
JWT_SECRET=test-secret
JWT_REFRESH_SECRET=test-refresh-secret

# Frontend
NEXT_PUBLIC_API_URL=http://localhost:3000/api/v1
```

## Best Practices

### Test Writing Guidelines
1. **Arrange-Act-Assert** pattern
2. **Descriptive test names** that explain the scenario
3. **Mock external dependencies** appropriately
4. **Test edge cases** and error conditions
5. **Keep tests isolated** and independent

### Performance Testing
1. **Gradual load increase** to identify breaking points
2. **Monitor system resources** during tests
3. **Test realistic scenarios** based on expected usage
4. **Validate both success and failure paths**

### Maintenance
1. **Update tests** when features change
2. **Review test coverage** regularly
3. **Clean up test data** after test runs
4. **Monitor test execution time** and optimize slow tests

## Troubleshooting

### Common Issues

**Backend Tests Failing:**
- Check Redis connection
- Verify database migrations
- Ensure test data is seeded

**Frontend Tests Failing:**
- Check API mocking setup
- Verify component dependencies
- Update snapshots if needed

**Load Tests Failing:**
- Ensure backend service is running
- Check system resources
- Verify test data exists

**E2E Tests Failing:**
- Check browser installation
- Verify application is running
- Update selectors if UI changed

## Reporting

### Coverage Reports
- Generated in `coverage/` directory
- HTML reports for detailed analysis
- LCOV format for CI integration

### Load Test Reports
- Artillery generates detailed reports
- Performance metrics and graphs
- Error analysis and recommendations

### CI/CD Integration
- Automated test execution
- Coverage tracking over time
- Performance regression detection
- Security vulnerability alerts