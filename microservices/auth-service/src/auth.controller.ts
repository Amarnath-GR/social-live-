import { Controller, Post, Body, Get } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller()
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('register')
  async register(@Body() body: { email: string; password: string; username: string; fullName?: string }) {
    return this.authService.register(body);
  }

  @Post('login')
  async login(@Body() body: { email: string; password: string }) {
    return this.authService.login(body.email, body.password);
  }

  @Post('refresh')
  async refresh(@Body() body: { refreshToken: string }) {
    return this.authService.refreshToken(body.refreshToken);
  }

  @Post('verify')
  async verify(@Body() body: { token: string }) {
    return this.authService.verifyToken(body.token);
  }

  @Post('revoke')
  async revoke(@Body() body: { refreshToken: string }) {
    return this.authService.revokeToken(body.refreshToken);
  }

  @Get('health')
  health() {
    return { success: true, service: 'auth-service', timestamp: new Date() };
  }
}