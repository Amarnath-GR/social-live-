import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  async createProduct(data: any) {
    try {
      const product = await this.prisma.product.create({
        data: {
          sellerId: data.sellerId,
          name: data.name,
          description: data.description,
          price: data.price,
          category: data.category,
          imageUrl: data.imageUrl,
          stock: data.stock || 0,
        },
      });

      return { success: true, data: { product } };
    } catch (error) {
      return { success: false, error: 'Failed to create product' };
    }
  }

  async getProducts(query: any) {
    try {
      const { page = 1, limit = 20, category, sellerId } = query;
      const skip = (page - 1) * limit;

      const where: any = { status: 'ACTIVE' };
      if (category) where.category = category;
      if (sellerId) where.sellerId = sellerId;

      const products = await this.prisma.product.findMany({
        where,
        include: { seller: { select: { id: true, username: true, fullName: true } } },
        orderBy: { createdAt: 'desc' },
        skip,
        take: parseInt(limit),
      });

      const total = await this.prisma.product.count({ where });

      return {
        success: true,
        data: {
          products,
          pagination: { page: parseInt(page), limit: parseInt(limit), total },
        },
      };
    } catch (error) {
      return { success: false, error: 'Failed to fetch products' };
    }
  }

  async getProduct(id: string) {
    try {
      const product = await this.prisma.product.findUnique({
        where: { id },
        include: { seller: { select: { id: true, username: true, fullName: true } } },
      });

      if (!product) {
        return { success: false, error: 'Product not found' };
      }

      return { success: true, data: { product } };
    } catch (error) {
      return { success: false, error: 'Failed to fetch product' };
    }
  }

  async updateProduct(id: string, data: any, sellerId: string) {
    try {
      const product = await this.prisma.product.update({
        where: { id, sellerId },
        data: {
          name: data.name,
          description: data.description,
          price: data.price,
          stock: data.stock,
          status: data.status,
        },
      });

      return { success: true, data: { product } };
    } catch (error) {
      return { success: false, error: 'Failed to update product' };
    }
  }

  async deleteProduct(id: string, sellerId: string) {
    try {
      await this.prisma.product.update({
        where: { id, sellerId },
        data: { status: 'INACTIVE' },
      });

      return { success: true, message: 'Product deleted' };
    } catch (error) {
      return { success: false, error: 'Failed to delete product' };
    }
  }
}