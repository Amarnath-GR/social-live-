import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { AnalyticsHelper } from '../../shared/analytics.helper';

@Injectable()
export class PostsService {
  constructor(private prisma: PrismaService) {}

  async createPost(data: any) {
    try {
      const post = await this.prisma.post.create({
        data: {
          userId: data.userId,
          content: data.content,
          mediaUrl: data.mediaUrl,
          mediaType: data.mediaType,
          visibility: data.visibility || 'PUBLIC',
        },
        include: { user: { select: { id: true, username: true, fullName: true } } },
      });

      return { success: true, data: { post } };
    } catch (error) {
      return { success: false, error: 'Failed to create post' };
    }
  }

  async getPosts(query: any) {
    try {
      const { page = 1, limit = 20, userId } = query;
      const skip = (page - 1) * limit;

      const posts = await this.prisma.post.findMany({
        where: userId ? { userId } : { visibility: 'PUBLIC' },
        include: { user: { select: { id: true, username: true, fullName: true } } },
        orderBy: { createdAt: 'desc' },
        skip,
        take: parseInt(limit),
      });

      const total = await this.prisma.post.count({
        where: userId ? { userId } : { visibility: 'PUBLIC' },
      });

      return {
        success: true,
        data: {
          posts,
          pagination: { page: parseInt(page), limit: parseInt(limit), total },
        },
      };
    } catch (error) {
      return { success: false, error: 'Failed to fetch posts' };
    }
  }

  async getPost(id: string) {
    try {
      const post = await this.prisma.post.findUnique({
        where: { id },
        include: { user: { select: { id: true, username: true, fullName: true } } },
      });

      if (!post) {
        return { success: false, error: 'Post not found' };
      }

      // Track view event
      AnalyticsHelper.trackView(post.userId, 'post', id);

      return { success: true, data: { post } };
    } catch (error) {
      return { success: false, error: 'Failed to fetch post' };
    }
  }

  async updatePost(id: string, data: any, userId: string) {
    try {
      const post = await this.prisma.post.update({
        where: { id, userId },
        data: { content: data.content, visibility: data.visibility },
      });

      return { success: true, data: { post } };
    } catch (error) {
      return { success: false, error: 'Failed to update post' };
    }
  }

  async deletePost(id: string, userId: string) {
    try {
      await this.prisma.post.delete({ where: { id, userId } });
      return { success: true, message: 'Post deleted' };
    } catch (error) {
      return { success: false, error: 'Failed to delete post' };
    }
  }

  async likePost(postId: string, userId: string) {
    try {
      await this.prisma.userEngagement.upsert({
        where: { userId_postId_engagementType: { userId, postId, engagementType: 'LIKE' } },
        create: { userId, postId, engagementType: 'LIKE' },
        update: {},
      });

      // Track engagement event
      AnalyticsHelper.trackEngagement(userId, 'like', 'post', postId);

      return { success: true, data: { liked: true } };
    } catch (error) {
      return { success: false, error: 'Failed to like post' };
    }
  }

  async unlikePost(postId: string, userId: string) {
    try {
      await this.prisma.userEngagement.delete({
        where: { userId_postId_engagementType: { userId, postId, engagementType: 'LIKE' } },
      });

      return { success: true, data: { liked: false } };
    } catch (error) {
      return { success: false, error: 'Failed to unlike post' };
    }
  }

  async getComments(postId: string, query: any) {
    try {
      const { page = 1, limit = 10 } = query;
      const skip = (page - 1) * limit;

      const comments = await this.prisma.comment.findMany({
        where: { postId },
        include: { user: { select: { id: true, username: true, fullName: true } } },
        orderBy: { createdAt: 'desc' },
        skip,
        take: parseInt(limit),
      });

      return { success: true, data: { comments } };
    } catch (error) {
      return { success: false, error: 'Failed to fetch comments' };
    }
  }

  async createComment(postId: string, data: any) {
    try {
      const comment = await this.prisma.comment.create({
        data: {
          postId,
          userId: data.userId,
          content: data.content,
          parentId: data.parentId,
        },
        include: { user: { select: { id: true, username: true, fullName: true } } },
      });

      return { success: true, data: { comment } };
    } catch (error) {
      return { success: false, error: 'Failed to create comment' };
    }
  }
}