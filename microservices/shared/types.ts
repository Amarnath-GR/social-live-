export interface User {
  id: string;
  email: string;
  username: string;
  fullName?: string;
  role: 'USER' | 'CREATOR' | 'ADMIN';
  isVerified: boolean;
  createdAt: Date;
}

export interface Post {
  id: string;
  userId: string;
  content: string;
  mediaUrl?: string;
  likesCount: number;
  commentsCount: number;
  createdAt: Date;
}

export interface ServiceResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export interface WalletTransaction {
  id: string;
  userId: string;
  amount: number;
  type: 'CREDIT' | 'DEBIT';
  status: 'PENDING' | 'COMPLETED' | 'FAILED';
  createdAt: Date;
}

export interface StreamSession {
  id: string;
  userId: string;
  title: string;
  status: 'LIVE' | 'ENDED';
  viewerCount: number;
  createdAt: Date;
}

export interface Product {
  id: string;
  sellerId: string;
  name: string;
  price: number;
  status: 'ACTIVE' | 'INACTIVE';
  createdAt: Date;
}