import { Router, Request, Response } from 'express';
import { GraduatedPositionSizingService, RiskCalculationInput } from '../services/graduated-position-sizing.service';
import { logger } from '../utils/logger';
import { AppError } from '../utils/app-error';
import { body, query, validationResult } from 'express-validator';

const router = Router();
const positionSizingService = new GraduatedPositionSizingService();

// Validation middleware
const validateRiskCalculation = [
  body('symbol').isString().notEmpty().withMessage('Symbol is required'),
  body('portfolioValue').isNumeric().isFloat({ min: 0 }).withMessage('Portfolio value must be positive'),
  body('entryPrice').isNumeric().isFloat({ min: 0 }).withMessage('Entry price must be positive'),
  body('leverage').isNumeric().isFloat({ min: 1, max: 100 }).withMessage('Leverage must be between 1 and 100'),
  body('tradeDirection').isIn(['long', 'short']).withMessage('Trade direction must be long or short'),
  body('stopLossPrice').optional().isNumeric().isFloat({ min: 0 }).withMessage('Stop loss price must be positive'),
];

// POST /position-sizing/calculate - Calculate position size recommendation
router.post('/calculate', validateRiskCalculation, async (req: Request, res: Response) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: errors.array(),
        timestamp: new Date().toISOString()
      });
    }

    const userId = req.headers['x-user-id'] as string;
    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'User ID required',
        timestamp: new Date().toISOString()
      });
    }

    const input: RiskCalculationInput = {
      userId,
      symbol: req.body.symbol,
      portfolioValue: parseFloat(req.body.portfolioValue),
      entryPrice: parseFloat(req.body.entryPrice),
      stopLossPrice: req.body.stopLossPrice ? parseFloat(req.body.stopLossPrice) : undefined,
      leverage: parseFloat(req.body.leverage),
      tradeDirection: req.body.tradeDirection
    };

    const recommendation = await positionSizingService.calculatePositionSize(input);

    res.json({
      success: true,
      data: recommendation,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    logger.error('Error calculating position size:', error);
    
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({
        success: false,
        error: error.message,
        timestamp: new Date().toISOString()
      });
    }

    res.status(500).json({
      success: false,
      error: 'Failed to calculate position size',
      timestamp: new Date().toISOString()
    });
  }
});

// POST /position-sizing/validate - Validate trade against tier limits
router.post('/validate', validateRiskCalculation, async (req: Request, res: Response) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: errors.array(),
        timestamp: new Date().toISOString()
      });
    }

    const userId = req.headers['x-user-id'] as string;
    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'User ID required',
        timestamp: new Date().toISOString()
      });
    }

    const input: RiskCalculationInput = {
      userId,
      symbol: req.body.symbol,
      portfolioValue: parseFloat(req.body.portfolioValue),
      entryPrice: parseFloat(req.body.entryPrice),
      stopLossPrice: req.body.stopLossPrice ? parseFloat(req.body.stopLossPrice) : undefined,
      leverage: parseFloat(req.body.leverage),
      tradeDirection: req.body.tradeDirection
    };

    const positionSize = parseFloat(req.body.positionSize);
    if (!positionSize || positionSize <= 0) {
      return res.status(400).json({
        success: false,
        error: 'Valid position size required',
        timestamp: new Date().toISOString()
      });
    }

    const validation = await positionSizingService.validateTradeAgainstLimits(input, positionSize);

    res.json({
      success: true,
      data: validation,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    logger.error('Error validating trade:', error);
    
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({
        success: false,
        error: error.message,
        timestamp: new Date().toISOString()
      });
    }

    res.status(500).json({
      success: false,
      error: 'Failed to validate trade',
      timestamp: new Date().toISOString()
    });
  }
});

// GET /position-sizing/tier-info - Get user's tier limits and progression
router.get('/tier-info', async (req: Request, res: Response) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'User ID required',
        timestamp: new Date().toISOString()
      });
    }

    const tierInfo = await positionSizingService.getTierProgressionRequirements(userId);

    res.json({
      success: true,
      data: tierInfo,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    logger.error('Error getting tier info:', error);
    
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({
        success: false,
        error: error.message,
        timestamp: new Date().toISOString()
      });
    }

    res.status(500).json({
      success: false,
      error: 'Failed to get tier information',
      timestamp: new Date().toISOString()
    });
  }
});

// GET /position-sizing/risk-summary - Get current risk summary for user
router.get('/risk-summary', async (req: Request, res: Response) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'User ID required',
        timestamp: new Date().toISOString()
      });
    }

    // This would typically fetch from database
    // For now, return mock data structure
    const riskSummary = {
      dailyRiskUsed: 2.5,
      dailyRiskLimit: 10.0,
      openPositions: 3,
      maxPositions: 8,
      currentDrawdown: 1.2,
      maxDrawdown: 12.0,
      portfolioValue: 10000,
      availableMargin: 8500,
      totalRiskExposure: 15.5
    };

    res.json({
      success: true,
      data: riskSummary,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    logger.error('Error getting risk summary:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get risk summary',
      timestamp: new Date().toISOString()
    });
  }
});

// POST /position-sizing/emergency-exit - Emergency position exit recommendations
router.post('/emergency-exit', async (req: Request, res: Response) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'User ID required',
        timestamp: new Date().toISOString()
      });
    }

    const { reason, positionId } = req.body;

    // This would implement emergency exit logic
    const emergencyRecommendation = {
      action: 'immediate_exit',
      reason: reason || 'risk_limit_exceeded',
      recommendations: [
        'Close position immediately to preserve capital',
        'Review risk management settings',
        'Consider reducing position sizes for future trades'
      ],
      estimatedLoss: 250,
      timeToExecute: 'immediate'
    };

    res.json({
      success: true,
      data: emergencyRecommendation,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    logger.error('Error getting emergency exit recommendation:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get emergency exit recommendation',
      timestamp: new Date().toISOString()
    });
  }
});

// GET /position-sizing/performance-analysis - Get position sizing performance analysis
router.get('/performance-analysis', async (req: Request, res: Response) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'User ID required',
        timestamp: new Date().toISOString()
      });
    }

    const { period = '30' } = req.query;

    // This would analyze position sizing performance over time
    const analysis = {
      period: `${period} days`,
      totalTrades: 45,
      avgPositionSize: 5.2, // % of portfolio
      optimalSizeHitRate: 78.5, // % of trades that were optimally sized
      oversizedTrades: 8,
      undersizedTrades: 12,
      riskAdjustedReturns: 12.5,
      recommendations: [
        'Consider increasing position sizes on high-conviction trades',
        'Your risk management is conservative but effective',
        'Strong performance suggests readiness for next tier'
      ]
    };

    res.json({
      success: true,
      data: analysis,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    logger.error('Error getting performance analysis:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get performance analysis',
      timestamp: new Date().toISOString()
    });
  }
});

export { router as positionSizingRouter };