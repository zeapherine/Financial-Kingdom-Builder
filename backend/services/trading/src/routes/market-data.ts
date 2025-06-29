import { Router, Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/app-error';
import { PerpetualMarketDataService } from '../services/perpetual-market-data.service';
import { MarketDataSubscription } from '../types/perpetual';
import { logger } from '../utils/logger';

const router = Router();
const marketDataService = new PerpetualMarketDataService();

// Get all market data
router.get('/prices', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const marketData = await marketDataService.getAllMarketData();
    
    res.json({
      success: true,
      message: 'Current perpetual contract prices',
      data: marketData
    });
  } catch (error) {
    next(error);
  }
});

// Get market data for specific symbol
router.get('/prices/:symbol', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { symbol } = req.params;
    const marketData = await marketDataService.getMarketData(symbol.toUpperCase());
    
    if (!marketData) {
      throw new AppError(`Market data not found for symbol: ${symbol}`, 404);
    }
    
    res.json({
      success: true,
      data: marketData
    });
  } catch (error) {
    next(error);
  }
});

// Get funding rate history
router.get('/funding/:symbol', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { symbol } = req.params;
    const limit = parseInt(req.query.limit as string) || 100;
    
    const fundingHistory = await marketDataService.getFundingHistory(symbol.toUpperCase(), limit);
    
    res.json({
      success: true,
      data: {
        symbol: symbol.toUpperCase(),
        history: fundingHistory
      }
    });
  } catch (error) {
    next(error);
  }
});

// Subscribe to market data updates
router.post('/subscribe', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    
    if (!userId) {
      throw new AppError('User ID required', 400);
    }
    
    const subscription: MarketDataSubscription = {
      symbols: req.body.symbols || ['BTCUSDT', 'ETHUSDT'],
      userId,
      includeOrderBook: req.body.includeOrderBook || false,
      includeTrades: req.body.includeTrades || false,
      includeFunding: req.body.includeFunding || true
    };
    
    await marketDataService.subscribe(subscription);
    
    res.json({
      success: true,
      message: 'Subscribed to market data updates',
      data: subscription
    });
  } catch (error) {
    next(error);
  }
});

// Unsubscribe from market data updates
router.post('/unsubscribe', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    
    if (!userId) {
      throw new AppError('User ID required', 400);
    }
    
    await marketDataService.unsubscribe(userId);
    
    res.json({
      success: true,
      message: 'Unsubscribed from market data updates'
    });
  } catch (error) {
    next(error);
  }
});

// Simulate price update (for demo)
router.post('/simulate/:symbol', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { symbol } = req.params;
    const { price } = req.body;
    
    if (!price) {
      throw new AppError('Price required for simulation', 400);
    }
    
    await marketDataService.simulatePriceUpdate(symbol.toUpperCase(), parseFloat(price));
    
    res.json({
      success: true,
      message: `Price simulation updated for ${symbol}`,
      data: {
        symbol: symbol.toUpperCase(),
        newPrice: parseFloat(price)
      }
    });
  } catch (error) {
    next(error);
  }
});

// Extended Exchange integration endpoints (placeholders)
router.get('/extended/status', async (req: Request, res: Response, next: NextFunction) => {
  try {
    res.json({
      success: true,
      message: 'Extended Exchange integration status',
      data: {
        connected: false,
        lastUpdate: null,
        endpoints: {
          prices: '/api/v1/ticker/24hr',
          funding: '/api/v1/premiumIndex',
          positions: '/api/v1/positionRisk'
        },
        note: 'Extended Exchange integration will be implemented when connecting to real trading'
      }
    });
  } catch (error) {
    next(error);
  }
});

export { router as marketDataRouter };