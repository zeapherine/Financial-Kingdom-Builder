import { logger } from '../utils/logger';
import { AppError } from '../utils/app-error';

export interface UserTier {
  tierName: string;
  level: number;
  requirements: {
    completedEducationModules: number;
    tradingExperience: number; // days
    totalTradingVolume: number;
    averageWinRate: number; // percentage
    maxConsecutiveLosses: number;
  };
  limits: {
    maxLeverage: number;
    maxPositionSize: number;
    maxDailyLoss: number;
    maxOpenPositions: number;
    maxOrderValue: number;
    dailyWithdrawalLimit: number;
    forceStopLoss: boolean;
    stopLossPercentage: number;
    requiresManualApproval: boolean;
    allowedInstruments: string[];
  };
  privileges: {
    accessToAdvancedOrders: boolean;
    accessToHighVolatilityPairs: boolean;
    prioritySupport: boolean;
    reducedFees: number; // percentage reduction
    accessToSignals: boolean;
    accessToAdvancedAnalytics: boolean;
  };
}

export interface UserProfile {
  userId: string;
  currentTier: string;
  tierLevel: number;
  registrationDate: Date;
  lastTierReview: Date;
  nextTierReview: Date;
  statistics: {
    completedEducationModules: number;
    tradingDays: number;
    totalTradingVolume: number;
    totalTrades: number;
    winningTrades: number;
    consecutiveLosses: number;
    maxConsecutiveLosses: number;
    currentStreak: number;
    averagePositionSize: number;
    averageHoldTime: number;
    largestWin: number;
    largestLoss: number;
  };
  violations: {
    riskLimitBreaches: number;
    liquidations: number;
    lastViolation: Date | null;
  };
}

export class UserTierService {
  private tiers: Map<string, UserTier> = new Map();
  private userProfiles: Map<string, UserProfile> = new Map();

  constructor() {
    this.initializeTierSystem();
  }

  private initializeTierSystem(): void {
    // Village Tier - Beginners
    this.tiers.set('village', {
      tierName: 'Village Ruler',
      level: 1,
      requirements: {
        completedEducationModules: 0,
        tradingExperience: 0,
        totalTradingVolume: 0,
        averageWinRate: 0,
        maxConsecutiveLosses: 999,
      },
      limits: {
        maxLeverage: 2,
        maxPositionSize: 500,
        maxDailyLoss: 100,
        maxOpenPositions: 2,
        maxOrderValue: 500,
        dailyWithdrawalLimit: 1000,
        forceStopLoss: true,
        stopLossPercentage: 15, // 15% stop loss mandatory
        requiresManualApproval: false,
        allowedInstruments: ['BTCUSDT', 'ETHUSDT'],
      },
      privileges: {
        accessToAdvancedOrders: false,
        accessToHighVolatilityPairs: false,
        prioritySupport: false,
        reducedFees: 0,
        accessToSignals: false,
        accessToAdvancedAnalytics: false,
      },
    });

    // Town Tier - Educated beginners
    this.tiers.set('town', {
      tierName: 'Town Mayor',
      level: 2,
      requirements: {
        completedEducationModules: 10,
        tradingExperience: 7,
        totalTradingVolume: 5000,
        averageWinRate: 40,
        maxConsecutiveLosses: 5,
      },
      limits: {
        maxLeverage: 5,
        maxPositionSize: 1000,
        maxDailyLoss: 250,
        maxOpenPositions: 3,
        maxOrderValue: 1000,
        dailyWithdrawalLimit: 2500,
        forceStopLoss: true,
        stopLossPercentage: 20, // 20% stop loss mandatory
        requiresManualApproval: false,
        allowedInstruments: ['BTCUSDT', 'ETHUSDT', 'ADAUSDT', 'SOLUSDT'],
      },
      privileges: {
        accessToAdvancedOrders: false,
        accessToHighVolatilityPairs: false,
        prioritySupport: false,
        reducedFees: 5,
        accessToSignals: true,
        accessToAdvancedAnalytics: false,
      },
    });

    // City Tier - Intermediate traders
    this.tiers.set('city', {
      tierName: 'City Governor',
      level: 3,
      requirements: {
        completedEducationModules: 20,
        tradingExperience: 30,
        totalTradingVolume: 25000,
        averageWinRate: 55,
        maxConsecutiveLosses: 3,
      },
      limits: {
        maxLeverage: 10,
        maxPositionSize: 2500,
        maxDailyLoss: 500,
        maxOpenPositions: 5,
        maxOrderValue: 2500,
        dailyWithdrawalLimit: 5000,
        forceStopLoss: false,
        stopLossPercentage: 25, // Optional stop loss
        requiresManualApproval: false,
        allowedInstruments: ['*'], // All available instruments
      },
      privileges: {
        accessToAdvancedOrders: true,
        accessToHighVolatilityPairs: false,
        prioritySupport: false,
        reducedFees: 10,
        accessToSignals: true,
        accessToAdvancedAnalytics: true,
      },
    });

    // Kingdom Tier - Advanced traders
    this.tiers.set('kingdom', {
      tierName: 'Kingdom Lord',
      level: 4,
      requirements: {
        completedEducationModules: 30,
        tradingExperience: 90,
        totalTradingVolume: 100000,
        averageWinRate: 65,
        maxConsecutiveLosses: 2,
      },
      limits: {
        maxLeverage: 20,
        maxPositionSize: 10000,
        maxDailyLoss: 1000,
        maxOpenPositions: 10,
        maxOrderValue: 10000,
        dailyWithdrawalLimit: 25000,
        forceStopLoss: false,
        stopLossPercentage: 30,
        requiresManualApproval: false,
        allowedInstruments: ['*'],
      },
      privileges: {
        accessToAdvancedOrders: true,
        accessToHighVolatilityPairs: true,
        prioritySupport: true,
        reducedFees: 20,
        accessToSignals: true,
        accessToAdvancedAnalytics: true,
      },
    });

    // Empire Tier - Expert traders
    this.tiers.set('empire', {
      tierName: 'Empire Sovereign',
      level: 5,
      requirements: {
        completedEducationModules: 40,
        tradingExperience: 180,
        totalTradingVolume: 500000,
        averageWinRate: 75,
        maxConsecutiveLosses: 1,
      },
      limits: {
        maxLeverage: 50,
        maxPositionSize: 50000,
        maxDailyLoss: 5000,
        maxOpenPositions: 20,
        maxOrderValue: 50000,
        dailyWithdrawalLimit: 100000,
        forceStopLoss: false,
        stopLossPercentage: 50,
        requiresManualApproval: true, // High-value trades need approval
        allowedInstruments: ['*'],
      },
      privileges: {
        accessToAdvancedOrders: true,
        accessToHighVolatilityPairs: true,
        prioritySupport: true,
        reducedFees: 30,
        accessToSignals: true,
        accessToAdvancedAnalytics: true,
      },
    });

    logger.info('User tier system initialized with 5 tiers');
  }

  /**
   * Get or create user profile
   */
  async getUserProfile(userId: string): Promise<UserProfile> {
    if (!this.userProfiles.has(userId)) {
      const newProfile: UserProfile = {
        userId,
        currentTier: 'village',
        tierLevel: 1,
        registrationDate: new Date(),
        lastTierReview: new Date(),
        nextTierReview: this.calculateNextReviewDate(new Date()),
        statistics: {
          completedEducationModules: 0,
          tradingDays: 0,
          totalTradingVolume: 0,
          totalTrades: 0,
          winningTrades: 0,
          consecutiveLosses: 0,
          maxConsecutiveLosses: 0,
          currentStreak: 0,
          averagePositionSize: 0,
          averageHoldTime: 0,
          largestWin: 0,
          largestLoss: 0,
        },
        violations: {
          riskLimitBreaches: 0,
          liquidations: 0,
          lastViolation: null,
        },
      };
      
      this.userProfiles.set(userId, newProfile);
      logger.info(`Created new user profile for ${userId} at Village tier`);
    }
    
    return this.userProfiles.get(userId)!;
  }

  /**
   * Get user's current tier configuration
   */
  async getUserTier(userId: string): Promise<UserTier> {
    const profile = await this.getUserProfile(userId);
    const tier = this.tiers.get(profile.currentTier);
    
    if (!tier) {
      throw new AppError(`Invalid tier: ${profile.currentTier}`, 500);
    }
    
    return tier;
  }

  /**
   * Check if user can be promoted to next tier
   */
  async checkTierPromotion(userId: string): Promise<{ canPromote: boolean; nextTier?: string; missingRequirements?: string[] }> {
    const profile = await this.getUserProfile(userId);
    const currentTierLevel = profile.tierLevel;
    
    // Find next tier
    const nextTierEntry = Array.from(this.tiers.entries())
      .find(([_, tier]) => tier.level === currentTierLevel + 1);
    
    if (!nextTierEntry) {
      return { canPromote: false }; // Already at highest tier
    }
    
    const [nextTierName, nextTier] = nextTierEntry;
    const requirements = nextTier.requirements;
    const stats = profile.statistics;
    const missingRequirements: string[] = [];
    
    // Check each requirement
    if (stats.completedEducationModules < requirements.completedEducationModules) {
      missingRequirements.push(`Complete ${requirements.completedEducationModules - stats.completedEducationModules} more education modules`);
    }
    
    if (stats.tradingDays < requirements.tradingExperience) {
      missingRequirements.push(`Gain ${requirements.tradingExperience - stats.tradingDays} more days of trading experience`);
    }
    
    if (stats.totalTradingVolume < requirements.totalTradingVolume) {
      missingRequirements.push(`Achieve $${(requirements.totalTradingVolume - stats.totalTradingVolume).toLocaleString()} more trading volume`);
    }
    
    const winRate = stats.totalTrades > 0 ? (stats.winningTrades / stats.totalTrades) * 100 : 0;
    if (winRate < requirements.averageWinRate) {
      missingRequirements.push(`Improve win rate to ${requirements.averageWinRate}% (current: ${winRate.toFixed(1)}%)`);
    }
    
    if (stats.maxConsecutiveLosses > requirements.maxConsecutiveLosses) {
      missingRequirements.push(`Reduce maximum consecutive losses to ${requirements.maxConsecutiveLosses} (current: ${stats.maxConsecutiveLosses})`);
    }
    
    const canPromote = missingRequirements.length === 0;
    
    return {
      canPromote,
      nextTier: nextTierName,
      missingRequirements: canPromote ? undefined : missingRequirements,
    };
  }

  /**
   * Promote user to next tier
   */
  async promoteUser(userId: string): Promise<boolean> {
    const promotionCheck = await this.checkTierPromotion(userId);
    
    if (!promotionCheck.canPromote || !promotionCheck.nextTier) {
      return false;
    }
    
    const profile = await this.getUserProfile(userId);
    const nextTier = this.tiers.get(promotionCheck.nextTier)!;
    
    profile.currentTier = promotionCheck.nextTier;
    profile.tierLevel = nextTier.level;
    profile.lastTierReview = new Date();
    profile.nextTierReview = this.calculateNextReviewDate(new Date());
    
    this.userProfiles.set(userId, profile);
    
    logger.info(`User ${userId} promoted to ${nextTier.tierName} (Level ${nextTier.level})`);
    return true;
  }

  /**
   * Demote user for violations
   */
  async demoteUser(userId: string, reason: string): Promise<boolean> {
    const profile = await this.getUserProfile(userId);
    
    if (profile.tierLevel <= 1) {
      return false; // Cannot demote below Village tier
    }
    
    // Find previous tier
    const previousTierEntry = Array.from(this.tiers.entries())
      .find(([_, tier]) => tier.level === profile.tierLevel - 1);
    
    if (!previousTierEntry) {
      return false;
    }
    
    const [previousTierName, previousTier] = previousTierEntry;
    
    profile.currentTier = previousTierName;
    profile.tierLevel = previousTier.level;
    profile.lastTierReview = new Date();
    profile.nextTierReview = this.calculateNextReviewDate(new Date(), 30); // Extended review period after demotion
    
    // Record violation
    profile.violations.riskLimitBreaches++;
    profile.violations.lastViolation = new Date();
    
    this.userProfiles.set(userId, profile);
    
    logger.warn(`User ${userId} demoted to ${previousTier.tierName} due to: ${reason}`);
    return true;
  }

  /**
   * Update user statistics
   */
  async updateUserStatistics(userId: string, updates: Partial<UserProfile['statistics']>): Promise<void> {
    const profile = await this.getUserProfile(userId);
    
    // Update statistics
    Object.assign(profile.statistics, updates);
    
    // Update trading days if this is a new trading day
    const lastTradeDate = new Date(profile.lastTierReview);
    const today = new Date();
    if (lastTradeDate.toDateString() !== today.toDateString()) {
      profile.statistics.tradingDays++;
    }
    
    this.userProfiles.set(userId, profile);
    
    // Check for tier promotion
    const promotionCheck = await this.checkTierPromotion(userId);
    if (promotionCheck.canPromote) {
      await this.promoteUser(userId);
    }
  }

  /**
   * Record trade outcome
   */
  async recordTrade(userId: string, tradeData: {
    isWin: boolean;
    pnl: number;
    positionSize: number;
    holdTime: number; // in minutes
  }): Promise<void> {
    const profile = await this.getUserProfile(userId);
    const stats = profile.statistics;
    
    stats.totalTrades++;
    stats.totalTradingVolume += tradeData.positionSize;
    
    if (tradeData.isWin) {
      stats.winningTrades++;
      stats.consecutiveLosses = 0;
      stats.currentStreak++;
      if (tradeData.pnl > stats.largestWin) {
        stats.largestWin = tradeData.pnl;
      }
    } else {
      stats.consecutiveLosses++;
      stats.currentStreak = 0;
      if (stats.consecutiveLosses > stats.maxConsecutiveLosses) {
        stats.maxConsecutiveLosses = stats.consecutiveLosses;
      }
      if (Math.abs(tradeData.pnl) > Math.abs(stats.largestLoss)) {
        stats.largestLoss = tradeData.pnl;
      }
    }
    
    // Update averages
    stats.averagePositionSize = stats.totalTradingVolume / stats.totalTrades;
    stats.averageHoldTime = ((stats.averageHoldTime * (stats.totalTrades - 1)) + tradeData.holdTime) / stats.totalTrades;
    
    await this.updateUserStatistics(userId, stats);
  }

  /**
   * Record education module completion
   */
  async recordEducationProgress(userId: string, modulesCompleted: number): Promise<void> {
    const profile = await this.getUserProfile(userId);
    profile.statistics.completedEducationModules = Math.max(
      profile.statistics.completedEducationModules,
      modulesCompleted
    );
    
    await this.updateUserStatistics(userId, profile.statistics);
  }

  /**
   * Get all available tiers
   */
  getAllTiers(): UserTier[] {
    return Array.from(this.tiers.values()).sort((a, b) => a.level - b.level);
  }

  /**
   * Get tier progression path for user
   */
  async getTierProgression(userId: string): Promise<{
    currentTier: UserTier;
    nextTier?: UserTier;
    progress: number; // 0-100
    requirements: string[];
  }> {
    const profile = await this.getUserProfile(userId);
    const currentTier = await this.getUserTier(userId);
    const promotionCheck = await this.checkTierPromotion(userId);
    
    let progress = 100; // Default for max tier
    let nextTier: UserTier | undefined;
    
    if (promotionCheck.nextTier) {
      nextTier = this.tiers.get(promotionCheck.nextTier)!;
      
      // Calculate progress based on requirements
      const requirements = nextTier.requirements;
      const stats = profile.statistics;
      
      const progressFactors = [
        Math.min(stats.completedEducationModules / requirements.completedEducationModules, 1),
        Math.min(stats.tradingDays / requirements.tradingExperience, 1),
        Math.min(stats.totalTradingVolume / requirements.totalTradingVolume, 1),
        Math.min((stats.winningTrades / Math.max(stats.totalTrades, 1) * 100) / requirements.averageWinRate, 1),
        stats.maxConsecutiveLosses <= requirements.maxConsecutiveLosses ? 1 : 0,
      ];
      
      progress = (progressFactors.reduce((sum, factor) => sum + factor, 0) / progressFactors.length) * 100;
    }
    
    return {
      currentTier,
      nextTier,
      progress,
      requirements: promotionCheck.missingRequirements || [],
    };
  }

  private calculateNextReviewDate(from: Date, daysFromNow: number = 7): Date {
    const nextReview = new Date(from);
    nextReview.setDate(nextReview.getDate() + daysFromNow);
    return nextReview;
  }
}