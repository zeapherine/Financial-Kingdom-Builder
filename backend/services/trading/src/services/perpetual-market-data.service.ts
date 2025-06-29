import { MarketData, FundingRateEntry, MarketDataSubscription } from '../types/perpetual';
import { logger } from '../utils/logger';
import { EventEmitter } from 'events';

interface ExtendedMarketDataResponse {
  symbol: string;
  price: string;
  priceChange: string;
  priceChangePercent: string;
  volume: string;
  count: number;
  lastPrice: string;
  lastQty: string;
  openPrice: string;
  highPrice: string;
  lowPrice: string;
}

interface ExtendedFundingRateResponse {
  symbol: string;
  fundingRate: string;
  fundingTime: number;
}

export class PerpetualMarketDataService extends EventEmitter {
  private marketData: Map<string, MarketData> = new Map();
  private subscriptions: Map<string, MarketDataSubscription> = new Map();
  private fundingRateHistory: Map<string, FundingRateEntry[]> = new Map();
  private priceUpdateIntervals: Map<string, NodeJS.Timeout> = new Map();

  constructor() {
    super();
    this.initializeDemoData();
    this.startMarketDataSimulation();
  }

  /**
   * Initialize demo market data for development
   */
  private initializeDemoData(): void {
    const symbols = ['BTCUSDT', 'ETHUSDT', 'ADAUSDT', 'SOLUSDT'];
    
    const demoData: Partial<MarketData>[] = [
      {
        symbol: 'BTCUSDT',
        price: 45230.0,
        indexPrice: 45225.0,
        change24h: 1087.50,
        changePercent24h: 2.45,
        volume24h: 28756234.50,
        fundingRate: 0.0001,
        openInterest: 125486,
        maxLeverage: 125,
        minOrderSize: 0.001,
        tickSize: 0.1,
        stepSize: 0.001
      },
      {
        symbol: 'ETHUSDT',
        price: 3150.0,
        indexPrice: 3148.5,
        change24h: 38.25,
        changePercent24h: 1.23,
        volume24h: 15234567.25,
        fundingRate: -0.0002,
        openInterest: 89342,
        maxLeverage: 100,
        minOrderSize: 0.01,
        tickSize: 0.01,
        stepSize: 0.01
      },
      {
        symbol: 'ADAUSDT',
        price: 0.4567,
        indexPrice: 0.4565,
        change24h: -0.0123,
        changePercent24h: -2.63,
        volume24h: 8945123.75,
        fundingRate: 0.00015,
        openInterest: 45678,
        maxLeverage: 75,
        minOrderSize: 1,
        tickSize: 0.0001,
        stepSize: 1
      },
      {
        symbol: 'SOLUSDT',
        price: 98.45,
        indexPrice: 98.42,
        change24h: 5.67,
        changePercent24h: 6.11,
        volume24h: 5234567.25,
        fundingRate: -0.00005,
        openInterest: 23456,
        maxLeverage: 50,
        minOrderSize: 0.1,
        tickSize: 0.01,
        stepSize: 0.1
      }
    ];

    demoData.forEach(data => {
      const marketData: MarketData = {
        symbol: data.symbol!,
        price: data.price!,
        indexPrice: data.indexPrice!,
        markPrice: data.price!, // Mark price = current price for demo
        change24h: data.change24h!,
        changePercent24h: data.changePercent24h!,
        volume24h: data.volume24h!,
        fundingRate: data.fundingRate!,
        fundingTime: this.getNextFundingTime(),
        fundingHistory: this.generateFundingHistory(data.symbol!, data.fundingRate!),
        openInterest: data.openInterest!,
        lastUpdate: new Date(),
        maxLeverage: data.maxLeverage!,
        minOrderSize: data.minOrderSize!,
        tickSize: data.tickSize!,
        stepSize: data.stepSize!
      };

      this.marketData.set(data.symbol!, marketData);
      logger.info(`Initialized demo data for ${data.symbol}`);
    });
  }

  /**
   * Start real-time market data simulation
   */
  private startMarketDataSimulation(): void {
    // Update prices every 5 seconds for demo
    const symbols = Array.from(this.marketData.keys());
    
    symbols.forEach(symbol => {
      const interval = setInterval(() => {
        this.simulatePriceUpdate(symbol);
      }, 5000);
      
      this.priceUpdateIntervals.set(symbol, interval);
    });

    // Update funding rates every 8 hours
    setInterval(() => {
      this.updateFundingRates();
    }, 8 * 60 * 60 * 1000);

    logger.info('Started market data simulation');
  }

  /**
   * Get current market data for a symbol
   */
  async getMarketData(symbol: string): Promise<MarketData | null> {
    return this.marketData.get(symbol) || null;
  }

  /**
   * Get market data for all symbols
   */
  async getAllMarketData(): Promise<MarketData[]> {
    return Array.from(this.marketData.values());
  }

  /**
   * Get funding rate history for a symbol
   */
  async getFundingHistory(symbol: string, limit: number = 100): Promise<FundingRateEntry[]> {
    const history = this.fundingRateHistory.get(symbol) || [];
    return history.slice(-limit);
  }

  /**
   * Subscribe to market data updates
   */
  async subscribe(subscription: MarketDataSubscription): Promise<void> {
    this.subscriptions.set(subscription.userId, subscription);
    
    // Send initial data
    const initialData: MarketData[] = [];
    for (const symbol of subscription.symbols) {
      const data = this.marketData.get(symbol);
      if (data) {
        initialData.push(data);
      }
    }

    this.emit('marketData', {
      userId: subscription.userId,
      data: initialData
    });

    logger.info(`User ${subscription.userId} subscribed to ${subscription.symbols.join(', ')}`);
  }

  /**
   * Unsubscribe from market data updates
   */
  async unsubscribe(userId: string): Promise<void> {
    this.subscriptions.delete(userId);
    logger.info(`User ${userId} unsubscribed from market data`);
  }

  /**
   * Simulate price update for development
   */
  async simulatePriceUpdate(symbol: string, newPrice?: number): Promise<void> {
    const currentData = this.marketData.get(symbol);
    if (!currentData) return;

    // Generate realistic price movement or use provided price
    const price = newPrice || this.generateRealisticPrice(currentData.price);
    const change24h = price - (currentData.price - currentData.change24h);
    const changePercent24h = ((change24h) / (price - change24h)) * 100;

    const updatedData: MarketData = {
      ...currentData,
      price,
      markPrice: price, // For demo, mark price = price
      indexPrice: price * (0.999 + Math.random() * 0.002), // Slight index difference
      change24h,
      changePercent24h,
      lastUpdate: new Date()
    };

    this.marketData.set(symbol, updatedData);

    // Notify subscribers
    this.notifySubscribers(symbol, updatedData);

    // Emit price update event for portfolio service
    this.emit('priceUpdate', {
      symbol,
      price,
      markPrice: price
    });
  }

  /**
   * Update funding rates for all symbols
   */
  private async updateFundingRates(): Promise<void> {
    for (const [symbol, data] of this.marketData) {
      // Generate new funding rate based on market conditions
      const newFundingRate = this.generateFundingRate(data.changePercent24h);
      
      // Add to history
      const historyEntry: FundingRateEntry = {
        timestamp: new Date(),
        rate: newFundingRate,
        symbol
      };

      const history = this.fundingRateHistory.get(symbol) || [];
      history.push(historyEntry);
      
      // Keep only last 1000 entries
      if (history.length > 1000) {
        history.splice(0, history.length - 1000);
      }
      
      this.fundingRateHistory.set(symbol, history);

      // Update market data
      const updatedData: MarketData = {
        ...data,
        fundingRate: newFundingRate,
        fundingTime: this.getNextFundingTime(),
        fundingHistory: history.slice(-24), // Last 24 funding periods
        lastUpdate: new Date()
      };

      this.marketData.set(symbol, updatedData);

      // Emit funding rate update
      this.emit('fundingUpdate', {
        symbol,
        rate: newFundingRate,
        timestamp: new Date()
      });
    }

    logger.info('Updated funding rates for all symbols');
  }

  /**
   * Integration method for Extended Exchange API
   */
  async fetchFromExtendedExchange(symbol: string): Promise<MarketData | null> {
    // This method will be implemented when integrating with Extended Exchange
    // For now, return demo data
    logger.info(`[FUTURE] Fetching ${symbol} from Extended Exchange`);
    return this.marketData.get(symbol) || null;
  }

  /**
   * Update market data from Extended Exchange
   */
  async updateFromExtendedExchange(): Promise<void> {
    // This method will implement real Extended Exchange integration
    logger.info('[FUTURE] Updating market data from Extended Exchange');
    
    // TODO: Implement Extended Exchange API calls
    // const symbols = Array.from(this.marketData.keys());
    // for (const symbol of symbols) {
    //   const data = await this.fetchFromExtendedExchange(symbol);
    //   if (data) {
    //     this.marketData.set(symbol, data);
    //     this.notifySubscribers(symbol, data);
    //   }
    // }
  }

  // Private helper methods

  private generateRealisticPrice(currentPrice: number): number {
    // Generate realistic price movement (±2% max)
    const volatility = 0.02;
    const randomChange = (Math.random() - 0.5) * 2 * volatility;
    return currentPrice * (1 + randomChange);
  }

  private generateFundingRate(changePercent24h: number): number {
    // Generate funding rate based on price movement
    // Positive funding rate when price is rising (longs pay shorts)
    // Negative funding rate when price is falling (shorts pay longs)
    const baseRate = changePercent24h * 0.0001; // Base correlation
    const noise = (Math.random() - 0.5) * 0.0002; // Random noise
    return Math.max(-0.003, Math.min(0.003, baseRate + noise)); // Cap at ±0.3%
  }

  private generateFundingHistory(symbol: string, currentRate: number): FundingRateEntry[] {
    const history: FundingRateEntry[] = [];
    const now = new Date();
    
    // Generate last 24 funding periods (every 8 hours)
    for (let i = 23; i >= 0; i--) {
      const timestamp = new Date(now.getTime() - i * 8 * 60 * 60 * 1000);
      const rate = currentRate + (Math.random() - 0.5) * 0.0004; // Slight variation
      
      history.push({
        timestamp,
        rate,
        symbol
      });
    }

    this.fundingRateHistory.set(symbol, history);
    return history;
  }

  private getNextFundingTime(): Date {
    const now = new Date();
    const hours = now.getUTCHours();
    
    // Funding times: 00:00, 08:00, 16:00 UTC
    let nextFundingHour: number;
    if (hours < 8) {
      nextFundingHour = 8;
    } else if (hours < 16) {
      nextFundingHour = 16;
    } else {
      nextFundingHour = 24; // Next day 00:00
    }

    const nextFundingTime = new Date(now);
    nextFundingTime.setUTCHours(nextFundingHour % 24, 0, 0, 0);
    
    if (nextFundingHour === 24) {
      nextFundingTime.setUTCDate(nextFundingTime.getUTCDate() + 1);
    }

    return nextFundingTime;
  }

  private notifySubscribers(symbol: string, data: MarketData): void {
    for (const [userId, subscription] of this.subscriptions) {
      if (subscription.symbols.includes(symbol)) {
        this.emit('marketData', {
          userId,
          data: [data]
        });
      }
    }
  }

  /**
   * Cleanup resources
   */
  public cleanup(): void {
    // Clear all intervals
    for (const interval of this.priceUpdateIntervals.values()) {
      clearInterval(interval);
    }
    this.priceUpdateIntervals.clear();
    
    logger.info('Market data service cleaned up');
  }
}