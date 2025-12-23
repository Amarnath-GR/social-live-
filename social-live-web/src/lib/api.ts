import axios from 'axios';
import Cookies from 'js-cookie';
import { ApiResponse } from '@/types';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api/v1';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
apiClient.interceptors.request.use((config) => {
  const token = Cookies.get('access_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      Cookies.remove('access_token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const api = {
  // Auth
  login: async (email: string, password: string) => {
    const response = await apiClient.post('/auth/login', { email, password });
    return response.data;
  },

  logout: async () => {
    await apiClient.post('/auth/logout');
    Cookies.remove('access_token');
  },

  // Users
  getUsers: async (page = 1, limit = 20) => {
    const response = await apiClient.get(`/users?page=${page}&limit=${limit}`);
    return response.data;
  },

  getUser: async (id: string) => {
    const response = await apiClient.get(`/users/${id}`);
    return response.data;
  },

  updateUserStatus: async (id: string, isBlocked: boolean) => {
    const response = await apiClient.patch(`/users/${id}/status`, { isBlocked });
    return response.data;
  },

  // Posts
  getPosts: async (page = 1, limit = 20) => {
    const response = await apiClient.get(`/posts?page=${page}&limit=${limit}`);
    return response.data;
  },

  // Analytics
  getAnalytics: async () => {
    const response = await apiClient.get('/analytics');
    return response.data;
  },

  getCreatorStats: async (userId: string) => {
    const response = await apiClient.get(`/analytics/creator/${userId}`);
    return response.data;
  },

  // Monitoring
  getSystemHealth: async () => {
    const response = await apiClient.get('/monitoring/health/detailed');
    return response.data;
  },

  getErrorStats: async (range = '24h') => {
    const response = await apiClient.get(`/monitoring/errors/stats?range=${range}`);
    return response.data;
  },

  getPerformanceStats: async (range = '24h') => {
    const response = await apiClient.get(`/monitoring/performance?range=${range}`);
    return response.data;
  },
};

export default apiClient;