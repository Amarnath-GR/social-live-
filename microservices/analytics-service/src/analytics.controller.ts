import { Controller, Get, Query, Req } from '@nestjs/common';
import { AnalyticsService } from './analytics.service';

@Controller('analytics')
export class AnalyticsController {
  constructor(private analyticsService: AnalyticsService) {}

  @Get('dashboard')
  async getDashboard(@Query() query: any, @Req() req: any) {
    return this.analyticsService.getDashboard(req.user?.id, query);
  }

  @Get('events')
  async getEvents(@Query() query: any) {
    return this.analyticsService.getEvents(query);
  }

  @Get('metrics')
  async getMetrics(@Query() query: any) {
    return this.analyticsService.getMetrics(query);
  }

  @Get('funnel')
  async getFunnelAnalysis(@Query() query: any) {
    return this.analyticsService.getFunnelAnalysis(query);
  }

  @Get('cohort')
  async getCohortAnalysis(@Query() query: any) {
    return this.analyticsService.getCohortAnalysis(query);
  }

  @Get('retention')
  async getRetentionAnalysis(@Query() query: any) {
    return this.analyticsService.getRetentionAnalysis(query);
  }
}