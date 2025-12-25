import { Controller, Get, Query, Req } from '@nestjs/common';
import { FeedService } from './feed.service';

@Controller('feed')
export class FeedController {
  constructor(private feedService: FeedService) {}

  @Get()
  async getFeed(@Query() query: any, @Req() req: any) {
    return this.feedService.getPersonalizedFeed(req.user.id, query);
  }

  @Get('following')
  async getFollowingFeed(@Query() query: any, @Req() req: any) {
    return this.feedService.getFollowingFeed(req.user.id, query);
  }

  @Get('trending')
  async getTrendingFeed(@Query() query: any) {
    return this.feedService.getTrendingFeed(query);
  }
}