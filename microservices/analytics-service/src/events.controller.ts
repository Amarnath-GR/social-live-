import { Controller, Post, Body, Get, Query, Req } from '@nestjs/common';
import { EventsService } from './events.service';
import { AnalyticsEvent } from './types';

@Controller('events')
export class EventsController {
  constructor(private eventsService: EventsService) {}

  @Post('track')
  async trackEvent(@Body() event: Partial<AnalyticsEvent>, @Req() req: any) {
    return this.eventsService.trackEvent(event, req);
  }

  @Post('batch')
  async trackBatchEvents(@Body() body: { events: Partial<AnalyticsEvent>[] }, @Req() req: any) {
    return this.eventsService.trackBatchEvents(body.events, req);
  }

  @Post('view')
  async trackView(@Body() data: any, @Req() req: any) {
    return this.eventsService.trackView(data, req);
  }

  @Post('engagement')
  async trackEngagement(@Body() data: any, @Req() req: any) {
    return this.eventsService.trackEngagement(data, req);
  }

  @Post('purchase')
  async trackPurchase(@Body() data: any, @Req() req: any) {
    return this.eventsService.trackPurchase(data, req);
  }

  @Post('stream')
  async trackStream(@Body() data: any, @Req() req: any) {
    return this.eventsService.trackStream(data, req);
  }

  @Post('session')
  async trackSession(@Body() data: any, @Req() req: any) {
    return this.eventsService.trackSession(data, req);
  }

  @Get('health')
  health() {
    return { success: true, service: 'analytics-service', timestamp: new Date() };
  }
}