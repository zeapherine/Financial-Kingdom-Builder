import { Router, Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/app-error';
import { PerpetualPortfolioService } from '../services/perpetual-portfolio.service';
import { UserTierService } from '../services/user-tier.service';
import { PositionStatus } from '../types/perpetual';
import { logger } from '../utils/logger';

const router = Router();
const portfolioService = new PerpetualPortfolioService();
const tierService = new UserTierService();

// Get current user tier information
router.get('/current', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    
    if (!userId) {
      throw new AppError('User ID required', 400);
    }
    
    const tierInfo = await portfolioService.getUserTierInfo(userId);
    
    res.json({
      success: true,
      message: 'User tier information retrieved',
      data: {
        currentTier: tierInfo.tier,
        progression: tierInfo.progression,
        dailyLimits: {
          maxDailyLoss: tierInfo.tier.limits.maxDailyLoss,
          used: tierInfo.dailyLossUsed,
          remaining: tierInfo.dailyLossRemaining,
        },
        tradingLimits: {
          maxLeverage: tierInfo.tier.limits.maxLeverage,
          maxPositionSize: tierInfo.tier.limits.maxPositionSize,
          maxOpenPositions: tierInfo.tier.limits.maxOpenPositions,
          maxOrderValue: tierInfo.tier.limits.maxOrderValue,
          forceStopLoss: tierInfo.tier.limits.forceStopLoss,
          stopLossPercentage: tierInfo.tier.limits.stopLossPercentage,
          allowedInstruments: tierInfo.tier.limits.allowedInstruments,
        },
        privileges: tierInfo.tier.privileges,
      }
    });
  } catch (error) {
    next(error);
  }
});

// Get all available tiers
router.get('/available', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const tiers = tierService.getAllTiers();
    
    res.json({
      success: true,
      message: 'Available tiers retrieved',
      data: {
        tiers: tiers.map(tier => ({
          name: tier.tierName,
          level: tier.level,
          requirements: tier.requirements,
          limits: tier.limits,
          privileges: tier.privileges,
        }))
      }
    });
  } catch (error) {
    next(error);
  }
});

// Get tier progression information
router.get('/progression', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    
    if (!userId) {
      throw new AppError('User ID required', 400);
    }
    
    const progression = await tierService.getTierProgression(userId);
    const profile = await tierService.getUserProfile(userId);
    
    res.json({
      success: true,
      message: 'Tier progression information retrieved',
      data: {
        currentTier: progression.currentTier,
        nextTier: progression.nextTier,
        progress: progression.progress,
        requirements: progression.requirements,
        statistics: profile.statistics,
        violations: profile.violations,
        timeInTier: Math.floor((Date.now() - profile.lastTierReview.getTime()) / (1000 * 60 * 60 * 24)),
        nextReview: profile.nextTierReview,
      }
    });
  } catch (error) {
    next(error);
  }
});

// Check tier promotion eligibility
router.post('/check-promotion', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    
    if (!userId) {
      throw new AppError('User ID required', 400);
    }
    
    const promotionCheck = await tierService.checkTierPromotion(userId);
    
    res.json({
      success: true,
      message: 'Tier promotion check completed',
      data: promotionCheck
    });
  } catch (error) {
    next(error);
  }
});

// Request tier promotion (if eligible)
router.post('/promote', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    
    if (!userId) {
      throw new AppError('User ID required', 400);
    }
    
    const promoted = await tierService.promoteUser(userId);
    
    if (promoted) {
      const newTierInfo = await portfolioService.getUserTierInfo(userId);
      
      res.json({
        success: true,
        message: 'Congratulations! Tier promotion successful',
        data: {
          newTier: newTierInfo.tier,
          message: `You have been promoted to ${newTierInfo.tier.tierName}!`,
          newLimits: newTierInfo.tier.limits,
          newPrivileges: newTierInfo.tier.privileges,
        }
      });
    } else {
      const promotionCheck = await tierService.checkTierPromotion(userId);
      
      res.json({
        success: false,
        message: 'Tier promotion not available at this time',
        data: {
          canPromote: promotionCheck.canPromote,
          missingRequirements: promotionCheck.missingRequirements,
        }
      });
    }
  } catch (error) {
    next(error);
  }
});

// Update education progress
router.post('/education-progress', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    const { modulesCompleted } = req.body;
    
    if (!userId) {
      throw new AppError('User ID required', 400);
    }
    
    if (typeof modulesCompleted !== 'number') {
      throw new AppError('modulesCompleted must be a number', 400);
    }
    
    await tierService.recordEducationProgress(userId, modulesCompleted);
    
    // Check if this unlocks tier promotion
    const promotionCheck = await tierService.checkTierPromotion(userId);
    
    res.json({
      success: true,
      message: 'Education progress updated',
      data: {
        modulesCompleted,
        promotionAvailable: promotionCheck.canPromote,
        nextTier: promotionCheck.nextTier,
        missingRequirements: promotionCheck.missingRequirements,
      }
    });
  } catch (error) {
    next(error);
  }
});

// Get tier comparison
router.get('/compare/:tierName', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    const { tierName } = req.params;
    
    if (!userId) {
      throw new AppError('User ID required', 400);
    }
    
    const currentTierInfo = await portfolioService.getUserTierInfo(userId);
    const allTiers = tierService.getAllTiers();
    const targetTier = allTiers.find(t => t.tierName.toLowerCase().replace(' ', '-') === tierName.toLowerCase());
    
    if (!targetTier) {
      throw new AppError(`Tier '${tierName}' not found`, 404);
    }
    
    res.json({
      success: true,
      message: 'Tier comparison retrieved',
      data: {
        current: {
          tier: currentTierInfo.tier,
          level: currentTierInfo.tier.level,
        },
        target: {
          tier: targetTier,
          level: targetTier.level,
        },
        comparison: {
          leverageIncrease: targetTier.limits.maxLeverage - currentTierInfo.tier.limits.maxLeverage,
          positionSizeIncrease: targetTier.limits.maxPositionSize - currentTierInfo.tier.limits.maxPositionSize,
          dailyLossIncrease: targetTier.limits.maxDailyLoss - currentTierInfo.tier.limits.maxDailyLoss,
          newPrivileges: Object.keys(targetTier.privileges).filter(
            key => targetTier.privileges[key as keyof typeof targetTier.privileges] && 
                   !currentTierInfo.tier.privileges[key as keyof typeof currentTierInfo.tier.privileges]
          ),
        },
        requirements: targetTier.requirements,
      }
    });
  } catch (error) {
    next(error);
  }
});

// Get daily usage statistics
router.get('/daily-usage', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    
    if (!userId) {
      throw new AppError('User ID required', 400);
    }
    
    const tierInfo = await portfolioService.getUserTierInfo(userId);
    const portfolio = await portfolioService.getPortfolio(userId, true); // Paper trading
    
    const openPositions = portfolio.positions.filter(p => p.status === PositionStatus.OPEN);
    const todayTrades = portfolio.positions.filter(p => {
      const today = new Date().toISOString().split('T')[0];
      const tradeDate = p.openTime.toISOString().split('T')[0];
      return tradeDate === today;
    });
    
    res.json({
      success: true,
      message: 'Daily usage statistics retrieved',
      data: {
        tier: tierInfo.tier.tierName,
        dailyLimits: {
          lossLimit: tierInfo.tier.limits.maxDailyLoss,
          lossUsed: tierInfo.dailyLossUsed,
          lossRemaining: tierInfo.dailyLossRemaining,
          lossPercentageUsed: (tierInfo.dailyLossUsed / tierInfo.tier.limits.maxDailyLoss) * 100,
        },
        positionLimits: {
          maxOpenPositions: tierInfo.tier.limits.maxOpenPositions,
          currentOpenPositions: openPositions.length,
          remainingPositions: tierInfo.tier.limits.maxOpenPositions - openPositions.length,
        },
        todayActivity: {
          tradesOpened: todayTrades.length,
          totalVolumeTraded: todayTrades.reduce((sum, trade) => sum + trade.size, 0),
          realizedPnl: todayTrades.reduce((sum, trade) => sum + (trade.realizedPnl || 0), 0),
        },
        warnings: {
          nearDailyLossLimit: (tierInfo.dailyLossUsed / tierInfo.tier.limits.maxDailyLoss) > 0.8,
          maxPositionsReached: openPositions.length >= tierInfo.tier.limits.maxOpenPositions,
        },
      }
    });
  } catch (error) {
    next(error);
  }
});

// Check trading suspension status
router.get('/suspension-status', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    
    if (!userId) {
      throw new AppError('User ID required', 400);
    }
    
    const suspension = await portfolioService.getTradingSuspensionStatus(userId);
    
    res.json({
      success: true,
      message: 'Trading suspension status retrieved',
      data: {
        suspended: suspension !== null,
        suspension: suspension ? {
          reason: suspension.reason,
          suspendedUntil: suspension.suspendedUntil,
          suspensionType: suspension.suspensionType,
          hoursRemaining: Math.ceil((suspension.suspendedUntil.getTime() - Date.now()) / (1000 * 60 * 60)),
        } : null,
      }
    });
  } catch (error) {
    next(error);
  }
});

// Force lift suspension (admin endpoint)
router.post('/lift-suspension', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    const { targetUserId, adminReason } = req.body;
    
    // In a real implementation, you'd check if the user has admin privileges
    // For now, we'll allow self-lifting for demo purposes
    const userToLift = targetUserId || userId;
    
    if (!userToLift) {
      throw new AppError('User ID required', 400);
    }
    
    const lifted = await portfolioService.liftTradingSuspension(userToLift, adminReason || 'User requested');
    
    res.json({
      success: lifted,
      message: lifted ? 'Trading suspension lifted successfully' : 'No active suspension found',
      data: { lifted }
    });
  } catch (error) {
    next(error);
  }
});

export { router as userTierRouter };