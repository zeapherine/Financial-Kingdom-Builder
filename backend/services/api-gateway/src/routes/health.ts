import { Router, Request, Response } from 'express';
import axios from 'axios';
import { logger } from '../utils/logger';

const router = Router();

interface HealthStatus {
  status: 'healthy' | 'unhealthy';
  timestamp: string;
  uptime: number;
  environment: string;
  version: string;
  services: Record<string, ServiceHealth>;
  memory: {
    used: number;
    total: number;
    percentage: number;
  };
}

interface ServiceHealth {
  status: 'healthy' | 'unhealthy' | 'unknown';
  responseTime?: number;
  lastChecked: string;
}

const serviceUrls = {
  trading: process.env.TRADING_SERVICE_URL || 'http://localhost:3001',
  gamification: process.env.GAMIFICATION_SERVICE_URL || 'http://localhost:3002',
  education: process.env.EDUCATION_SERVICE_URL || 'http://localhost:3003',
  social: process.env.SOCIAL_SERVICE_URL || 'http://localhost:3004',
  notifications: process.env.NOTIFICATION_SERVICE_URL || 'http://localhost:3005',
};

const checkServiceHealth = async (serviceUrl: string): Promise<ServiceHealth> => {
  const startTime = Date.now();
  
  try {
    const response = await axios.get(`${serviceUrl}/health`, {
      timeout: 5000,
    });
    
    const responseTime = Date.now() - startTime;
    
    return {
      status: response.status === 200 ? 'healthy' : 'unhealthy',
      responseTime,
      lastChecked: new Date().toISOString(),
    };
  } catch (error) {
    logger.warn(`Health check failed for ${serviceUrl}:`, error);
    return {
      status: 'unhealthy',
      responseTime: Date.now() - startTime,
      lastChecked: new Date().toISOString(),
    };
  }
};

router.get('/', async (req: Request, res: Response) => {
  try {
    const memoryUsage = process.memoryUsage();
    const memoryUsed = memoryUsage.heapUsed;
    const memoryTotal = memoryUsage.heapTotal;

    const services: Record<string, ServiceHealth> = {};
    
    for (const [serviceName, serviceUrl] of Object.entries(serviceUrls)) {
      services[serviceName] = await checkServiceHealth(serviceUrl);
    }

    const allServicesHealthy = Object.values(services).every(
      service => service.status === 'healthy'
    );

    const healthStatus: HealthStatus = {
      status: allServicesHealthy ? 'healthy' : 'unhealthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV || 'development',
      version: '1.0.0',
      services,
      memory: {
        used: memoryUsed,
        total: memoryTotal,
        percentage: Math.round((memoryUsed / memoryTotal) * 100),
      },
    };

    const statusCode = healthStatus.status === 'healthy' ? 200 : 503;
    res.status(statusCode).json(healthStatus);
  } catch (error) {
    logger.error('Health check error:', error);
    res.status(500).json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      error: 'Health check failed',
    });
  }
});

router.get('/ready', async (req: Request, res: Response) => {
  try {
    const services: Record<string, ServiceHealth> = {};
    
    for (const [serviceName, serviceUrl] of Object.entries(serviceUrls)) {
      services[serviceName] = await checkServiceHealth(serviceUrl);
    }

    const allServicesReady = Object.values(services).every(
      service => service.status === 'healthy'
    );

    if (allServicesReady) {
      res.status(200).json({
        status: 'ready',
        timestamp: new Date().toISOString(),
        services,
      });
    } else {
      res.status(503).json({
        status: 'not ready',
        timestamp: new Date().toISOString(),
        services,
      });
    }
  } catch (error) {
    logger.error('Readiness check error:', error);
    res.status(500).json({
      status: 'not ready',
      timestamp: new Date().toISOString(),
      error: 'Readiness check failed',
    });
  }
});

router.get('/live', (req: Request, res: Response) => {
  res.status(200).json({
    status: 'alive',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

export { router as healthRouter };