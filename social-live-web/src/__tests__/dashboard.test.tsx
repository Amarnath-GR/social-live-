import { render, screen, waitFor } from '@testing-library/react';
import { useAuth } from '@/hooks/useAuth';
import { api } from '@/lib/api';
import DashboardPage from '@/app/dashboard/page';

jest.mock('@/hooks/useAuth');
jest.mock('@/lib/api');

const mockUseAuth = useAuth as jest.MockedFunction<typeof useAuth>;
const mockApi = api as jest.Mocked<typeof api>;

describe('DashboardPage', () => {
  const mockUser = {
    id: 'user-1',
    email: 'test@example.com',
    username: 'testuser',
    name: 'Test User',
    role: 'USER' as const,
    isBlocked: false,
    createdAt: new Date().toISOString(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should render loading state initially', () => {
    mockUseAuth.mockReturnValue({
      user: null,
      loading: true,
      login: jest.fn(),
      logout: jest.fn(),
      isAdmin: false,
      isCreator: false,
    });

    render(<DashboardPage />);

    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  it('should render dashboard when user is authenticated', async () => {
    mockUseAuth.mockReturnValue({
      user: mockUser,
      loading: false,
      login: jest.fn(),
      logout: jest.fn(),
      isAdmin: false,
      isCreator: false,
    });

    mockApi.getAnalytics.mockResolvedValue({
      data: {
        totalUsers: 100,
        totalPosts: 50,
        totalEngagements: 200,
        userGrowth: 10,
        postGrowth: 5,
        engagementGrowth: 15,
        dailyStats: [],
      },
    });

    mockApi.getSystemHealth.mockResolvedValue({
      status: 'ok',
      uptime: 3600,
      memory: {
        heapUsed: 50 * 1024 * 1024,
        heapTotal: 100 * 1024 * 1024,
      },
      activeRequests: 5,
    });

    render(<DashboardPage />);

    await waitFor(() => {
      expect(screen.getByText('Welcome back, Test User')).toBeInTheDocument();
    });

    expect(screen.getByText('Total Users')).toBeInTheDocument();
    expect(screen.getByText('100')).toBeInTheDocument();
    expect(screen.getByText('Total Posts')).toBeInTheDocument();
    expect(screen.getByText('50')).toBeInTheDocument();
  });

  it('should display system health information', async () => {
    mockUseAuth.mockReturnValue({
      user: mockUser,
      loading: false,
      login: jest.fn(),
      logout: jest.fn(),
      isAdmin: false,
      isCreator: false,
    });

    mockApi.getAnalytics.mockResolvedValue({ data: {} });
    mockApi.getSystemHealth.mockResolvedValue({
      status: 'ok',
      uptime: 7200, // 2 hours
      memory: {
        heapUsed: 75 * 1024 * 1024,
        heapTotal: 100 * 1024 * 1024,
      },
      activeRequests: 3,
    });

    render(<DashboardPage />);

    await waitFor(() => {
      expect(screen.getByText('System Status')).toBeInTheDocument();
    });

    expect(screen.getByText('2h 0m')).toBeInTheDocument(); // Uptime
    expect(screen.getByText('75MB')).toBeInTheDocument(); // Memory usage
    expect(screen.getByText('3')).toBeInTheDocument(); // Active requests
  });

  it('should handle API errors gracefully', async () => {
    mockUseAuth.mockReturnValue({
      user: mockUser,
      loading: false,
      login: jest.fn(),
      logout: jest.fn(),
      isAdmin: false,
      isCreator: false,
    });

    mockApi.getAnalytics.mockRejectedValue(new Error('API Error'));
    mockApi.getSystemHealth.mockRejectedValue(new Error('API Error'));

    const consoleSpy = jest.spyOn(console, 'error').mockImplementation();

    render(<DashboardPage />);

    await waitFor(() => {
      expect(screen.getByText('Welcome back, Test User')).toBeInTheDocument();
    });

    expect(consoleSpy).toHaveBeenCalledWith('Failed to load dashboard data:', expect.any(Error));

    consoleSpy.mockRestore();
  });
});