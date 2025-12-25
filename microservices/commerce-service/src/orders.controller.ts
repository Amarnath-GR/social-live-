import { Controller, Get, Post, Body, Param, Req } from '@nestjs/common';
import { OrdersService } from './orders.service';

@Controller('orders')
export class OrdersController {
  constructor(private ordersService: OrdersService) {}

  @Post()
  async createOrder(@Body() body: { productId: string; quantity: number }, @Req() req: any) {
    return this.ordersService.createOrder(req.user.id, body);
  }

  @Get()
  async getOrders(@Req() req: any) {
    return this.ordersService.getUserOrders(req.user.id);
  }

  @Get(':id')
  async getOrder(@Param('id') id: string, @Req() req: any) {
    return this.ordersService.getOrder(id, req.user.id);
  }

  @Post(':id/cancel')
  async cancelOrder(@Param('id') id: string, @Req() req: any) {
    return this.ordersService.cancelOrder(id, req.user.id);
  }
}