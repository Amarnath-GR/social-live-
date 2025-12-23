import axios from 'axios';

export class AnalyticsHelper {
  private static analyticsServiceUrl = process.env.ANALYTICS_SERVICE_URL || 'http://localhost:3006';

  static async trackView(userId: string, contentType: string, contentId: string, metadata?: any) {
    return this.track({
      eventType: 'view',
      userId,
      data: {
        contentType,
        contentId,
        ...metadata,
      },
    });
  }

  static async trackEngagement(userId: string, action: string, targetType: string, targetId: string, metadata?: any) {
    return this.track({
      eventType: 'engagement',
      userId,
      data: {
        action,
        targetType,
        targetId,
        metadata,
      },
    });
  }

  static async trackPurchase(userId: string, purchaseData: any) {
    return this.track({
      eventType: 'purchase',
      userId,
      data: purchaseData,
    });
  }

  static async trackStream(userId: string, action: string, streamId: string, metadata?: any) {
    return this.track({
      eventType: 'stream',
      userId,
      data: {
        action,
        streamId,
        ...metadata,
      },
    });
  }

  private static async track(event: any) {
    try {
      await axios.post(`${this.analyticsServiceUrl}/events/track`, event, {
        headers: { 'X-Service-Name': 'helper' },
        timeout: 2000,
      });
    } catch (error) {
      console.warn('Analytics tracking failed:', error.message);
    }
  }
}