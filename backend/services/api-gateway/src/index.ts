import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import dotenv from 'dotenv';
import { createProxyMiddleware } from 'http-proxy-middleware';
import rateLimit from 'express-rate-limit';

import { logger } from './utils/logger';
import { errorHandler } from './middleware/error-handler';
import { authMiddleware } from './middleware/auth';
import { validateRequest } from './middleware/validation';
import { healthRouter } from './routes/health';
import { proxyConfig } from './config/proxy-config';
import { AppError } from './utils/app-error';

// Import database utilities from shared package
import { 
  initializeDatabases, 
  closeDatabases, 
  getDatabaseManager,
  createHealthChecker,
  createHealthEndpoints,
  setupGracefulShutdown
} from '@financial-kingdom/shared';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
}));

app.use(compression());

app.use(cors({
  origin: process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3000'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-api-key'],
}));

const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'),
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});

app.use(limiter);
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.use('/health', healthRouter);

app.use('/api/trading', authMiddleware, createProxyMiddleware(proxyConfig.trading));
app.use('/api/gamification', authMiddleware, createProxyMiddleware(proxyConfig.gamification));
app.use('/api/education', authMiddleware, createProxyMiddleware(proxyConfig.education));
app.use('/api/social', authMiddleware, createProxyMiddleware(proxyConfig.social));
app.use('/api/notifications', authMiddleware, createProxyMiddleware(proxyConfig.notifications));

app.get('/', (req, res) => {
  res.json({
    message: 'Financial Kingdom Builder API Gateway',
    version: '1.0.0',
    status: 'healthy',
    timestamp: new Date().toISOString(),
  });
});

app.use('*', (req, res, next) => {
  next(new AppError(`Route ${req.originalUrl} not found`, 404));
});

app.use(errorHandler);

// Initialize database connections and health monitoring
async function startServer() {
  try {
    // Initialize database connections
    logger.info('Initializing database connections...');
    await initializeDatabases();
    
    // Create and initialize health checker
    const databaseManager = getDatabaseManager();
    const healthChecker = createHealthChecker(databaseManager);
    await healthChecker.initialize();
    
    // Add enhanced health endpoints
    const healthEndpoints = createHealthEndpoints();
    app.get('/health/detailed', healthEndpoints.healthDetailed);
    app.get('/ready', healthEndpoints.ready);
    app.get('/live', healthEndpoints.live);
    app.get('/metrics', healthEndpoints.metrics);
    app.get('/metrics/history', healthEndpoints.metricsHistory);
    
    // Start periodic monitoring
    const monitoringInterval = healthChecker.startPeriodicMonitoring(60000); // Every minute
    
    // Setup graceful shutdown for databases
    setupGracefulShutdown();
    
    const server = app.listen(PORT, () => {
      logger.info(`API Gateway running on port ${PORT}`);
      logger.info(`Environment: ${process.env.NODE_ENV}`);
      logger.info('Database connections established');
      logger.info('Health monitoring started');
    });

    // Enhanced graceful shutdown
    const gracefulShutdown = async (signal: string) => {
      logger.info(`${signal} received, shutting down gracefully`);
      
      // Stop health monitoring
      if (monitoringInterval) {
        healthChecker.stopPeriodicMonitoring(monitoringInterval);
      }
      
      // Close HTTP server
      server.close(async () => {
        try {
          // Close database connections
          await closeDatabases();
          logger.info('Database connections closed');
          logger.info('Process terminated gracefully');
          process.exit(0);
        } catch (error) {
          logger.error('Error during graceful shutdown:', error);
          process.exit(1);
        }
      });
      
      // Force exit after 30 seconds
      setTimeout(() => {
        logger.error('Forceful shutdown after timeout');
        process.exit(1);
      }, 30000);
    };

    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));

    process.on('uncaughtException', async (err) => {
      logger.error('Uncaught Exception:', err);
      await gracefulShutdown('UNCAUGHT_EXCEPTION');
    });

    process.on('unhandledRejection', async (err) => {
      logger.error('Unhandled Rejection:', err);
      await gracefulShutdown('UNHANDLED_REJECTION');
    });

  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Start the server
startServer();

export default app;