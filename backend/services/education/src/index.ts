import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import rateLimit from 'express-rate-limit';

import { logger } from './utils/logger';
import { errorHandler } from './middleware/error-handler';
import { validateAuth } from './middleware/auth';
import { healthRouter } from './routes/health';
import { modulesRouter } from './routes/modules';
import { progressRouter } from './routes/progress';
import { AppError } from './utils/app-error';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3003;

app.use(helmet());
app.use(cors());

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Too many education requests from this IP',
});

app.use(limiter);
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.use('/health', healthRouter);
app.use('/modules', validateAuth, modulesRouter);
app.use('/progress', validateAuth, progressRouter);

app.get('/', (req, res) => {
  res.json({
    service: 'Education Service',
    version: '1.0.0',
    status: 'healthy',
    timestamp: new Date().toISOString(),
    description: 'Handles learning content management and progress tracking for Financial Kingdom Builder',
  });
});

app.use('*', (req, res, next) => {
  next(new AppError(`Route ${req.originalUrl} not found`, 404));
});

app.use(errorHandler);

const server = app.listen(PORT, () => {
  logger.info(`Education Service running on port ${PORT}`);
});

process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
  });
});

export default app;