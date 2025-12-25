import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Injectable()
export class FeedService {
  constructor(private prisma: PrismaService) {}

  async getPersonalizedFeed(userId: string, query: any) {
    try {
      const { page = 1, limit = 20 } = query;
      const skip = (page - 1) * limit;

      const feedItems = await this.prisma.feedItem.findMany({
        where: { userId },
        include: {
          post: {
            include: { user: { select: { id: true, username: true, fullName: true } } },
          },
        },
        orderBy: { score: 'desc' },
        skip,
        take: parseInt(limit),
      });

      return {
        success: true,
        data: {
          feedItems: feedItems.map(item => ({
            id: item.id,
            score: item.score,
            post: item.post,
          })),
        },
      };
    } catch (error) {
      return { success: false, error: 'Failed to fetch feed' };
    }
  }

  async getFollowingFeed(userId: string, query: any) {
    try {
      const { page = 1, limit = 20 } = query;
      const skip = (page - 1) * limit;

      const posts = await this.prisma.post.findMany({
        where: {
          user: {
            followers: { some: { followerId: userId } },
          },
        },
        include: { user: { select: { id: true, username: true, fullName: true } } },
        orderBy: { createdAt: 'desc' },
        skip,
        take: parseInt(limit),
      });

      return { success: true, data: { posts } };
    } catch (error) {
      return { success: false, error: 'Failed to fetch following feed' };
    }
  }

  async getTrendingFeed(query: any) {
    try {
      const { timeframe = '24h', limit = 20 } = query;
      const since = new Date(Date.now() - (timeframe === '1h' ? 3600000 : 86400000));

      const posts = await this.prisma.post.findMany({
        where: {
          createdAt: { gte: since },
          visibility: 'PUBLIC',
        },
        include: { user: { select: { id: true, username: true, fullName: true } } },
        orderBy: { engagementScore: 'desc' },
        take: parseInt(limit),
      });

      return { success: true, data: { posts } };
    } catch (error) {
      return { success: false, error: 'Failed to fetch trending feed' };
    }
  }
}