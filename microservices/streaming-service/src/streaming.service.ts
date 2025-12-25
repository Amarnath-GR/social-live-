import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Injectable()
export class StreamingService {
  constructor(private prisma: PrismaService) {}

  async startStream(userId: string, data: { title: string; description?: string }) {
    try {
      const stream = await this.prisma.streamSession.create({
        data: {
          userId,
          title: data.title,
          description: data.description,
          status: 'LIVE',
          streamKey: this.generateStreamKey(),
        },
      });

      return { success: true, data: { stream } };
    } catch (error) {
      return { success: false, error: 'Failed to start stream' };
    }
  }

  async endStream(streamId: string, userId: string) {
    try {
      const stream = await this.prisma.streamSession.update({
        where: { id: streamId, userId },
        data: { status: 'ENDED', endedAt: new Date() },
      });

      return { success: true, data: { stream } };
    } catch (error) {
      return { success: false, error: 'Failed to end stream' };
    }
  }

  async getLiveStreams() {
    try {
      const streams = await this.prisma.streamSession.findMany({
        where: { status: 'LIVE' },
        include: { user: { select: { id: true, username: true, fullName: true } } },
        orderBy: { viewerCount: 'desc' },
      });

      return { success: true, data: { streams } };
    } catch (error) {
      return { success: false, error: 'Failed to get live streams' };
    }
  }

  async getStream(streamId: string) {
    try {
      const stream = await this.prisma.streamSession.findUnique({
        where: { id: streamId },
        include: { user: { select: { id: true, username: true, fullName: true } } },
      });

      if (!stream) {
        return { success: false, error: 'Stream not found' };
      }

      return { success: true, data: { stream } };
    } catch (error) {
      return { success: false, error: 'Failed to get stream' };
    }
  }

  async joinStream(streamId: string, userId: string) {
    try {
      await this.prisma.streamViewer.upsert({
        where: { streamId_userId: { streamId, userId } },
        create: { streamId, userId },
        update: { joinedAt: new Date() },
      });

      await this.prisma.streamSession.update({
        where: { id: streamId },
        data: { viewerCount: { increment: 1 } },
      });

      return { success: true, message: 'Joined stream' };
    } catch (error) {
      return { success: false, error: 'Failed to join stream' };
    }
  }

  async leaveStream(streamId: string, userId: string) {
    try {
      await this.prisma.streamViewer.delete({
        where: { streamId_userId: { streamId, userId } },
      });

      await this.prisma.streamSession.update({
        where: { id: streamId },
        data: { viewerCount: { decrement: 1 } },
      });

      return { success: true, message: 'Left stream' };
    } catch (error) {
      return { success: false, error: 'Failed to leave stream' };
    }
  }

  private generateStreamKey(): string {
    return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
  }
}