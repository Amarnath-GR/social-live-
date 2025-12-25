import { Module, MiddlewareConsumer } from '@nestjs/common';
import { ProxyController } from './proxy.controller';
import { AuthMiddleware } from './auth.middleware';

@Module({
  controllers: [ProxyController],
  providers: [AuthMiddleware],
})
export class AppModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(AuthMiddleware).forRoutes('*');
  }
}