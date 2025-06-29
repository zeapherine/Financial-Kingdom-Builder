import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import rateLimit from 'express-rate-limit';

import { logger } from './utils/logger';
import { errorHandler } from './middleware/error-handler';
import { validateAuth } from './middleware/auth';
import { healthRouter } from './routes/health';
import { portfolioRouter } from './routes/portfolio';
import { ordersRouter } from './routes/orders';
import { marketDataRouter } from './routes/market-data';
import { userTierRouter } from './routes/user-tier';
import { stopLossRouter } from './routes/stop-loss';
import { AppError } from './utils/app-error';
import { PerpetualMarketDataService } from './services/perpetual-market-data.service';
import { PerpetualPortfolioService } from './services/perpetual-portfolio.service';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Initialize services
const marketDataService = new PerpetualMarketDataService();
const portfolioService = new PerpetualPortfolioService();

// Connect market data updates to portfolio service
marketDataService.on('priceUpdate', async (data) => {
  try {
    await portfolioService.updatePositionPrices(data.symbol, data.markPrice);
    logger.debug(`Updated positions for ${data.symbol} at price ${data.markPrice}`);
  } catch (error) {
    logger.error('Failed to update position prices:', error);
  }
});

// Connect funding rate updates to portfolio service
marketDataService.on('fundingUpdate', async (data) => {
  try {
    await portfolioService.applyFundingPayments(data.symbol, data.rate);
    logger.info(`Applied funding payments for ${data.symbol} at rate ${data.rate}`);
  } catch (error) {
    logger.error('Failed to apply funding payments:', error);
  }
});

app.use(helmet());
app.use(cors());

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Too many trading requests from this IP',
});

app.use(limiter);
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.use('/health', healthRouter);
app.use('/portfolio', validateAuth, portfolioRouter);
app.use('/orders', validateAuth, ordersRouter);
app.use('/market-data', marketDataRouter);
app.use('/user-tier', validateAuth, userTierRouter);
app.use('/stop-loss', validateAuth, stopLossRouter);

app.get('/', (req, res) => {
  res.json({
    service: 'Perpetual Trading Service',
    version: '1.0.0',
    status: 'healthy',
    timestamp: new Date().toISOString(),
    features: [
      'Paper trading with perpetual contracts',
      'Real-time market data simulation',
      'Funding rate calculations',
      'Risk management and liquidation',
      'Extended Exchange integration ready'
    ],
    endpoints: {
      portfolio: '/portfolio',
      orders: '/orders',
      marketData: '/market-data',
      health: '/health'
    }
  });
});

app.use('*', (req, res, next) => {
  next(new AppError(`Route ${req.originalUrl} not found`, 404));
});

app.use(errorHandler);

const server = app.listen(PORT, () => {
  logger.info(`Perpetual Trading Service running on port ${PORT}`);
  logger.info('Services initialized:');
  logger.info('- Paper trading engine ready');
  logger.info('- Market data simulation active');
  logger.info('- Funding rate calculations enabled');
  logger.info('- Extended Exchange integration prepared');
});

process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  
  // Cleanup services
  marketDataService.cleanup();
  
  server.close(() => {
    logger.info('Perpetual Trading Service terminated');
  });
});

export default app;