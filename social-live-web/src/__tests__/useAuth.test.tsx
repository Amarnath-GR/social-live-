import { renderHook, act } from '@testing-library/react';
import { useAuth, AuthProvider } from '@/hooks/useAuth';
import { api } from '@/lib/api';
import Cookies from 'js-cookie';

jest.mock('@/lib/api');
jest.mock('js-cookie');

const mockApi = api as jest.Mocked<typeof api>;
const mockCookies = Cookies as jest.Mocked<typeof Cookies>;

describe('useAuth', () => {
  const wrapper = ({ children }: { children: React.ReactNode }) => (
    <AuthProvider>{children}</AuthProvider>
  );

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should initialize with no user when no token exists', () => {
    mockCookies.get.mockReturnValue(undefined);

    const { result } = renderHook(() => useAuth(), { wrapper });

    expect(result.current.user).toBeNull();
    expect(result.current.loading).toBe(false);
  });

  it('should initialize with user when valid token exists', () => {
    const mockToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOiJ1c2VyLTEiLCJlbWFpbCI6InRlc3RAZXhhbXBsZS5jb20iLCJ1c2VybmFtZSI6InRlc3R1c2VyIiwibmFtZSI6IlRlc3QgVXNlciIsInJvbGUiOiJVU0VSIn0.signature';
    mockCookies.get.mockReturnValue(mockToken);

    const { result } = renderHook(() => useAuth(), { wrapper });

    expect(result.current.user).toEqual({
      id: 'user-1',
      email: 'test@example.com',
      username: 'testuser',
      name: 'Test User',
      role: 'USER',
      isBlocked: false,
      createdAt: expect.any(String),
    });
  });

  it('should login successfully with valid credentials', async () => {
    mockApi.login.mockResolvedValue({
      success: true,
      user: {
        id: 'user-1',
        email: 'test@example.com',
        username: 'testuser',
        name: 'Test User',
        role: 'USER',
        isBlocked: false,
        createdAt: new Date().toISOString(),
      },
      accessToken: 'access-token',
    });

    const { result } = renderHook(() => useAuth(), { wrapper });

    let loginResult: boolean;
    await act(async () => {
      loginResult = await result.current.login('test@example.com', 'password');
    });

    expect(loginResult!).toBe(true);
    expect(mockCookies.set).toHaveBeenCalledWith('access_token', 'access-token', { expires: 7 });
    expect(result.current.user).toBeTruthy();
  });

  it('should fail login with invalid credentials', async () => {
    mockApi.login.mockResolvedValue({
      success: false,
      message: 'Invalid credentials',
    });

    const { result } = renderHook(() => useAuth(), { wrapper });

    let loginResult: boolean;
    await act(async () => {
      loginResult = await result.current.login('test@example.com', 'wrong-password');
    });

    expect(loginResult!).toBe(false);
    expect(result.current.user).toBeNull();
  });

  it('should logout successfully', async () => {
    // Setup initial user
    const mockToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOiJ1c2VyLTEiLCJlbWFpbCI6InRlc3RAZXhhbXBsZS5jb20iLCJ1c2VybmFtZSI6InRlc3R1c2VyIiwibmFtZSI6IlRlc3QgVXNlciIsInJvbGUiOiJVU0VSIn0.signature';
    mockCookies.get.mockReturnValue(mockToken);

    const { result } = renderHook(() => useAuth(), { wrapper });

    act(() => {
      result.current.logout();
    });

    expect(mockApi.logout).toHaveBeenCalled();
    expect(mockCookies.remove).toHaveBeenCalledWith('access_token');
    expect(result.current.user).toBeNull();
  });

  it('should correctly identify admin users', () => {
    const adminToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOiJhZG1pbi0xIiwiZW1haWwiOiJhZG1pbkBleGFtcGxlLmNvbSIsInVzZXJuYW1lIjoiYWRtaW4iLCJuYW1lIjoiQWRtaW4gVXNlciIsInJvbGUiOiJBRE1JTiJ9.signature';
    mockCookies.get.mockReturnValue(adminToken);

    const { result } = renderHook(() => useAuth(), { wrapper });

    expect(result.current.isAdmin).toBe(true);
    expect(result.current.isCreator).toBe(true);
  });

  it('should correctly identify creator users', () => {
    const creatorToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOiJjcmVhdG9yLTEiLCJlbWFpbCI6ImNyZWF0b3JAZXhhbXBsZS5jb20iLCJ1c2VybmFtZSI6ImNyZWF0b3IiLCJuYW1lIjoiQ3JlYXRvciBVc2VyIiwicm9sZSI6IkNSRUFUT1IifQ.signature';
    mockCookies.get.mockReturnValue(creatorToken);

    const { result } = renderHook(() => useAuth(), { wrapper });

    expect(result.current.isAdmin).toBe(false);
    expect(result.current.isCreator).toBe(true);
  });
});