import { Module } from '@nestjs/common';
import { StreamingController } from './streaming.controller';
import { StreamingGateway } from './streaming.gateway';
import { StreamingService } from './streaming.service';
import { PrismaService } from './prisma.service';

@Module({
  controllers: [StreamingController],
  providers: [StreamingGateway, StreamingService, PrismaService],
})
export class AppModule {}