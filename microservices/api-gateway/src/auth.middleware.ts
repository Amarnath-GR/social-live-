import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import axios from 'axios';

@Injectable()
export class AuthMiddleware implements NestMiddleware {
  private authServiceUrl = process.env.AUTH_SERVICE_URL || 'http://localhost:3001';

  async use(req: Request, res: Response, next: NextFunction) {
    const publicPaths = ['/auth/login', '/auth/register', '/health'];
    
    if (publicPaths.some(path => req.path.startsWith(path))) {
      return next();
    }

    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ success: false, error: 'No token provided' });
    }

    try {
      const response = await axios.post(`${this.authServiceUrl}/verify`, 
        { token },
        { headers: { 'X-Service-Name': 'api-gateway' } }
      );

      if (response.data.success) {
        req['user'] = response.data.data.user;
        next();
      } else {
        res.status(401).json({ success: false, error: 'Invalid token' });
      }
    } catch (error) {
      res.status(401).json({ success: false, error: 'Token verification failed' });
    }
  }
}