import { Options } from 'http-proxy-middleware';
import { Request, Response } from 'express';
import { logger } from '../utils/logger';

const createProxyOptions = (serviceUrl: string, pathRewrite?: Record<string, string>): Options => ({
  target: serviceUrl,
  changeOrigin: true,
  pathRewrite: pathRewrite || {},
  timeout: 10000,
  proxyTimeout: 10000,
  onError: (err: Error, req: Request, res: Response) => {
    logger.error(`Proxy error for ${req.url}:`, err);
    if (!res.headersSent) {
      res.status(503).json({
        error: 'Service Unavailable',
        message: 'The requested service is temporarily unavailable',
        timestamp: new Date().toISOString(),
      });
    }
  },
  onProxyReq: (_proxyReq: any, req: Request) => {
    logger.debug(`Proxying ${req.method} ${req.url} to ${serviceUrl}`);
  },
  onProxyRes: (proxyRes: any, req: Request) => {
    logger.debug(`Response from ${serviceUrl} for ${req.url}: ${proxyRes.statusCode}`);
  },
});

export const proxyConfig = {
  trading: createProxyOptions(
    process.env.TRADING_SERVICE_URL || 'http://localhost:3001',
    { '^/api/trading': '' }
  ),
  gamification: createProxyOptions(
    process.env.GAMIFICATION_SERVICE_URL || 'http://localhost:3002',
    { '^/api/gamification': '' }
  ),
  education: createProxyOptions(
    process.env.EDUCATION_SERVICE_URL || 'http://localhost:3003',
    { '^/api/education': '' }
  ),
  social: createProxyOptions(
    process.env.SOCIAL_SERVICE_URL || 'http://localhost:3004',
    { '^/api/social': '' }
  ),
  notifications: createProxyOptions(
    process.env.NOTIFICATION_SERVICE_URL || 'http://localhost:3005',
    { '^/api/notifications': '' }
  ),
};