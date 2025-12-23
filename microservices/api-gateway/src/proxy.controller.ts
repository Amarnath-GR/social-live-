import { Controller, All, Req, Res } from '@nestjs/common';
import { Request, Response } from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';

@Controller()
export class ProxyController {
  private services = {
    auth: process.env.AUTH_SERVICE_URL || 'http://localhost:3001',
    social: process.env.SOCIAL_SERVICE_URL || 'http://localhost:3002',
    wallet: process.env.WALLET_SERVICE_URL || 'http://localhost:3003',
    streaming: process.env.STREAMING_SERVICE_URL || 'http://localhost:3004',
    commerce: process.env.COMMERCE_SERVICE_URL || 'http://localhost:3005',
    analytics: process.env.ANALYTICS_SERVICE_URL || 'http://localhost:3006',
  };

  @All('/auth/*')
  proxyAuth(@Req() req: Request, @Res() res: Response) {
    const proxy = createProxyMiddleware({
      target: this.services.auth,
      changeOrigin: true,
      pathRewrite: { '^/auth': '' },
    });
    proxy(req, res, () => {});
  }

  @All('/social/*')
  proxySocial(@Req() req: Request, @Res() res: Response) {
    const proxy = createProxyMiddleware({
      target: this.services.social,
      changeOrigin: true,
      pathRewrite: { '^/social': '' },
    });
    proxy(req, res, () => {});
  }

  @All('/wallet/*')
  proxyWallet(@Req() req: Request, @Res() res: Response) {
    const proxy = createProxyMiddleware({
      target: this.services.wallet,
      changeOrigin: true,
      pathRewrite: { '^/wallet': '' },
    });
    proxy(req, res, () => {});
  }

  @All('/streaming/*')
  proxyStreaming(@Req() req: Request, @Res() res: Response) {
    const proxy = createProxyMiddleware({
      target: this.services.streaming,
      changeOrigin: true,
      pathRewrite: { '^/streaming': '' },
    });
    proxy(req, res, () => {});
  }

  @All('/commerce/*')
  proxyCommerce(@Req() req: Request, @Res() res: Response) {
    const proxy = createProxyMiddleware({
      target: this.services.commerce,
      changeOrigin: true,
      pathRewrite: { '^/commerce': '' },
    });
    proxy(req, res, () => {});
  }

  @All('/analytics/*')
  proxyAnalytics(@Req() req: Request, @Res() res: Response) {
    const proxy = createProxyMiddleware({
      target: this.services.analytics,
      changeOrigin: true,
      pathRewrite: { '^/analytics': '' },
    });
    proxy(req, res, () => {});
  }
}