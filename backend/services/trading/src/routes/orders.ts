import { Router, Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/app-error';
import { PerpetualPortfolioService } from '../services/perpetual-portfolio.service';
import { PerpetualMarketDataService } from '../services/perpetual-market-data.service';
import { OpenPositionRequest, ClosePositionRequest } from '../types/perpetual';
import { logger } from '../utils/logger';

const router = Router();
const portfolioService = new PerpetualPortfolioService();
const marketDataService = new PerpetualMarketDataService();

// Open new position
router.post('/position/open', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;

    if (!userId) {
      throw new AppError('User ID required', 400);
    }

    const openRequest: OpenPositionRequest = {
      symbol: req.body.symbol,
      side: req.body.side,
      size: parseFloat(req.body.size),
      leverage: parseFloat(req.body.leverage),
      orderType: req.body.orderType || 'market',
      price: req.body.price ? parseFloat(req.body.price) : undefined,
      stopLoss: req.body.stopLoss ? parseFloat(req.body.stopLoss) : undefined,
      takeProfit: req.body.takeProfit ? parseFloat(req.body.takeProfit) : undefined,
      isPaperTrading: req.body.isPaperTrading !== false // Default to paper trading
    };

    // Validate required fields
    if (!openRequest.symbol || !openRequest.side || !openRequest.size || !openRequest.leverage) {
      throw new AppError('Missing required fields: symbol, side, size, leverage', 400);
    }

    // Get current market price
    const marketData = await marketDataService.getMarketData(openRequest.symbol);
    if (!marketData) {
      throw new AppError(`Market data not available for ${openRequest.symbol}`, 404);
    }

    const currentPrice = openRequest.price || marketData.price;
    const position = await portfolioService.openPosition(userId, openRequest, currentPrice);

    logger.info(`Opened position for user ${userId}: ${position.id}`);

    res.json({
      success: true,
      message: 'Position opened successfully',
      data: position
    });
  } catch (error) {
    next(error);
  }
});

// Close position
router.post('/position/close', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;

    if (!userId) {
      throw new AppError('User ID required', 400);
    }

    const closeRequest: ClosePositionRequest = {
      positionId: req.body.positionId,
      size: req.body.size ? parseFloat(req.body.size) : undefined,
      orderType: req.body.orderType || 'market',
      price: req.body.price ? parseFloat(req.body.price) : undefined
    };

    if (!closeRequest.positionId) {
      throw new AppError('Position ID required', 400);
    }

    // Get current market price for the position's symbol
    // For now, we'll use a placeholder - in real implementation we'd get the symbol from the position
    const currentPrice = closeRequest.price || 45000; // Placeholder

    const position = await portfolioService.closePosition(userId, closeRequest, currentPrice);

    logger.info(`Closed position for user ${userId}: ${position.id}`);

    res.json({
      success: true,
      message: 'Position closed successfully',
      data: position
    });
  } catch (error) {
    next(error);
  }
});

// Simulate price movement (for demo)
router.post('/simulate/price', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { symbol, price } = req.body;

    if (!symbol || !price) {
      throw new AppError('Symbol and price required', 400);
    }

    await marketDataService.simulatePriceUpdate(symbol, parseFloat(price));

    res.json({
      success: true,
      message: `Price updated for ${symbol}`,
      data: {
        symbol,
        newPrice: parseFloat(price)
      }
    });
  } catch (error) {
    next(error);
  }
});

// Apply funding payments (for demo)
router.post('/funding/apply', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { symbol } = req.body;

    if (!symbol) {
      throw new AppError('Symbol required', 400);
    }

    const marketData = await marketDataService.getMarketData(symbol);
    if (!marketData) {
      throw new AppError(`Market data not available for ${symbol}`, 404);
    }

    const fundingPayments = await portfolioService.applyFundingPayments(symbol, marketData.fundingRate);

    res.json({
      success: true,
      message: `Applied funding payments for ${symbol}`,
      data: {
        symbol,
        fundingRate: marketData.fundingRate,
        paymentsCount: fundingPayments.length,
        payments: fundingPayments
      }
    });
  } catch (error) {
    next(error);
  }
});

// Get order history (placeholder)
router.get('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;

    if (!userId) {
      throw new AppError('User ID required', 400);
    }

    // Placeholder - in real implementation, this would fetch order history
    res.json({
      success: true,
      message: 'Order history service - to be implemented with Extended Exchange',
      data: {
        userId,
        orders: []
      }
    });
  } catch (error) {
    next(error);
  }
});

export { router as ordersRouter };