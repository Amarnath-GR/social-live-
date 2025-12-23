import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { AnalyticsEvent, SCHEMA_VERSIONS } from './types';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class EventsService {
  private currentSchemaVersion = '1.1.0';

  constructor(private prisma: PrismaService) {}

  async trackEvent(eventData: Partial<AnalyticsEvent>, req: any) {
    try {
      const event = this.enrichEvent(eventData, req);
      const validatedEvent = this.validateEvent(event);
      
      await this.storeEvent(validatedEvent);
      
      return { success: true, eventId: event.eventId };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async trackBatchEvents(events: Partial<AnalyticsEvent>[], req: any) {
    try {
      const enrichedEvents = events.map(event => this.enrichEvent(event, req));
      const validatedEvents = enrichedEvents.map(event => this.validateEvent(event));
      
      await this.storeBatchEvents(validatedEvents);
      
      return { success: true, count: events.length };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  async trackView(data: any, req: any) {
    const event: Partial<AnalyticsEvent> = {
      eventType: 'view',
      data: {
        contentType: data.contentType,
        contentId: data.contentId,
        viewDuration: data.viewDuration,
        scrollDepth: data.scrollDepth,
        referrer: data.referrer,
      },
    };
    return this.trackEvent(event, req);
  }

  async trackEngagement(data: any, req: any) {
    const event: Partial<AnalyticsEvent> = {
      eventType: 'engagement',
      data: {
        action: data.action,
        targetType: data.targetType,
        targetId: data.targetId,
        metadata: data.metadata,
      },
    };
    return this.trackEvent(event, req);
  }

  async trackPurchase(data: any, req: any) {
    const event: Partial<AnalyticsEvent> = {
      eventType: 'purchase',
      data: {
        productId: data.productId,
        orderId: data.orderId,
        amount: data.amount,
        currency: data.currency || 'USD',
        quantity: data.quantity || 1,
        paymentMethod: data.paymentMethod,
        conversionPath: data.conversionPath,
      },
    };
    return this.trackEvent(event, req);
  }

  async trackStream(data: any, req: any) {
    const event: Partial<AnalyticsEvent> = {
      eventType: 'stream',
      data: {
        action: data.action,
        streamId: data.streamId,
        duration: data.duration,
        viewerCount: data.viewerCount,
        messageContent: data.messageContent,
      },
    };
    return this.trackEvent(event, req);
  }

  async trackSession(data: any, req: any) {
    const event: Partial<AnalyticsEvent> = {
      eventType: 'session',
      data: {
        action: data.action,
        duration: data.duration,
        pageViews: data.pageViews,
        device: data.device,
      },
    };
    return this.trackEvent(event, req);
  }

  private enrichEvent(eventData: Partial<AnalyticsEvent>, req: any): AnalyticsEvent {
    const now = new Date();
    
    return {
      ...eventData,
      eventId: eventData.eventId || uuidv4(),
      userId: eventData.userId || req.user?.id || 'anonymous',
      sessionId: eventData.sessionId || req.headers['x-session-id'] || uuidv4(),
      timestamp: eventData.timestamp || now,
      schemaVersion: eventData.schemaVersion || this.currentSchemaVersion,
      platform: eventData.platform || this.detectPlatform(req),
      userAgent: eventData.userAgent || req.headers['user-agent'],
      ipAddress: eventData.ipAddress || req.ip,
    } as AnalyticsEvent;
  }

  private validateEvent(event: AnalyticsEvent): AnalyticsEvent {
    const schema = SCHEMA_VERSIONS[event.schemaVersion];
    if (!schema) {
      throw new Error(`Unsupported schema version: ${event.schemaVersion}`);
    }

    const eventSchema = schema[event.eventType];
    if (!eventSchema) {
      throw new Error(`Unsupported event type: ${event.eventType}`);
    }

    // Validate required fields exist
    for (const field of eventSchema) {
      if (!(field in event.data)) {
        console.warn(`Missing field ${field} in ${event.eventType} event`);
      }
    }

    return event;
  }

  private detectPlatform(req: any): 'web' | 'mobile' | 'api' {
    const userAgent = req.headers['user-agent'] || '';
    if (userAgent.includes('Mobile') || userAgent.includes('Android') || userAgent.includes('iPhone')) {
      return 'mobile';
    }
    if (req.headers['x-api-client']) {
      return 'api';
    }
    return 'web';
  }

  private async storeEvent(event: AnalyticsEvent) {
    await this.prisma.analyticsEvent.create({
      data: {
        eventId: event.eventId,
        eventType: event.eventType,
        userId: event.userId,
        sessionId: event.sessionId,
        timestamp: event.timestamp,
        schemaVersion: event.schemaVersion,
        platform: event.platform,
        userAgent: event.userAgent,
        ipAddress: event.ipAddress,
        eventData: event.data,
      },
    });
  }

  private async storeBatchEvents(events: AnalyticsEvent[]) {
    await this.prisma.analyticsEvent.createMany({
      data: events.map(event => ({
        eventId: event.eventId,
        eventType: event.eventType,
        userId: event.userId,
        sessionId: event.sessionId,
        timestamp: event.timestamp,
        schemaVersion: event.schemaVersion,
        platform: event.platform,
        userAgent: event.userAgent,
        ipAddress: event.ipAddress,
        eventData: event.data,
      })),
    });
  }
}