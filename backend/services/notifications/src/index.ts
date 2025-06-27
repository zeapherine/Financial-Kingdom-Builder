import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import rateLimit from 'express-rate-limit';

import { logger } from './utils/logger';
import { errorHandler } from './middleware/error-handler';
import { validateAuth } from './middleware/auth';
import { healthRouter } from './routes/health';
import { pushRouter } from './routes/push';
import { preferencesRouter } from './routes/preferences';
import { AppError } from './utils/app-error';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3005;

app.use(helmet());
app.use(cors());

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Too many notification requests from this IP',
});

app.use(limiter);
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.use('/health', healthRouter);
app.use('/push', validateAuth, pushRouter);
app.use('/preferences', validateAuth, preferencesRouter);

app.get('/', (req, res) => {
  res.json({
    service: 'Notifications Service',
    version: '1.0.0',
    status: 'healthy',
    timestamp: new Date().toISOString(),
    description: 'Handles push notifications and user preferences for Financial Kingdom Builder',
  });
});

app.use('*', (req, res, next) => {
  next(new AppError(`Route ${req.originalUrl} not found`, 404));
});

app.use(errorHandler);

const server = app.listen(PORT, () => {
  logger.info(`Notifications Service running on port ${PORT}`);
});

process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
  });
});

export default app;