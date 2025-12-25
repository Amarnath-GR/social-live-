'use client';

import { useState, useEffect, createContext, useContext } from 'react';
import Cookies from 'js-cookie';
import { api } from '@/lib/api';
import { User } from '@/types';

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => void;
  isAdmin: boolean;
  isCreator: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = Cookies.get('access_token');
    if (token) {
      // Decode token to get user info (simplified)
      try {
        const payload = JSON.parse(atob(token.split('.')[1]));
        setUser({
          id: payload.userId,
          email: payload.email,
          username: payload.username,
          name: payload.name,
          role: payload.role,
          isBlocked: false,
          createdAt: new Date().toISOString(),
        });
      } catch (error) {
        Cookies.remove('access_token');
      }
    }
    setLoading(false);
  }, []);

  const login = async (email: string, password: string): Promise<boolean> => {
    try {
      const response = await api.login(email, password);
      if (response.success && response.user) {
        const token = response.accessToken || response.data?.tokens?.accessToken;
        if (token) {
          Cookies.set('access_token', token, { expires: 7 });
          setUser(response.user || response.data?.user);
          return true;
        }
      }
      return false;
    } catch (error) {
      return false;
    }
  };

  const logout = () => {
    api.logout();
    setUser(null);
    Cookies.remove('access_token');
  };

  const isAdmin = user?.role === 'ADMIN';
  const isCreator = user?.role === 'CREATOR' || user?.role === 'ADMIN';

  return (
    <AuthContext.Provider value={{ user, loading, login, logout, isAdmin, isCreator }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}