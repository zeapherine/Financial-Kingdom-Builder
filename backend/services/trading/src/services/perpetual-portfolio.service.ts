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

export class PerpetualPortfolioService {
  private portfolios: Map<string, PerpetualPortfolio> = new Map();
  private positions: Map<string, PerpetualPosition> = new Map();
  private riskLimits: Map<string, RiskLimits> = new Map();

  constructor() {
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
   * Open a new perpetual position
   */
  async openPosition(userId: string, request: OpenPositionRequest, currentPrice: number): Promise<PerpetualPosition> {
    const portfolio = await this.getOrCreatePortfolio(userId, request.isPaperTrading);
    const riskLimits = this.getRiskLimits(userId);

    // Validate request
    this.validateOpenPositionRequest(request, portfolio, riskLimits, currentPrice);

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
      stopLoss: request.stopLoss,
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

  private validateOpenPositionRequest(
    request: OpenPositionRequest,
    portfolio: PerpetualPortfolio,
    riskLimits: RiskLimits,
    currentPrice: number
  ): void {
    if (request.leverage > riskLimits.maxLeverage) {
      throw new AppError(`Leverage ${request.leverage}x exceeds maximum allowed ${riskLimits.maxLeverage}x`, 400);
    }

    if (request.size > riskLimits.maxPositionSize) {
      throw new AppError(`Position size $${request.size} exceeds maximum allowed $${riskLimits.maxPositionSize}`, 400);
    }

    const openPositionsCount = portfolio.positions.filter(p => p.status === PositionStatus.OPEN).length;
    if (openPositionsCount >= riskLimits.maxOpenPositions) {
      throw new AppError(`Maximum open positions (${riskLimits.maxOpenPositions}) reached`, 400);
    }

    if (request.size > riskLimits.maxOrderValue) {
      throw new AppError(`Order value $${request.size} exceeds maximum allowed $${riskLimits.maxOrderValue}`, 400);
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

  private generatePositionId(): string {
    return `pos_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  private generateId(): string {
    return `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}