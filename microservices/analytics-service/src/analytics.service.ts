import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from './prisma.service';

@Injectable()
export class AnalyticsService {
  constructor(private prisma: PrismaService) {}

  async getDashboard(userId?: string, query: any = {}) {
    try {
      const { timeframe = '7d' } = query;
      const since = this.getTimeframeSince(timeframe);

      const [
        totalEvents,
        uniqueUsers,
        topContent,
        engagementMetrics,
        revenueMetrics,
      ] = await Promise.all([
        this.getTotalEvents(since, userId),
        this.getUniqueUsers(since),
        this.getTopContent(since, userId),
        this.getEngagementMetrics(since, userId),
        this.getRevenueMetrics(since, userId),
      ]);

      return {
        success: true,
        data: {
          totalEvents,
          uniqueUsers,
          topContent,
          engagementMetrics,
          revenueMetrics,
          timeframe,
        },
      };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async getEvents(query: any) {
    try {
      const {
        eventType,
        userId,
        timeframe = '24h',
        page = 1,
        limit = 100,
      } = query;

      const since = this.getTimeframeSince(timeframe);
      const skip = (page - 1) * limit;

      const where: any = { timestamp: { gte: since } };
      if (eventType) where.eventType = eventType;
      if (userId) where.userId = userId;

      const events = await this.prisma.analyticsEvent.findMany({
        where,
        orderBy: { timestamp: 'desc' },
        skip,
        take: parseInt(limit),
      });

      const total = await this.prisma.analyticsEvent.count({ where });

      return {
        success: true,
        data: {
          events,
          pagination: { page: parseInt(page), limit: parseInt(limit), total },
        },
      };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async getMetrics(query: any) {
    try {
      const { metric, timeframe = '7d', groupBy = 'day' } = query;
      const since = this.getTimeframeSince(timeframe);

      let metrics;
      switch (metric) {
        case 'views':
          metrics = await this.getViewMetrics(since, groupBy);
          break;
        case 'engagement':
          metrics = await this.getEngagementMetrics(since);
          break;
        case 'revenue':
          metrics = await this.getRevenueMetrics(since);
          break;
        default:
          metrics = await this.getAllMetrics(since, groupBy);
      }

      return { success: true, data: { metrics, timeframe, groupBy } };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async getFunnelAnalysis(query: any) {
    try {
      const { steps, timeframe = '7d' } = query;
      const since = this.getTimeframeSince(timeframe);

      const funnel = [];
      for (const step of steps) {
        const count = await this.prisma.analyticsEvent.count({
          where: {
            eventType: step.eventType,
            eventData: { path: [step.field], equals: step.value },
            timestamp: { gte: since },
          },
        });
        funnel.push({ step: step.name, count });
      }

      return { success: true, data: { funnel, timeframe } };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async getCohortAnalysis(query: any) {
    try {
      const { timeframe = '30d' } = query;
      const since = this.getTimeframeSince(timeframe);

      const cohorts = await this.prisma.$queryRaw`
        SELECT 
          DATE_TRUNC('week', timestamp) as cohort_week,
          COUNT(DISTINCT user_id) as users
        FROM analytics_events 
        WHERE timestamp >= ${since}
        GROUP BY cohort_week
        ORDER BY cohort_week
      `;

      return { success: true, data: { cohorts, timeframe } };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async getRetentionAnalysis(query: any) {
    try {
      const { timeframe = '30d' } = query;
      const since = this.getTimeframeSince(timeframe);

      const retention = await this.prisma.$queryRaw`
        WITH user_first_seen AS (
          SELECT user_id, MIN(DATE(timestamp)) as first_seen
          FROM analytics_events
          WHERE timestamp >= ${since}
          GROUP BY user_id
        ),
        user_activity AS (
          SELECT 
            u.user_id,
            u.first_seen,
            DATE(e.timestamp) as activity_date,
            DATE(e.timestamp) - u.first_seen as days_since_first
          FROM user_first_seen u
          JOIN analytics_events e ON u.user_id = e.user_id
          WHERE e.timestamp >= ${since}
        )
        SELECT 
          days_since_first,
          COUNT(DISTINCT user_id) as retained_users
        FROM user_activity
        WHERE days_since_first <= 30
        GROUP BY days_since_first
        ORDER BY days_since_first
      `;

      return { success: true, data: { retention, timeframe } };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  @Cron(CronExpression.EVERY_HOUR)
  async aggregateHourlyMetrics() {
    const hourAgo = new Date(Date.now() - 60 * 60 * 1000);
    
    const metrics = await this.prisma.analyticsEvent.groupBy({
      by: ['eventType'],
      where: { timestamp: { gte: hourAgo } },
      _count: { eventId: true },
    });

    for (const metric of metrics) {
      await this.prisma.analyticsAggregation.upsert({
        where: {
          timeframe_eventType_timestamp: {
            timeframe: 'hour',
            eventType: metric.eventType,
            timestamp: new Date(Math.floor(hourAgo.getTime() / 3600000) * 3600000),
          },
        },
        create: {
          timeframe: 'hour',
          eventType: metric.eventType,
          timestamp: new Date(Math.floor(hourAgo.getTime() / 3600000) * 3600000),
          count: metric._count.eventId,
        },
        update: {
          count: metric._count.eventId,
        },
      });
    }
  }

  private async getTotalEvents(since: Date, userId?: string) {
    const where: any = { timestamp: { gte: since } };
    if (userId) where.userId = userId;
    return this.prisma.analyticsEvent.count({ where });
  }

  private async getUniqueUsers(since: Date) {
    const result = await this.prisma.analyticsEvent.groupBy({
      by: ['userId'],
      where: { timestamp: { gte: since } },
    });
    return result.length;
  }

  private async getTopContent(since: Date, userId?: string) {
    const where: any = {
      eventType: 'view',
      timestamp: { gte: since },
    };
    if (userId) where.userId = userId;

    return this.prisma.analyticsEvent.groupBy({
      by: ['eventData'],
      where,
      _count: { eventId: true },
      orderBy: { _count: { eventId: 'desc' } },
      take: 10,
    });
  }

  private async getEngagementMetrics(since: Date, userId?: string) {
    const where: any = {
      eventType: 'engagement',
      timestamp: { gte: since },
    };
    if (userId) where.userId = userId;

    return this.prisma.analyticsEvent.groupBy({
      by: ['eventData'],
      where,
      _count: { eventId: true },
    });
  }

  private async getRevenueMetrics(since: Date, userId?: string) {
    const where: any = {
      eventType: 'purchase',
      timestamp: { gte: since },
    };
    if (userId) where.userId = userId;

    const purchases = await this.prisma.analyticsEvent.findMany({ where });
    
    const totalRevenue = purchases.reduce((sum, event) => {
      return sum + (event.eventData as any).amount || 0;
    }, 0);

    return {
      totalRevenue,
      totalOrders: purchases.length,
      averageOrderValue: purchases.length > 0 ? totalRevenue / purchases.length : 0,
    };
  }

  private async getViewMetrics(since: Date, groupBy: string) {
    return this.prisma.analyticsEvent.groupBy({
      by: ['eventType'],
      where: {
        eventType: 'view',
        timestamp: { gte: since },
      },
      _count: { eventId: true },
    });
  }

  private async getAllMetrics(since: Date, groupBy: string) {
    return this.prisma.analyticsEvent.groupBy({
      by: ['eventType'],
      where: { timestamp: { gte: since } },
      _count: { eventId: true },
    });
  }

  private getTimeframeSince(timeframe: string): Date {
    const now = new Date();
    switch (timeframe) {
      case '1h': return new Date(now.getTime() - 60 * 60 * 1000);
      case '24h': return new Date(now.getTime() - 24 * 60 * 60 * 1000);
      case '7d': return new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      case '30d': return new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
      case '90d': return new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
      default: return new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    }
  }
}