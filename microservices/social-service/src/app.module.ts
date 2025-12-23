import { Module } from '@nestjs/common';
import { PostsController } from './posts.controller';
import { FeedController } from './feed.controller';
import { PostsService } from './posts.service';
import { FeedService } from './feed.service';
import { PrismaService } from './prisma.service';

@Module({
  controllers: [PostsController, FeedController],
  providers: [PostsService, FeedService, PrismaService],
})
export class AppModule {}