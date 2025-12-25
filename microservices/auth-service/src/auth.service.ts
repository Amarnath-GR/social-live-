import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from './prisma.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async register(data: { email: string; password: string; username: string; fullName?: string }) {
    try {
      const hashedPassword = await bcrypt.hash(data.password, 12);
      
      const user = await this.prisma.user.create({
        data: {
          email: data.email,
          username: data.username,
          fullName: data.fullName,
          passwordHash: hashedPassword,
        },
      });

      const tokens = await this.generateTokens(user.id);
      
      return {
        success: true,
        data: {
          user: { id: user.id, email: user.email, username: user.username, role: user.role },
          tokens,
        },
      };
    } catch (error) {
      return { success: false, error: 'Registration failed' };
    }
  }

  async login(email: string, password: string) {
    try {
      const user = await this.prisma.user.findUnique({ where: { email } });
      
      if (!user || !await bcrypt.compare(password, user.passwordHash)) {
        return { success: false, error: 'Invalid credentials' };
      }

      const tokens = await this.generateTokens(user.id);
      
      return {
        success: true,
        data: {
          user: { id: user.id, email: user.email, username: user.username, role: user.role },
          tokens,
        },
      };
    } catch (error) {
      return { success: false, error: 'Login failed' };
    }
  }

  async verifyToken(token: string) {
    try {
      const payload = this.jwtService.verify(token);
      const user = await this.prisma.user.findUnique({ where: { id: payload.sub } });
      
      if (!user) {
        return { success: false, error: 'User not found' };
      }

      return {
        success: true,
        data: { user: { id: user.id, email: user.email, username: user.username, role: user.role } },
      };
    } catch (error) {
      return { success: false, error: 'Invalid token' };
    }
  }

  async refreshToken(refreshToken: string) {
    try {
      const session = await this.prisma.userSession.findFirst({
        where: { refreshTokenHash: await bcrypt.hash(refreshToken, 12) },
        include: { user: true },
      });

      if (!session || session.expiresAt < new Date()) {
        return { success: false, error: 'Invalid refresh token' };
      }

      const tokens = await this.generateTokens(session.userId);
      
      return { success: true, data: { tokens } };
    } catch (error) {
      return { success: false, error: 'Token refresh failed' };
    }
  }

  async revokeToken(refreshToken: string) {
    try {
      await this.prisma.userSession.deleteMany({
        where: { refreshTokenHash: await bcrypt.hash(refreshToken, 12) },
      });
      return { success: true, message: 'Token revoked' };
    } catch (error) {
      return { success: false, error: 'Token revocation failed' };
    }
  }

  private async generateTokens(userId: string) {
    const payload = { sub: userId };
    const accessToken = this.jwtService.sign(payload);
    const refreshToken = this.jwtService.sign(payload, { expiresIn: '7d' });

    await this.prisma.userSession.create({
      data: {
        userId,
        refreshTokenHash: await bcrypt.hash(refreshToken, 12),
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
    });

    return { accessToken, refreshToken, expiresIn: 3600 };
  }
}