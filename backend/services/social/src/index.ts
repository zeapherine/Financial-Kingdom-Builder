import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import rateLimit from 'express-rate-limit';

import { logger } from './utils/logger';
import { errorHandler } from './middleware/error-handler';
import { validateAuth } from './middleware/auth';
import { healthRouter } from './routes/health';
import { profilesRouter } from './routes/profiles';
import { messagesRouter } from './routes/messages';
import { friendsRouter } from './routes/friends';
import { AppError } from './utils/app-error';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3004;

app.use(helmet());
app.use(cors());

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Too many social requests from this IP',
});

app.use(limiter);
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.use('/health', healthRouter);
app.use('/profiles', validateAuth, profilesRouter);
app.use('/messages', validateAuth, messagesRouter);
app.use('/friends', validateAuth, friendsRouter);

app.get('/', (req, res) => {
  res.json({
    service: 'Social Service',
    version: '1.0.0',
    status: 'healthy',
    timestamp: new Date().toISOString(),
    description: 'Handles user profiles, messaging, and friend system for Financial Kingdom Builder',
  });
});

app.use('*', (req, res, next) => {
  next(new AppError(`Route ${req.originalUrl} not found`, 404));
});

app.use(errorHandler);

const server = app.listen(PORT, () => {
  logger.info(`Social Service running on port ${PORT}`);
});

process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
  });
});

export default app;