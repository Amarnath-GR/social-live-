export interface User {
  id: string;
  email: string;
  username: string;
  name: string;
  avatar?: string;
  role: 'USER' | 'ADMIN' | 'CREATOR';
  isBlocked: boolean;
  createdAt: string;
}

export interface Post {
  id: string;
  content: string;
  imageUrl?: string;
  userId: string;
  user: User;
  likes: number;
  comments: number;
  views: number;
  createdAt: string;
}

export interface Analytics {
  totalUsers: number;
  totalPosts: number;
  totalEngagements: number;
  dailyActiveUsers: number;
  weeklyGrowth: number;
  topPosts: Post[];
}

export interface CreatorStats {
  totalPosts: number;
  totalLikes: number;
  totalComments: number;
  totalViews: number;
  followers: number;
  engagement: {
    date: string;
    likes: number;
    comments: number;
    views: number;
  }[];
}

export interface SystemHealth {
  status: string;
  uptime: number;
  memory: {
    rss: number;
    heapTotal: number;
    heapUsed: number;
  };
  activeRequests: number;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
}