export interface BaseEvent {
  eventId: string;
  userId: string;
  sessionId: string;
  timestamp: Date;
  schemaVersion: string;
  platform: 'web' | 'mobile' | 'api';
  userAgent?: string;
  ipAddress?: string;
}

export interface ViewEvent extends BaseEvent {
  eventType: 'view';
  data: {
    contentType: 'post' | 'profile' | 'stream' | 'product';
    contentId: string;
    viewDuration?: number;
    scrollDepth?: number;
    referrer?: string;
  };
}

export interface EngagementEvent extends BaseEvent {
  eventType: 'engagement';
  data: {
    action: 'like' | 'unlike' | 'share' | 'comment' | 'follow' | 'unfollow';
    targetType: 'post' | 'user' | 'stream' | 'product';
    targetId: string;
    metadata?: Record<string, any>;
  };
}

export interface PurchaseEvent extends BaseEvent {
  eventType: 'purchase';
  data: {
    productId: string;
    orderId: string;
    amount: number;
    currency: string;
    quantity: number;
    paymentMethod: string;
    conversionPath?: string[];
  };
}

export interface StreamEvent extends BaseEvent {
  eventType: 'stream';
  data: {
    action: 'start' | 'join' | 'leave' | 'end' | 'message';
    streamId: string;
    duration?: number;
    viewerCount?: number;
    messageContent?: string;
  };
}

export interface SessionEvent extends BaseEvent {
  eventType: 'session';
  data: {
    action: 'start' | 'end' | 'heartbeat';
    duration?: number;
    pageViews?: number;
    device?: {
      type: string;
      os: string;
      browser?: string;
    };
  };
}

export type AnalyticsEvent = ViewEvent | EngagementEvent | PurchaseEvent | StreamEvent | SessionEvent;

export const SCHEMA_VERSIONS = {
  '1.0.0': {
    view: ['contentType', 'contentId'],
    engagement: ['action', 'targetType', 'targetId'],
    purchase: ['productId', 'orderId', 'amount', 'currency'],
    stream: ['action', 'streamId'],
    session: ['action'],
  },
  '1.1.0': {
    view: ['contentType', 'contentId', 'viewDuration', 'scrollDepth'],
    engagement: ['action', 'targetType', 'targetId', 'metadata'],
    purchase: ['productId', 'orderId', 'amount', 'currency', 'quantity', 'paymentMethod'],
    stream: ['action', 'streamId', 'duration', 'viewerCount'],
    session: ['action', 'duration', 'pageViews', 'device'],
  },
} as const;