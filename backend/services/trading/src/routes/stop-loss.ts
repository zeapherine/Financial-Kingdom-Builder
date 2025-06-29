import { Router, Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/app-error';
import { PerpetualPortfolioService } from '../services/perpetual-portfolio.service';
import { PositionSide } from '../types/perpetual';
import { logger } from '../utils/logger';

const router = Router();
const portfolioService = new PerpetualPortfolioService();

// Update stop-loss for a position
router.put('/:positionId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    const { positionId } = req.params;
    const { stopLoss } = req.body;
    
    if (!userId) {
      throw new AppError('User ID required', 400);
    }
    
    const updatedPosition = await portfolioService.updateStopLoss(userId, positionId, stopLoss);
    
    res.json({
      success: true,
      message: stopLoss ? 'Stop-loss updated successfully' : 'Stop-loss removed successfully',
      data: {
        position: updatedPosition,
        stopLoss: updatedPosition.stopLoss,
      }
    });
  } catch (error) {
    next(error);
  }
});

// Get positions with stop-loss analysis
router.get('/analysis', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    const isPaperTrading = req.query.paper !== 'false';
    
    if (!userId) {
      throw new AppError('User ID required', 400);
    }
    
    const analysis = await portfolioService.getPositionsWithStopLoss(userId, isPaperTrading);
    
    res.json({
      success: true,
      message: 'Stop-loss analysis retrieved',
      data: analysis
    });
  } catch (error) {
    next(error);
  }
});

// Get stop-loss recommendations for a position
router.get('/recommendations/:positionId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    const { positionId } = req.params;
    
    if (!userId) {
      throw new AppError('User ID required', 400);
    }
    
    // Get position and user tier info
    const tierInfo = await portfolioService.getUserTierInfo(userId);
    const portfolio = await portfolioService.getPortfolio(userId, true);
    const position = portfolio.positions.find(p => p.id === positionId);
    
    if (!position) {
      throw new AppError('Position not found', 404);
    }
    
    // Calculate stop-loss recommendations
    const currentPrice = position.markPrice;
    const tier = tierInfo.tier;
    
    const recommendations = {
      conservative: {
        price: tier.limits.stopLossPercentage > 0 ? 
          (position.side === PositionSide.LONG ? 
            currentPrice * (1 - tier.limits.stopLossPercentage / 100) :
            currentPrice * (1 + tier.limits.stopLossPercentage / 100)) : null,
        description: `${tier.limits.stopLossPercentage}% protection (${tier.tierName} requirement)`,
        riskLevel: 'low',
      },
      moderate: {
        price: position.side === PositionSide.LONG ? 
          currentPrice * 0.95 : // 5% stop-loss
          currentPrice * 1.05,
        description: '5% stop-loss (moderate protection)',
        riskLevel: 'medium',
      },
      aggressive: {
        price: position.side === PositionSide.LONG ? 
          currentPrice * 0.90 : // 10% stop-loss
          currentPrice * 1.10,
        description: '10% stop-loss (wider swing room)',
        riskLevel: 'high',
      },
    };
    
    // Calculate potential loss for each recommendation
    Object.values(recommendations).forEach((rec: any) => {
      if (rec.price) {
        const priceDiff = position.side === PositionSide.LONG ? 
          position.entryPrice - rec.price :
          rec.price - position.entryPrice;
        rec.potentialLoss = (priceDiff / position.entryPrice) * position.size * position.leverage;
      }
    });
    
    res.json({
      success: true,
      message: 'Stop-loss recommendations generated',
      data: {
        position: {
          id: position.id,
          symbol: position.symbol,
          side: position.side,
          currentPrice,
          entryPrice: position.entryPrice,
          currentStopLoss: position.stopLoss,
        },
        tierRequirements: {
          mandatoryStopLoss: tier.limits.forceStopLoss,
          maxStopLossPercentage: tier.limits.stopLossPercentage,
          tierName: tier.tierName,
        },
        recommendations,
        warnings: {
          nearLiquidation: Math.abs(currentPrice - position.liquidationPrice) / currentPrice < 0.1,
          noStopLoss: !position.stopLoss && tier.limits.forceStopLoss,
        },
      }
    });
  } catch (error) {
    next(error);
  }
});

export { router as stopLossRouter };