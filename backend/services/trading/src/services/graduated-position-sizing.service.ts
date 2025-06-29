import { DatabaseManager } from '../../../shared/src/database/manager';
import { logger } from '../utils/logger';
import { AppError } from '../utils/app-error';

// User tier definitions matching Flutter app
export enum UserTier {
  VILLAGE = 'village',
  TOWN = 'town',
  CITY = 'city',
  KINGDOM = 'kingdom',
  EMPIRE = 'empire'
}

// Position sizing recommendation
export interface PositionSizeRecommendation {
  recommendedSize: number;
  maxSize: number;
  minSize: number;
  riskPercentage: number;
  stopLossDistance: number;
  leverageRecommended: number;
  maxLeverage: number;
  warnings: string[];
  reasoning: string[];
}

// Risk calculation input
export interface RiskCalculationInput {
  userId: string;
  symbol: string;
  portfolioValue: number;
  entryPrice: number;
  stopLossPrice?: number;
  leverage: number;
  tradeDirection: 'long' | 'short';
}

// Tier-based risk limits
interface TierRiskLimits {
  maxPositionSizePercent: number;
  maxLeverage: number;
  maxRiskPerTradePercent: number;
  maxDailyRiskPercent: number;
  maxDrawdownPercent: number;
  minStopLossDistance: number;
  maxOpenPositions: number;
  requiresStopLoss: boolean;
  allowedInstruments: string[];
}

export class GraduatedPositionSizingService {
  private db: DatabaseManager;

  // Tier-based risk limits configuration
  private static readonly TIER_LIMITS: Record<UserTier, TierRiskLimits> = {
    [UserTier.VILLAGE]: {
      maxPositionSizePercent: 5.0,     // 5% max per position
      maxLeverage: 2.0,                // 2x max leverage
      maxRiskPerTradePercent: 1.0,     // 1% risk per trade
      maxDailyRiskPercent: 3.0,        // 3% max daily risk
      maxDrawdownPercent: 5.0,         // 5% max drawdown
      minStopLossDistance: 2.0,        // 2% min stop loss distance
      maxOpenPositions: 3,             // Max 3 positions
      requiresStopLoss: true,          // Stop loss mandatory
      allowedInstruments: ['BTC', 'ETH', 'SOL']
    },
    [UserTier.TOWN]: {
      maxPositionSizePercent: 10.0,
      maxLeverage: 5.0,
      maxRiskPerTradePercent: 2.0,
      maxDailyRiskPercent: 6.0,
      maxDrawdownPercent: 8.0,
      minStopLossDistance: 1.5,
      maxOpenPositions: 5,
      requiresStopLoss: true,
      allowedInstruments: ['BTC', 'ETH', 'SOL', 'AVAX', 'MATIC']
    },
    [UserTier.CITY]: {
      maxPositionSizePercent: 15.0,
      maxLeverage: 10.0,
      maxRiskPerTradePercent: 3.0,
      maxDailyRiskPercent: 10.0,
      maxDrawdownPercent: 12.0,
      minStopLossDistance: 1.0,
      maxOpenPositions: 8,
      requiresStopLoss: false,
      allowedInstruments: ['BTC', 'ETH', 'SOL', 'AVAX', 'MATIC', 'ARB', 'OP']
    },
    [UserTier.KINGDOM]: {
      maxPositionSizePercent: 20.0,
      maxLeverage: 20.0,
      maxRiskPerTradePercent: 4.0,
      maxDailyRiskPercent: 15.0,
      maxDrawdownPercent: 15.0,
      minStopLossDistance: 0.5,
      maxOpenPositions: 12,
      requiresStopLoss: false,
      allowedInstruments: ['BTC', 'ETH', 'SOL', 'AVAX', 'MATIC', 'ARB', 'OP', 'DOGE', 'ADA']
    },
    [UserTier.EMPIRE]: {
      maxPositionSizePercent: 25.0,
      maxLeverage: 50.0,
      maxRiskPerTradePercent: 5.0,
      maxDailyRiskPercent: 20.0,
      maxDrawdownPercent: 20.0,
      minStopLossDistance: 0.25,
      maxOpenPositions: 15,
      requiresStopLoss: false,
      allowedInstruments: ['*'] // All instruments allowed
    }
  };

  constructor() {
    this.db = DatabaseManager.getInstance();
  }

  /**
   * Calculate position sizing recommendation based on user tier and risk parameters
   */
  async calculatePositionSize(input: RiskCalculationInput): Promise<PositionSizeRecommendation> {
    try {
      // Get user tier and trading history
      const userTier = await this.getUserTier(input.userId);
      const tradingHistory = await this.getTradingHistory(input.userId, 30); // Last 30 days
      const currentPositions = await this.getCurrentPositions(input.userId);
      
      const tierLimits = GraduatedPositionSizingService.TIER_LIMITS[userTier];
      const warnings: string[] = [];
      const reasoning: string[] = [];

      // Check if instrument is allowed for this tier
      if (!this.isInstrumentAllowed(input.symbol, tierLimits)) {
        throw new AppError(`${input.symbol} is not available for ${userTier} tier traders`, 403);
      }

      // Calculate stop loss distance
      const stopLossDistance = input.stopLossPrice 
        ? Math.abs(input.entryPrice - input.stopLossPrice) / input.entryPrice
        : tierLimits.minStopLossDistance / 100;

      // Validate stop loss requirements
      if (tierLimits.requiresStopLoss && !input.stopLossPrice) {
        throw new AppError('Stop loss is required for your tier level', 400);
      }

      if (stopLossDistance < tierLimits.minStopLossDistance / 100) {
        warnings.push(`Stop loss too tight. Minimum ${tierLimits.minStopLossDistance}% required for your tier.`);
      }

      // Calculate maximum position size based on portfolio percentage
      const maxPositionValueByPercent = (input.portfolioValue * tierLimits.maxPositionSizePercent) / 100;

      // Calculate maximum position size based on risk percentage
      const riskAmount = (input.portfolioValue * tierLimits.maxRiskPerTradePercent) / 100;
      const maxPositionValueByRisk = riskAmount / stopLossDistance;

      // Take the more conservative limit
      const maxPositionValue = Math.min(maxPositionValueByPercent, maxPositionValueByRisk);

      // Apply leverage constraints
      const constrainedLeverage = Math.min(input.leverage, tierLimits.maxLeverage);
      if (input.leverage > tierLimits.maxLeverage) {
        warnings.push(`Leverage reduced from ${input.leverage}x to ${tierLimits.maxLeverage}x (tier limit)`);
      }

      // Calculate recommended position size
      const basePositionValue = maxPositionValue / constrainedLeverage;
      const recommendedPositionSize = basePositionValue / input.entryPrice;

      // Check daily risk limits
      const todayRisk = await this.calculateDailyRisk(input.userId);
      const newTradeRisk = (riskAmount / input.portfolioValue) * 100;
      
      if (todayRisk + newTradeRisk > tierLimits.maxDailyRiskPercent) {
        const availableDailyRisk = Math.max(0, tierLimits.maxDailyRiskPercent - todayRisk);
        warnings.push(`Daily risk limit reached. Available risk: ${availableDailyRisk.toFixed(2)}%`);
      }

      // Check position count limits
      if (currentPositions.length >= tierLimits.maxOpenPositions) {
        throw new AppError(`Maximum ${tierLimits.maxOpenPositions} positions allowed for ${userTier} tier`, 403);
      }

      // Check drawdown limits
      const currentDrawdown = await this.calculateCurrentDrawdown(input.userId);
      if (currentDrawdown > tierLimits.maxDrawdownPercent) {
        warnings.push(`Portfolio drawdown (${currentDrawdown.toFixed(2)}%) exceeds tier limit (${tierLimits.maxDrawdownPercent}%)`);
      }

      // Add reasoning for recommendations
      reasoning.push(`Position size calculated based on ${userTier} tier limits`);
      reasoning.push(`Max position size: ${tierLimits.maxPositionSizePercent}% of portfolio`);
      reasoning.push(`Max risk per trade: ${tierLimits.maxRiskPerTradePercent}% of portfolio`);
      reasoning.push(`Stop loss distance: ${(stopLossDistance * 100).toFixed(2)}%`);

      // Performance-based adjustments
      const performanceMultiplier = await this.calculatePerformanceMultiplier(input.userId, tradingHistory);
      const adjustedRecommendedSize = recommendedPositionSize * performanceMultiplier;

      if (performanceMultiplier < 1.0) {
        reasoning.push(`Position size reduced by ${((1 - performanceMultiplier) * 100).toFixed(1)}% due to recent performance`);
      } else if (performanceMultiplier > 1.0) {
        reasoning.push(`Position size increased by ${((performanceMultiplier - 1) * 100).toFixed(1)}% due to good performance`);
      }

      return {
        recommendedSize: Math.max(0, adjustedRecommendedSize),
        maxSize: recommendedPositionSize,
        minSize: recommendedPositionSize * 0.1, // 10% of recommended as minimum
        riskPercentage: (riskAmount / input.portfolioValue) * 100,
        stopLossDistance: stopLossDistance * 100,
        leverageRecommended: constrainedLeverage,
        maxLeverage: tierLimits.maxLeverage,
        warnings,
        reasoning
      };

    } catch (error) {
      logger.error('Error calculating position size:', error);
      throw error;
    }
  }

  /**
   * Validate trade against tier limits before execution
   */
  async validateTradeAgainstLimits(input: RiskCalculationInput, positionSize: number): Promise<{ valid: boolean; errors: string[] }> {
    try {
      const userTier = await this.getUserTier(input.userId);
      const tierLimits = GraduatedPositionSizingService.TIER_LIMITS[userTier];
      const errors: string[] = [];

      const positionValue = positionSize * input.entryPrice * input.leverage;
      const positionSizePercent = (positionValue / input.portfolioValue) * 100;

      // Check position size limits
      if (positionSizePercent > tierLimits.maxPositionSizePercent) {
        errors.push(`Position size ${positionSizePercent.toFixed(2)}% exceeds tier limit of ${tierLimits.maxPositionSizePercent}%`);
      }

      // Check leverage limits
      if (input.leverage > tierLimits.maxLeverage) {
        errors.push(`Leverage ${input.leverage}x exceeds tier limit of ${tierLimits.maxLeverage}x`);
      }

      // Check instrument restrictions
      if (!this.isInstrumentAllowed(input.symbol, tierLimits)) {
        errors.push(`${input.symbol} is not available for ${userTier} tier`);
      }

      // Check stop loss requirements
      if (tierLimits.requiresStopLoss && !input.stopLossPrice) {
        errors.push('Stop loss is required for your tier level');
      }

      // Check position count
      const currentPositions = await this.getCurrentPositions(input.userId);
      if (currentPositions.length >= tierLimits.maxOpenPositions) {
        errors.push(`Maximum ${tierLimits.maxOpenPositions} positions allowed for ${userTier} tier`);
      }

      return {
        valid: errors.length === 0,
        errors
      };

    } catch (error) {
      logger.error('Error validating trade limits:', error);
      return {
        valid: false,
        errors: ['Failed to validate trade limits']
      };
    }
  }

  /**
   * Get tier progression requirements for position sizing
   */
  async getTierProgressionRequirements(userId: string): Promise<any> {
    try {
      const currentTier = await this.getUserTier(userId);
      const nextTier = this.getNextTier(currentTier);
      
      if (!nextTier) {
        return { message: 'You have reached the highest tier!' };
      }

      const currentLimits = GraduatedPositionSizingService.TIER_LIMITS[currentTier];
      const nextLimits = GraduatedPositionSizingService.TIER_LIMITS[nextTier];

      return {
        currentTier,
        nextTier,
        currentLimits,
        nextLimits,
        improvements: {
          maxPositionSize: `${currentLimits.maxPositionSizePercent}% → ${nextLimits.maxPositionSizePercent}%`,
          maxLeverage: `${currentLimits.maxLeverage}x → ${nextLimits.maxLeverage}x`,
          maxRiskPerTrade: `${currentLimits.maxRiskPerTradePercent}% → ${nextLimits.maxRiskPerTradePercent}%`,
          maxPositions: `${currentLimits.maxOpenPositions} → ${nextLimits.maxOpenPositions}`
        }
      };

    } catch (error) {
      logger.error('Error getting tier progression:', error);
      throw new AppError('Failed to get tier progression requirements', 500);
    }
  }

  // Private helper methods
  private async getUserTier(userId: string): Promise<UserTier> {
    try {
      const result = await this.db.query(
        'SELECT tier FROM user_profiles WHERE user_id = $1',
        [userId]
      );
      
      if (result.rows.length === 0) {
        return UserTier.VILLAGE; // Default tier for new users
      }

      return result.rows[0].tier as UserTier || UserTier.VILLAGE;
    } catch (error) {
      logger.error('Error getting user tier:', error);
      return UserTier.VILLAGE;
    }
  }

  private async getTradingHistory(userId: string, days: number): Promise<any[]> {
    try {
      const result = await this.db.query(`
        SELECT * FROM trades 
        WHERE user_id = $1 
        AND created_at >= NOW() - INTERVAL '${days} days'
        ORDER BY created_at DESC
      `, [userId]);
      
      return result.rows;
    } catch (error) {
      logger.error('Error getting trading history:', error);
      return [];
    }
  }

  private async getCurrentPositions(userId: string): Promise<any[]> {
    try {
      const result = await this.db.query(
        'SELECT * FROM positions WHERE user_id = $1 AND status = $2',
        [userId, 'open']
      );
      
      return result.rows;
    } catch (error) {
      logger.error('Error getting current positions:', error);
      return [];
    }
  }

  private isInstrumentAllowed(symbol: string, tierLimits: TierRiskLimits): boolean {
    if (tierLimits.allowedInstruments.includes('*')) {
      return true;
    }
    return tierLimits.allowedInstruments.includes(symbol);
  }

  private async calculateDailyRisk(userId: string): Promise<number> {
    try {
      const result = await this.db.query(`
        SELECT COALESCE(SUM(ABS(pnl_percent)), 0) as daily_risk
        FROM trades 
        WHERE user_id = $1 
        AND DATE(created_at) = CURRENT_DATE
        AND pnl_percent < 0
      `, [userId]);
      
      return result.rows[0]?.daily_risk || 0;
    } catch (error) {
      logger.error('Error calculating daily risk:', error);
      return 0;
    }
  }

  private async calculateCurrentDrawdown(userId: string): Promise<number> {
    try {
      const result = await this.db.query(`
        SELECT 
          MAX(portfolio_value) as peak_value,
          MIN(portfolio_value) as trough_value
        FROM portfolio_history 
        WHERE user_id = $1 
        AND created_at >= NOW() - INTERVAL '30 days'
      `, [userId]);
      
      const { peak_value, trough_value } = result.rows[0] || { peak_value: 0, trough_value: 0 };
      
      if (peak_value === 0) return 0;
      
      return ((peak_value - trough_value) / peak_value) * 100;
    } catch (error) {
      logger.error('Error calculating drawdown:', error);
      return 0;
    }
  }

  private async calculatePerformanceMultiplier(userId: string, tradingHistory: any[]): Promise<number> {
    if (tradingHistory.length < 5) {
      return 0.8; // Conservative for new traders
    }

    const recentTrades = tradingHistory.slice(0, 10); // Last 10 trades
    const winRate = recentTrades.filter(trade => trade.pnl_percent > 0).length / recentTrades.length;
    const avgReturn = recentTrades.reduce((sum, trade) => sum + trade.pnl_percent, 0) / recentTrades.length;

    // Performance score based on win rate and returns
    let multiplier = 1.0;

    if (winRate >= 0.6 && avgReturn > 0) {
      multiplier = 1.2; // Good performance, increase size
    } else if (winRate < 0.4 || avgReturn < -2) {
      multiplier = 0.7; // Poor performance, reduce size
    }

    return multiplier;
  }

  private getNextTier(currentTier: UserTier): UserTier | null {
    const tiers = Object.values(UserTier);
    const currentIndex = tiers.indexOf(currentTier);
    return currentIndex < tiers.length - 1 ? tiers[currentIndex + 1] : null;
  }
}