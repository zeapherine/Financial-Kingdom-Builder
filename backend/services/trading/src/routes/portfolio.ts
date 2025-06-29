import { Router, Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/app-error';
import { PerpetualPortfolioService } from '../services/perpetual-portfolio.service';
import { OpenPositionRequest, ClosePositionRequest, UpdatePositionRequest } from '../types/perpetual';
import { logger } from '../utils/logger';

const router = Router();
const portfolioService = new PerpetualPortfolioService();

// Get user portfolio
router.get('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    const isPaperTrading = req.query.paper === 'true';

    if (!userId) {
      throw new AppError('User ID required', 400);
    }

    const portfolio = await portfolioService.getPortfolio(userId, isPaperTrading);
    
    res.json({
      success: true,
      data: portfolio
    });
  } catch (error) {
    next(error);
  }
});

// Get open positions
router.get('/positions', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    const isPaperTrading = req.query.paper === 'true';

    if (!userId) {
      throw new AppError('User ID required', 400);
    }

    const positions = await portfolioService.getOpenPositions(userId, isPaperTrading);
    
    res.json({
      success: true,
      data: positions
    });
  } catch (error) {
    next(error);
  }
});

// Get risk warnings
router.get('/risk-warnings', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    const isPaperTrading = req.query.paper === 'true';

    if (!userId) {
      throw new AppError('User ID required', 400);
    }

    const warnings = await portfolioService.getRiskWarnings(userId, isPaperTrading);
    
    res.json({
      success: true,
      data: warnings
    });
  } catch (error) {
    next(error);
  }
});

// Reset portfolio (for demo purposes)
router.post('/reset', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    const isPaperTrading = req.query.paper === 'true';

    if (!userId) {
      throw new AppError('User ID required', 400);
    }

    // Create new portfolio (effectively resets)
    const portfolio = await portfolioService.getOrCreatePortfolio(userId, isPaperTrading);
    
    logger.info(`Portfolio reset for user ${userId}, paper: ${isPaperTrading}`);
    
    res.json({
      success: true,
      message: 'Portfolio reset successfully',
      data: portfolio
    });
  } catch (error) {
    next(error);
  }
});

export { router as portfolioRouter };