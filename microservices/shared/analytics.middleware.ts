import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import axios from 'axios';

@Injectable()
export class AnalyticsMiddleware implements NestMiddleware {
  private analyticsServiceUrl = process.env.ANALYTICS_SERVICE_URL || 'http://localhost:3006';

  async use(req: Request, res: Response, next: NextFunction) {
    const startTime = Date.now();

    // Track request
    this.trackEvent({
      eventType: 'api_request',
      data: {
        method: req.method,
        path: req.path,
        userAgent: req.headers['user-agent'],
        ip: req.ip,
      },
      userId: req['user']?.id,
      sessionId: req.headers['x-session-id'],
    });

    // Override res.json to track responses
    const originalJson = res.json;
    res.json = function(body) {
      const duration = Date.now() - startTime;
      
      // Track response
      this.trackEvent({
        eventType: 'api_response',
        data: {
          method: req.method,
          path: req.path,
          statusCode: res.statusCode,
          duration,
          success: res.statusCode < 400,
        },
        userId: req['user']?.id,
        sessionId: req.headers['x-session-id'],
      });

      return originalJson.call(this, body);
    }.bind(this);

    next();
  }

  private async trackEvent(event: any) {
    try {
      await axios.post(`${this.analyticsServiceUrl}/events/track`, event, {
        headers: { 'X-Service-Name': 'middleware' },
        timeout: 1000,
      });
    } catch (error) {
      // Silently fail - don't break the main request
      console.warn('Analytics tracking failed:', error.message);
    }
  }
}