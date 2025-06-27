import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import rateLimit from 'express-rate-limit';

import { logger } from './utils/logger';
import { errorHandler } from './middleware/error-handler';
import { validateAuth } from './middleware/auth';
import { healthRouter } from './routes/health';
import { xpRouter } from './routes/xp';
import { achievementsRouter } from './routes/achievements';
import { leaderboardRouter } from './routes/leaderboard';
import { AppError } from './utils/app-error';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3002;

app.use(helmet());
app.use(cors());

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  message: 'Too many gamification requests from this IP',
});

app.use(limiter);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/health', healthRouter);
app.use('/xp', validateAuth, xpRouter);
app.use('/achievements', validateAuth, achievementsRouter);
app.use('/leaderboard', leaderboardRouter);

app.get('/', (req, res) => {
  res.json({
    service: 'Gamification Service',
    version: '1.0.0',
    status: 'healthy',
    timestamp: new Date().toISOString(),
  });
});

app.use('*', (req, res, next) => {
  next(new AppError(`Route ${req.originalUrl} not found`, 404));
});

app.use(errorHandler);

const server = app.listen(PORT, () => {
  logger.info(`Gamification Service running on port ${PORT}`);
});

process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
  });
});

export default app;