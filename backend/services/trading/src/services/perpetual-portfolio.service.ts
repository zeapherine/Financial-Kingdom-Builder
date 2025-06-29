import { 
  PerpetualPosition, 
  PerpetualPortfolio, 
  PositionSide, 
  PositionStatus,
  OpenPositionRequest,
  ClosePositionRequest,
  UpdatePositionRequest,
  LiquidationEvent,
  FundingPayment,
  RiskLimits,
  RiskWarning
} from '../types/perpetual';
import { logger } from '../utils/logger';
import { AppError } from '../utils/app-error';
import { UserTierService, UserTier } from './user-tier.service';

interface TradingSuspension {
  userId: string;
  reason: string;
  suspendedUntil: Date;
  suspensionType: 'daily_loss' | 'consecutive_loss' | 'tier_violation';
  canTrade: boolean;
}

export class PerpetualPortfolioService {
  private portfolios: Map<string, PerpetualPortfolio> = new Map();
  private positions: Map<string, PerpetualPosition> = new Map();
  private riskLimits: Map<string, RiskLimits> = new Map();
  private userTierService: UserTierService;
  private dailyLossTracking: Map<string, { date: string; losses: number; trades: number }> = new Map();
  private tradingSuspensions: Map<string, TradingSuspension> = new Map();

  constructor() {
    this.userTierService = new UserTierService();
    this.initializeDefaultRiskLimits();
  }

  private initializeDefaultRiskLimits() {
    // Default risk limits for different user tiers
    const defaultLimits: RiskLimits = {
      maxLeverage: 20,
      maxPositionSize: 1000,
      maxDailyLoss: 500,
      maxOpenPositions: 5,
      maxOrderValue: 2000,
      forceStopLoss: true
    };
    
    // Set default limits for all users
    this.riskLimits.set('default', defaultLimits);
  }

  /**
   * Initialize or get user portfolio
   */
  async getOrCreatePortfolio(userId: string, isPaperTrading: boolean = true): Promise<PerpetualPortfolio> {
    const portfolioKey = `${userId}_${isPaperTrading ? 'paper' : 'real'}`;
    
    if (!this.portfolios.has(portfolioKey)) {
      const newPortfolio: PerpetualPortfolio = {
        userId,
        totalBalance: isPaperTrading ? 10000 : 0, // $10k paper trading start
        availableBalance: isPaperTrading ? 10000 : 0,
        usedMargin: 0,
        unrealizedPnl: 0,
        totalEquity: isPaperTrading ? 10000 : 0,
        marginRatio: 0,
        positions: [],
        isPaperTrading,
        maxDrawdown: 0,
        dailyPnl: 0,
        totalFees: 0,
        totalFunding: 0
      };
      
      this.portfolios.set(portfolioKey, newPortfolio);
      logger.info(`Created new portfolio for user ${userId}, paper: ${isPaperTrading}`);
    }

    return this.portfolios.get(portfolioKey)!;
  }

  /**
   * Open a new perpetual position with tier-based limits
   */
  async openPosition(userId: string, request: OpenPositionRequest, currentPrice: number): Promise<PerpetualPosition> {
    const portfolio = await this.getOrCreatePortfolio(userId, request.isPaperTrading);
    const userTier = await this.userTierService.getUserTier(userId);

    // Check for trading suspension first
    await this.checkTradingSuspension(userId);
    
    // Validate request with tier-based limits
    await this.validateOpenPositionRequest(userId, request, portfolio, userTier, currentPrice);

    // Calculate position parameters
    const margin = request.size / request.leverage;
    const liquidationPrice = this.calculateLiquidationPrice(
      request.side,
      currentPrice,
      request.leverage
    );

    // Check if user has sufficient balance
    if (margin > portfolio.availableBalance) {
      throw new AppError(`Insufficient balance. Required: $${margin.toFixed(2)}, Available: $${portfolio.availableBalance.toFixed(2)}`, 400);
    }

    // Set mandatory stop-loss for beginner tiers if not provided
    let stopLoss = request.stopLoss;
    if (userTier.limits.forceStopLoss && !stopLoss) {
      stopLoss = this.calculateMandatoryStopLoss(
        request.side,
        currentPrice,
        userTier.limits.stopLossPercentage
      );
      logger.info(`Auto-set mandatory stop-loss for ${userTier.tierName} user ${userId}: ${stopLoss}`);
    }

    // Create position
    const position: PerpetualPosition = {
      id: this.generatePositionId(),
      userId,
      symbol: request.symbol,
      side: request.side,
      entryPrice: currentPrice,
      markPrice: currentPrice,
      size: request.size,
      leverage: request.leverage,
      margin,
      marginRatio: 0,
      unrealizedPnl: 0,
      realizedPnl: 0,
      liquidationPrice,
      status: PositionStatus.OPEN,
      openTime: new Date(),
      fundingPaid: 0,
      isPaperTrading: request.isPaperTrading,
      stopLoss,
      takeProfit: request.takeProfit,
      autoDeleverage: false
    };

    // Update portfolio
    portfolio.availableBalance -= margin;
    portfolio.usedMargin += margin;
    portfolio.positions.push(position);

    // Store position
    this.positions.set(position.id, position);
    
    logger.info(`Opened ${request.side} position for ${userId}: ${request.symbol} ${request.size} @ ${currentPrice} (${request.leverage}x)`);

    return position;
  }

  /**
   * Close a position (fully or partially)
   */
  async closePosition(userId: string, request: ClosePositionRequest, currentPrice: number): Promise<PerpetualPosition> {
    const position = this.positions.get(request.positionId);
    if (!position || position.userId !== userId) {
      throw new AppError('Position not found', 404);
    }

    if (position.status !== PositionStatus.OPEN) {
      throw new AppError('Position is already closed', 400);
    }

    const portfolio = await this.getOrCreatePortfolio(userId, position.isPaperTrading);
    
    // Calculate close size (full close if not specified)
    const closeSize = request.size || position.size;
    if (closeSize > position.size) {
      throw new AppError('Close size cannot exceed position size', 400);
    }

    // Calculate realized PnL
    const realizedPnl = this.calculatePnl(position.side, position.entryPrice, currentPrice, closeSize, position.leverage);
    
    // Calculate margin to return
    const marginToReturn = (closeSize / position.size) * position.margin;

    // Update position
    if (closeSize === position.size) {
      // Full close
      position.status = PositionStatus.CLOSED;
      position.closeTime = new Date();
      position.closePrice = currentPrice;
      position.realizedPnl = realizedPnl;
      
      // Remove from portfolio positions
      portfolio.positions = portfolio.positions.filter(p => p.id !== position.id);
    } else {
      // Partial close - create new position with remaining size
      position.size -= closeSize;
      position.margin -= marginToReturn;
      position.realizedPnl += realizedPnl;
    }

    // Update portfolio
    portfolio.availableBalance += marginToReturn + realizedPnl;
    portfolio.usedMargin -= marginToReturn;

    // Update daily PnL
    portfolio.dailyPnl += realizedPnl;
    
    // Record trade outcome for tier system and risk management
    const holdTime = position.openTime ? 
      Math.floor((Date.now() - position.openTime.getTime()) / (1000 * 60)) : 0; // in minutes
    
    await this.userTierService.recordTrade(userId, {
      isWin: realizedPnl > 0,
      pnl: realizedPnl,
      positionSize: request.size || position.size,
      holdTime,
    });
    
    // If this was a loss, track it for daily limits and consecutive loss patterns
    if (realizedPnl < 0) {
      await this.recordTradeLoss(userId, Math.abs(realizedPnl));
      await this.checkConsecutiveLossPattern(userId);
    }

    logger.info(`Closed position ${request.positionId} for ${userId}: PnL ${realizedPnl.toFixed(2)}`);

    return position;
  }

  /**
   * Update position prices and calculate unrealized PnL
   */
  async updatePositionPrices(symbol: string, markPrice: number): Promise<void> {
    for (const [positionId, position] of this.positions) {
      if (position.symbol === symbol && position.status === PositionStatus.OPEN) {
        position.markPrice = markPrice;
        position.unrealizedPnl = this.calculatePnl(
          position.side,
          position.entryPrice,
          markPrice,
          position.size,
          position.leverage
        );

        // Check for liquidation
        if (this.shouldLiquidate(position, markPrice)) {
          await this.liquidatePosition(position.id, markPrice);
        }
        
        // Check for stop-loss triggers
        if (this.shouldTriggerStopLoss(position, markPrice)) {
          await this.triggerStopLoss(position.id, markPrice);
        }

        // Update portfolio unrealized PnL
        const portfolio = await this.getOrCreatePortfolio(position.userId, position.isPaperTrading);
        this.updatePortfolioMetrics(portfolio);
      }
    }
  }

  /**
   * Apply funding payments to all open positions
   */
  async applyFundingPayments(symbol: string, fundingRate: number): Promise<FundingPayment[]> {
    const fundingPayments: FundingPayment[] = [];

    for (const [positionId, position] of this.positions) {
      if (position.symbol === symbol && position.status === PositionStatus.OPEN) {
        const payment = this.calculateFundingPayment(position, fundingRate);
        
        // Apply funding payment
        position.fundingPaid += payment;
        
        const portfolio = await this.getOrCreatePortfolio(position.userId, position.isPaperTrading);
        portfolio.availableBalance -= payment;
        portfolio.totalFunding += payment;

        const fundingPayment: FundingPayment = {
          id: this.generateId(),
          userId: position.userId,
          positionId: position.id,
          symbol,
          rate: fundingRate,
          payment,
          timestamp: new Date(),
          isPaperTrading: position.isPaperTrading
        };

        fundingPayments.push(fundingPayment);
      }
    }

    return fundingPayments;
  }

  /**
   * Get risk warnings for a user
   */
  async getRiskWarnings(userId: string, isPaperTrading: boolean): Promise<RiskWarning[]> {
    const portfolio = await this.getOrCreatePortfolio(userId, isPaperTrading);
    const warnings: RiskWarning[] = [];

    // Check margin ratio
    if (portfolio.marginRatio > 0.8) {
      warnings.push({
        type: 'margin',
        severity: portfolio.marginRatio > 0.95 ? 'critical' : 'high',
        message: `High margin usage: ${(portfolio.marginRatio * 100).toFixed(1)}%`,
        threshold: 0.8,
        current: portfolio.marginRatio
      });
    }

    // Check daily loss
    if (portfolio.dailyPnl < -500) {
      warnings.push({
        type: 'daily_loss',
        severity: 'high',
        message: `Daily loss limit approaching: $${portfolio.dailyPnl.toFixed(2)}`,
        threshold: -500,
        current: portfolio.dailyPnl
      });
    }

    // Check positions near liquidation
    for (const position of portfolio.positions) {
      if (this.isNearLiquidation(position, position.markPrice)) {
        warnings.push({
          type: 'liquidation',
          severity: 'critical',
          message: `Position ${position.symbol} near liquidation`,
          positionId: position.id,
          threshold: position.liquidationPrice,
          current: position.markPrice
        });
      }
    }

    return warnings;
  }

  /**
   * Get user's portfolio
   */
  async getPortfolio(userId: string, isPaperTrading: boolean): Promise<PerpetualPortfolio> {
    const portfolio = await this.getOrCreatePortfolio(userId, isPaperTrading);
    this.updatePortfolioMetrics(portfolio);
    return portfolio;
  }

  /**
   * Get user's open positions
   */
  async getOpenPositions(userId: string, isPaperTrading: boolean): Promise<PerpetualPosition[]> {
    const portfolio = await this.getOrCreatePortfolio(userId, isPaperTrading);
    return portfolio.positions.filter(p => p.status === PositionStatus.OPEN);
  }

  // Private helper methods

  private async validateOpenPositionRequest(
    userId: string,
    request: OpenPositionRequest,
    portfolio: PerpetualPortfolio,
    userTier: UserTier,
    currentPrice: number
  ): Promise<void> {
    const limits = userTier.limits;
    
    // Check leverage limits based on user tier
    if (request.leverage > limits.maxLeverage) {
      throw new AppError(
        `Your ${userTier.tierName} status allows maximum ${limits.maxLeverage}x leverage. ` +
        `Current request: ${request.leverage}x. Complete more education to unlock higher leverage.`,
        400
      );
    }

    // Check position size limits
    if (request.size > limits.maxPositionSize) {
      throw new AppError(
        `Position size $${request.size} exceeds ${userTier.tierName} limit of $${limits.maxPositionSize}. ` +
        `Upgrade your kingdom tier to trade larger positions.`,
        400
      );
    }

    // Check maximum open positions
    const openPositionsCount = portfolio.positions.filter(p => p.status === PositionStatus.OPEN).length;
    if (openPositionsCount >= limits.maxOpenPositions) {
      throw new AppError(
        `Maximum open positions (${limits.maxOpenPositions}) reached for ${userTier.tierName}. ` +
        `Close existing positions or upgrade your tier.`,
        400
      );
    }

    // Check order value limits
    if (request.size > limits.maxOrderValue) {
      throw new AppError(
        `Order value $${request.size} exceeds ${userTier.tierName} limit of $${limits.maxOrderValue}.`,
        400
      );
    }

    // Check daily loss limits
    await this.checkDailyLossLimits(userId, request.size, limits.maxDailyLoss);
    
    // Check instrument access
    if (!this.isInstrumentAllowed(request.symbol, limits.allowedInstruments)) {
      throw new AppError(
        `Trading ${request.symbol} requires higher tier. Your ${userTier.tierName} status restricts available instruments.`,
        400
      );
    }
    
    // Force stop loss for certain tiers
    if (limits.forceStopLoss && !request.stopLoss) {
      const suggestedStopLoss = this.calculateMandatoryStopLoss(
        request.side, 
        currentPrice, 
        limits.stopLossPercentage
      );
      
      throw new AppError(
        `${userTier.tierName} requires mandatory stop loss. ` +
        `Suggested stop loss: $${suggestedStopLoss.toFixed(2)} (${limits.stopLossPercentage}% protection).`,
        400
      );
    }
  }

  private calculatePnl(side: PositionSide, entryPrice: number, currentPrice: number, size: number, leverage: number): number {
    const priceDiff = side === PositionSide.LONG 
      ? currentPrice - entryPrice 
      : entryPrice - currentPrice;
    return (priceDiff / entryPrice) * size * leverage;
  }

  private calculateLiquidationPrice(side: PositionSide, entryPrice: number, leverage: number): number {
    const marginRatio = 1 / leverage;
    const liquidationThreshold = 0.9; // 90% of margin

    if (side === PositionSide.LONG) {
      return entryPrice * (1 - marginRatio * liquidationThreshold);
    } else {
      return entryPrice * (1 + marginRatio * liquidationThreshold);
    }
  }

  private calculateFundingPayment(position: PerpetualPosition, fundingRate: number): number {
    // Long positions pay when funding rate is positive
    // Short positions pay when funding rate is negative
    const notionalValue = position.size;
    
    if (position.side === PositionSide.LONG) {
      return notionalValue * fundingRate;
    } else {
      return -notionalValue * fundingRate;
    }
  }

  private shouldLiquidate(position: PerpetualPosition, markPrice: number): boolean {
    if (position.side === PositionSide.LONG) {
      return markPrice <= position.liquidationPrice;
    } else {
      return markPrice >= position.liquidationPrice;
    }
  }

  private isNearLiquidation(position: PerpetualPosition, markPrice: number): boolean {
    const threshold = 0.05; // 5% away from liquidation
    
    if (position.side === PositionSide.LONG) {
      return markPrice <= position.liquidationPrice * (1 + threshold);
    } else {
      return markPrice >= position.liquidationPrice * (1 - threshold);
    }
  }
  
  private shouldTriggerStopLoss(position: PerpetualPosition, markPrice: number): boolean {
    if (!position.stopLoss) return false;
    
    if (position.side === PositionSide.LONG) {
      return markPrice <= position.stopLoss;
    } else {
      return markPrice >= position.stopLoss;
    }
  }
  
  private async triggerStopLoss(positionId: string, markPrice: number): Promise<void> {
    const position = this.positions.get(positionId);
    if (!position) return;
    
    logger.info(`Stop-loss triggered for position ${positionId} at ${markPrice}`);
    
    // Close the position at stop-loss price
    try {
      await this.closePosition(position.userId, {
        positionId: position.id,
        size: position.size, // Close full position
      }, markPrice);
      
      // Mark position as stop-loss triggered
      position.status = PositionStatus.CLOSED;
      position.closeTime = new Date();
      position.closePrice = markPrice;
      
      // Notify user of stop-loss execution
      logger.info(`Stop-loss executed for user ${position.userId}: ` +
        `Position ${positionId} closed at ${markPrice} (stop-loss: ${position.stopLoss})`);
      
    } catch (error) {
      logger.error(`Failed to execute stop-loss for position ${positionId}:`, error);
    }
  }

  private async liquidatePosition(positionId: string, markPrice: number): Promise<void> {
    const position = this.positions.get(positionId);
    if (!position) return;

    position.status = PositionStatus.LIQUIDATED;
    position.closeTime = new Date();
    position.closePrice = markPrice;
    position.realizedPnl = this.calculatePnl(
      position.side,
      position.entryPrice,
      markPrice,
      position.size,
      position.leverage
    );

    const portfolio = await this.getOrCreatePortfolio(position.userId, position.isPaperTrading);
    
    // In liquidation, user loses the margin
    portfolio.usedMargin -= position.margin;
    portfolio.positions = portfolio.positions.filter(p => p.id !== position.id);

    logger.warn(`Liquidated position ${positionId} for user ${position.userId} at ${markPrice}`);
  }

  private updatePortfolioMetrics(portfolio: PerpetualPortfolio): void {
    // Calculate total unrealized PnL
    portfolio.unrealizedPnl = portfolio.positions
      .filter(p => p.status === PositionStatus.OPEN)
      .reduce((sum, p) => sum + p.unrealizedPnl, 0);

    // Calculate total equity
    portfolio.totalEquity = portfolio.totalBalance + portfolio.unrealizedPnl;

    // Calculate margin ratio
    portfolio.marginRatio = portfolio.totalEquity > 0 ? portfolio.usedMargin / portfolio.totalEquity : 0;
  }

  private getRiskLimits(userId: string): RiskLimits {
    return this.riskLimits.get(userId) || this.riskLimits.get('default')!;
  }
  
  /**
   * Check for active trading suspension
   */
  private async checkTradingSuspension(userId: string): Promise<void> {
    const suspension = this.tradingSuspensions.get(userId);
    
    if (suspension && suspension.canTrade === false) {
      const now = new Date();
      
      if (now < suspension.suspendedUntil) {
        const hoursRemaining = Math.ceil((suspension.suspendedUntil.getTime() - now.getTime()) / (1000 * 60 * 60));
        
        throw new AppError(
          `Trading suspended due to ${suspension.reason}. ` +
          `Suspension will be lifted in ${hoursRemaining} hours (${suspension.suspendedUntil.toISOString()}). ` +
          `This is for your protection and risk management.`,
          403
        );
      } else {
        // Suspension expired, remove it
        this.tradingSuspensions.delete(userId);
        logger.info(`Trading suspension lifted for user ${userId}`);
      }
    }
  }
  
  /**
   * Check daily loss limits for user tier
   */
  private async checkDailyLossLimits(userId: string, positionSize: number, maxDailyLoss: number): Promise<void> {
    const today = new Date().toISOString().split('T')[0];
    const key = `${userId}_${today}`;
    
    let dailyLoss = this.dailyLossTracking.get(key);
    if (!dailyLoss) {
      dailyLoss = { date: today, losses: 0, trades: 0 };
      this.dailyLossTracking.set(key, dailyLoss);
    }
    
    // Calculate potential loss (conservative estimate based on leverage and volatility)
    const leverage = Math.min(20, Math.max(1, positionSize / 1000)); // Estimate leverage
    const potentialLoss = positionSize * 0.1 * leverage; // 10% move with leverage
    
    if (dailyLoss.losses + potentialLoss > maxDailyLoss) {
      // Suspend trading for the rest of the day
      await this.suspendTrading(userId, 'daily_loss', 
        `Daily loss limit reached: $${dailyLoss.losses.toFixed(2)} + potential $${potentialLoss.toFixed(2)} > limit $${maxDailyLoss}`);
      
      throw new AppError(
        `Daily loss limit protection activated. ` +
        `Current losses: $${dailyLoss.losses.toFixed(2)}, ` +
        `Limit: $${maxDailyLoss}, ` +
        `Potential additional loss: $${potentialLoss.toFixed(2)}. ` +
        `Trading has been suspended until tomorrow to protect your kingdom.`,
        403
      );
    }
  }
  
  /**
   * Check if instrument is allowed for user tier
   */
  private isInstrumentAllowed(symbol: string, allowedInstruments: string[]): boolean {
    return allowedInstruments.includes('*') || allowedInstruments.includes(symbol);
  }
  
  /**
   * Calculate mandatory stop loss based on tier requirements
   */
  private calculateMandatoryStopLoss(side: PositionSide, entryPrice: number, stopLossPercentage: number): number {
    const stopLossRatio = stopLossPercentage / 100;
    
    if (side === PositionSide.LONG) {
      return entryPrice * (1 - stopLossRatio);
    } else {
      return entryPrice * (1 + stopLossRatio);
    }
  }
  
  /**
   * Suspend trading for a user
   */
  private async suspendTrading(userId: string, type: TradingSuspension['suspensionType'], reason: string): Promise<void> {
    const suspendedUntil = new Date();
    
    // Determine suspension duration based on type
    switch (type) {
      case 'daily_loss':
        // Suspend until next day
        suspendedUntil.setDate(suspendedUntil.getDate() + 1);
        suspendedUntil.setHours(0, 0, 0, 0); // Start of next day
        break;
      case 'consecutive_loss':
        // Suspend for 2 hours for cooling off
        suspendedUntil.setHours(suspendedUntil.getHours() + 2);
        break;
      case 'tier_violation':
        // Suspend for 24 hours
        suspendedUntil.setHours(suspendedUntil.getHours() + 24);
        break;
    }
    
    const suspension: TradingSuspension = {
      userId,
      reason,
      suspendedUntil,
      suspensionType: type,
      canTrade: false,
    };
    
    this.tradingSuspensions.set(userId, suspension);
    
    logger.warn(`Trading suspended for user ${userId}: ${reason}. Until: ${suspendedUntil.toISOString()}`);
    
    // Demote user tier if serious violation
    if (type === 'tier_violation') {
      await this.userTierService.demoteUser(userId, reason);
    }
  }
  
  /**
   * Record actual trade loss for daily tracking
   */
  async recordTradeLoss(userId: string, loss: number): Promise<void> {
    if (loss <= 0) return; // Only record losses
    
    const today = new Date().toISOString().split('T')[0];
    const key = `${userId}_${today}`;
    
    let dailyLoss = this.dailyLossTracking.get(key);
    if (!dailyLoss) {
      dailyLoss = { date: today, losses: 0, trades: 0 };
    }
    
    dailyLoss.losses += Math.abs(loss);
    dailyLoss.trades += 1;
    this.dailyLossTracking.set(key, dailyLoss);
    
    // Get user tier to check limits
    const userTier = await this.userTierService.getUserTier(userId);
    
    // Check if daily loss limit exceeded
    if (dailyLoss.losses >= userTier.limits.maxDailyLoss) {
      await this.suspendTrading(userId, 'daily_loss', 
        `Daily loss limit of $${userTier.limits.maxDailyLoss} exceeded with $${dailyLoss.losses.toFixed(2)} in losses`);
    }
    
    // Record trade in user tier service
    await this.userTierService.recordTrade(userId, {
      isWin: false,
      pnl: -loss,
      positionSize: 0, // Will be updated when we have full trade data
      holdTime: 0,
    });
  }
  
  /**
   * Check for consecutive loss patterns and suspend if needed
   */
  private async checkConsecutiveLossPattern(userId: string): Promise<void> {
    const profile = await this.userTierService.getUserProfile(userId);
    const userTier = await this.userTierService.getUserTier(userId);
    
    // If user has excessive consecutive losses, suspend for cooling off
    if (profile.statistics.consecutiveLosses >= 5) {
      await this.suspendTrading(userId, 'consecutive_loss', 
        `${profile.statistics.consecutiveLosses} consecutive losses detected. Cooling off period activated for better decision-making.`);
    }
  }
  
  /**
   * Get trading suspension status
   */
  async getTradingSuspensionStatus(userId: string): Promise<TradingSuspension | null> {
    const suspension = this.tradingSuspensions.get(userId);
    
    if (suspension) {
      const now = new Date();
      
      if (now >= suspension.suspendedUntil) {
        // Suspension expired
        this.tradingSuspensions.delete(userId);
        return null;
      }
      
      return suspension;
    }
    
    return null;
  }
  
  /**
   * Force lift suspension (admin only)
   */
  async liftTradingSuspension(userId: string, adminReason: string): Promise<boolean> {
    const suspension = this.tradingSuspensions.get(userId);
    
    if (suspension) {
      this.tradingSuspensions.delete(userId);
      logger.info(`Trading suspension lifted for user ${userId} by admin: ${adminReason}`);
      return true;
    }
    
    return false;
  }
  
  /**
   * Get user tier progression and limits
   */
  async getUserTierInfo(userId: string): Promise<{
    tier: UserTier;
    progression: any;
    dailyLossUsed: number;
    dailyLossRemaining: number;
  }> {
    const tier = await this.userTierService.getUserTier(userId);
    const progression = await this.userTierService.getTierProgression(userId);
    
    const today = new Date().toISOString().split('T')[0];
    const key = `${userId}_${today}`;
    const dailyLoss = this.dailyLossTracking.get(key);
    const dailyLossUsed = dailyLoss?.losses || 0;
    const dailyLossRemaining = Math.max(0, tier.limits.maxDailyLoss - dailyLossUsed);
    
    return {
      tier,
      progression,
      dailyLossUsed,
      dailyLossRemaining,
    };
  }

  /**
   * Update stop-loss for a position
   */
  async updateStopLoss(userId: string, positionId: string, newStopLoss: number | null): Promise<PerpetualPosition> {
    const position = this.positions.get(positionId);
    if (!position || position.userId !== userId) {
      throw new AppError('Position not found', 404);
    }
    
    if (position.status !== PositionStatus.OPEN) {
      throw new AppError('Cannot update stop-loss on closed position', 400);
    }
    
    const userTier = await this.userTierService.getUserTier(userId);
    
    // Check if tier requires mandatory stop-loss
    if (userTier.limits.forceStopLoss && !newStopLoss) {
      throw new AppError(
        `${userTier.tierName} requires mandatory stop-loss. Cannot remove stop-loss protection.`,
        400
      );
    }
    
    position.stopLoss = newStopLoss || undefined;
    logger.info(`Updated stop-loss for position ${positionId}: ${newStopLoss || 'removed'}`);
    
    return position;
  }
  
  /**
   * Get positions with stop-loss analysis
   */
  async getPositionsWithStopLoss(userId: string, isPaperTrading: boolean = true): Promise<{
    positions: PerpetualPosition[];
    stopLossAnalysis: {
      totalPositions: number;
      positionsWithStopLoss: number;
      mandatoryStopLossRequired: boolean;
      averageStopLossDistance: number;
    };
  }> {
    const portfolio = await this.getOrCreatePortfolio(userId, isPaperTrading);
    const userTier = await this.userTierService.getUserTier(userId);
    const openPositions = portfolio.positions.filter(p => p.status === PositionStatus.OPEN);
    
    const positionsWithStopLoss = openPositions.filter(p => p.stopLoss);
    const stopLossDistances = positionsWithStopLoss.map(p => {
      if (!p.stopLoss) return 0;
      const distance = Math.abs(p.markPrice - p.stopLoss) / p.markPrice;
      return distance * 100; // as percentage
    });
    
    const averageStopLossDistance = stopLossDistances.length > 0 ?
      stopLossDistances.reduce((sum, dist) => sum + dist, 0) / stopLossDistances.length : 0;
    
    return {
      positions: openPositions,
      stopLossAnalysis: {
        totalPositions: openPositions.length,
        positionsWithStopLoss: positionsWithStopLoss.length,
        mandatoryStopLossRequired: userTier.limits.forceStopLoss,
        averageStopLossDistance,
      },
    };
  }

  private generatePositionId(): string {
    return `pos_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  private generateId(): string {
    return `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}