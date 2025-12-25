import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { EventsController } from './events.controller';
import { AnalyticsController } from './analytics.controller';
import { EventsService } from './events.service';
import { AnalyticsService } from './analytics.service';
import { PrismaService } from './prisma.service';

@Module({
  imports: [ScheduleModule.forRoot()],
  controllers: [EventsController, AnalyticsController],
  providers: [EventsService, AnalyticsService, PrismaService],
})
export class AppModule {}