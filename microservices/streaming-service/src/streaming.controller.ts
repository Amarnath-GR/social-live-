import { Controller, Get, Post, Body, Param, Req } from '@nestjs/common';
import { StreamingService } from './streaming.service';

@Controller()
export class StreamingController {
  constructor(private streamingService: StreamingService) {}

  @Post('start')
  async startStream(@Body() body: { title: string; description?: string }, @Req() req: any) {
    return this.streamingService.startStream(req.user.id, body);
  }

  @Post(':id/end')
  async endStream(@Param('id') id: string, @Req() req: any) {
    return this.streamingService.endStream(id, req.user.id);
  }

  @Get('live')
  async getLiveStreams() {
    return this.streamingService.getLiveStreams();
  }

  @Get(':id')
  async getStream(@Param('id') id: string) {
    return this.streamingService.getStream(id);
  }

  @Post(':id/join')
  async joinStream(@Param('id') id: string, @Req() req: any) {
    return this.streamingService.joinStream(id, req.user.id);
  }

  @Post(':id/leave')
  async leaveStream(@Param('id') id: string, @Req() req: any) {
    return this.streamingService.leaveStream(id, req.user.id);
  }
}