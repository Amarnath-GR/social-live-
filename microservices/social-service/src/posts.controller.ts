import { Controller, Get, Post, Put, Delete, Body, Param, Query, Req } from '@nestjs/common';
import { PostsService } from './posts.service';

@Controller('posts')
export class PostsController {
  constructor(private postsService: PostsService) {}

  @Post()
  async createPost(@Body() body: any, @Req() req: any) {
    return this.postsService.createPost({ ...body, userId: req.user.id });
  }

  @Get()
  async getPosts(@Query() query: any) {
    return this.postsService.getPosts(query);
  }

  @Get(':id')
  async getPost(@Param('id') id: string) {
    return this.postsService.getPost(id);
  }

  @Put(':id')
  async updatePost(@Param('id') id: string, @Body() body: any, @Req() req: any) {
    return this.postsService.updatePost(id, body, req.user.id);
  }

  @Delete(':id')
  async deletePost(@Param('id') id: string, @Req() req: any) {
    return this.postsService.deletePost(id, req.user.id);
  }

  @Post(':id/like')
  async likePost(@Param('id') id: string, @Req() req: any) {
    return this.postsService.likePost(id, req.user.id);
  }

  @Delete(':id/like')
  async unlikePost(@Param('id') id: string, @Req() req: any) {
    return this.postsService.unlikePost(id, req.user.id);
  }

  @Get(':id/comments')
  async getComments(@Param('id') id: string, @Query() query: any) {
    return this.postsService.getComments(id, query);
  }

  @Post(':id/comments')
  async createComment(@Param('id') id: string, @Body() body: any, @Req() req: any) {
    return this.postsService.createComment(id, { ...body, userId: req.user.id });
  }
}