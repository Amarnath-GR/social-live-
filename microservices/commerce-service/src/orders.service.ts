import { Injectable, Inject } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { ServiceClient } from '../../../shared/service-client';
import { AnalyticsHelper } from '../../../shared/analytics.helper';

@Injectable()
export class OrdersService {
  constructor(
    private prisma: PrismaService,
    @Inject('WalletService') private walletService: ServiceClient,
  ) {}

  async createOrder(userId: string, data: { productId: string; quantity: number }) {
    try {
      const product = await this.prisma.product.findUnique({
        where: { id: data.productId },
      });

      if (!product || product.stock < data.quantity) {
        return { success: false, error: 'Product not available' };
      }

      const totalAmount = product.price * data.quantity;

      // Check wallet balance
      const balanceResponse = await this.walletService.get('/balance', {
        'X-User-Id': userId,
      });

      if (!balanceResponse.success || balanceResponse.data.balance < totalAmount) {
        return { success: false, error: 'Insufficient balance' };
      }

      const result = await this.prisma.$transaction(async (tx) => {
        // Create order
        const order = await tx.order.create({
          data: {
            userId,
            productId: data.productId,
            quantity: data.quantity,
            totalAmount,
            status: 'PENDING',
          },
        });

        // Update product stock
        await tx.product.update({
          where: { id: data.productId },
          data: { stock: { decrement: data.quantity } },
        });

        // Process payment via wallet service
        const paymentResponse = await this.walletService.post('/transfer', {
          toUserId: product.sellerId,
          amount: totalAmount,
        }, { 'X-User-Id': userId });

        if (!paymentResponse.success) {
          throw new Error('Payment failed');
        }

        // Update order status
        const completedOrder = await tx.order.update({
          where: { id: order.id },
          data: { status: 'COMPLETED' },
        });

        // Track purchase event
        AnalyticsHelper.trackPurchase(userId, {
          productId: data.productId,
          orderId: order.id,
          amount: totalAmount,
          currency: 'USD',
          quantity: data.quantity,
          paymentMethod: 'wallet',
        });

        return completedOrder;
      });

      return { success: true, data: { order: result } };
    } catch (error) {
      return { success: false, error: error.message || 'Order creation failed' };
    }
  }

  async getUserOrders(userId: string) {
    try {
      const orders = await this.prisma.order.findMany({
        where: { userId },
        include: { product: true },
        orderBy: { createdAt: 'desc' },
      });

      return { success: true, data: { orders } };
    } catch (error) {
      return { success: false, error: 'Failed to fetch orders' };
    }
  }

  async getOrder(orderId: string, userId: string) {
    try {
      const order = await this.prisma.order.findFirst({
        where: { id: orderId, userId },
        include: { product: true },
      });

      if (!order) {
        return { success: false, error: 'Order not found' };
      }

      return { success: true, data: { order } };
    } catch (error) {
      return { success: false, error: 'Failed to fetch order' };
    }
  }

  async cancelOrder(orderId: string, userId: string) {
    try {
      const order = await this.prisma.order.findFirst({
        where: { id: orderId, userId, status: 'PENDING' },
        include: { product: true },
      });

      if (!order) {
        return { success: false, error: 'Order not found or cannot be cancelled' };
      }

      await this.prisma.$transaction(async (tx) => {
        // Update order status
        await tx.order.update({
          where: { id: orderId },
          data: { status: 'CANCELLED' },
        });

        // Restore product stock
        await tx.product.update({
          where: { id: order.productId },
          data: { stock: { increment: order.quantity } },
        });

        // Refund via wallet service
        await this.walletService.post('/transfer', {
          toUserId: userId,
          amount: order.totalAmount,
        }, { 'X-User-Id': order.product.sellerId });
      });

      return { success: true, message: 'Order cancelled and refunded' };
    } catch (error) {
      return { success: false, error: 'Failed to cancel order' };
    }
  }
}