import { Module } from '@nestjs/common';
import { ProductsController } from './products.controller';
import { OrdersController } from './orders.controller';
import { ProductsService } from './products.service';
import { OrdersService } from './orders.service';
import { PrismaService } from './prisma.service';
import { ServiceClient } from '../../../shared/service-client';

@Module({
  controllers: [ProductsController, OrdersController],
  providers: [
    ProductsService,
    OrdersService,
    PrismaService,
    {
      provide: 'WalletService',
      useValue: new ServiceClient(process.env.WALLET_SERVICE_URL || 'http://localhost:3003', 'commerce-service'),
    },
  ],
})
export class AppModule {}