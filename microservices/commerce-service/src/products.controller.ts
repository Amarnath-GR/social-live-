import { Controller, Get, Post, Put, Delete, Body, Param, Query, Req } from '@nestjs/common';
import { ProductsService } from './products.service';

@Controller('products')
export class ProductsController {
  constructor(private productsService: ProductsService) {}

  @Post()
  async createProduct(@Body() body: any, @Req() req: any) {
    return this.productsService.createProduct({ ...body, sellerId: req.user.id });
  }

  @Get()
  async getProducts(@Query() query: any) {
    return this.productsService.getProducts(query);
  }

  @Get(':id')
  async getProduct(@Param('id') id: string) {
    return this.productsService.getProduct(id);
  }

  @Put(':id')
  async updateProduct(@Param('id') id: string, @Body() body: any, @Req() req: any) {
    return this.productsService.updateProduct(id, body, req.user.id);
  }

  @Delete(':id')
  async deleteProduct(@Param('id') id: string, @Req() req: any) {
    return this.productsService.deleteProduct(id, req.user.id);
  }
}