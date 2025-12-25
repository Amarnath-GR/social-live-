import '@testing-library/jest-dom';

// Mock Next.js router
jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    back: jest.fn(),
  }),
  usePathname: () => '/dashboard',
}));

// Mock API client
jest.mock('@/lib/api', () => ({
  api: {
    login: jest.fn(),
    logout: jest.fn(),
    getAnalytics: jest.fn(),
    getSystemHealth: jest.fn(),
    getUsers: jest.fn(),
  },
}));

// Mock cookies
jest.mock('js-cookie', () => ({
  get: jest.fn(),
  set: jest.fn(),
  remove: jest.fn(),
}));