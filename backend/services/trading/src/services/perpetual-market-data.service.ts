import { MarketData, FundingRateEntry, MarketDataSubscription } from '../types/perpetual';
import { logger } from '../utils/logger';
import { EventEmitter } from 'events';
import { LRUCache } from 'lru-cache';
import { setTimeout as delay } from 'timers/promises';

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

interface CircuitBreakerState {
  failures: number;
  lastFailureTime: Date | null;
  state: 'CLOSED' | 'OPEN' | 'HALF_OPEN';
  nextAttemptTime: Date | null;
}

interface RateLimiter {
  requests: number;
  windowStart: Date;
  maxRequests: number;
  windowMs: number;
}

interface DataSourceConfig {
  name: string;
  url: string;
  priority: number;
  enabled: boolean;
  lastUsed: Date | null;
}

export class PerpetualMarketDataService extends EventEmitter {
  private marketData: Map<string, MarketData> = new Map();
  private subscriptions: Map<string, MarketDataSubscription> = new Map();
  private fundingRateHistory: Map<string, FundingRateEntry[]> = new Map();
  private priceUpdateIntervals: Map<string, NodeJS.Timeout> = new Map();
  
  // Circuit breaker for API failures
  private circuitBreakers: Map<string, CircuitBreakerState> = new Map();
  private readonly FAILURE_THRESHOLD = 5;
  private readonly RECOVERY_TIMEOUT = 60000; // 1 minute
  private readonly HALF_OPEN_MAX_CALLS = 3;
  
  // Data caching
  private cache: LRUCache<string, MarketData>;
  private readonly CACHE_TTL = 5000; // 5 seconds
  
  // Rate limiting
  private rateLimiters: Map<string, RateLimiter> = new Map();
  private readonly DEFAULT_RATE_LIMIT = 100; // requests per minute
  
  // Data source failover
  private dataSources: DataSourceConfig[] = [
    { name: 'extended-exchange', url: 'https://api.extended.exchange', priority: 1, enabled: true, lastUsed: null },
    { name: 'binance-futures', url: 'https://fapi.binance.com', priority: 2, enabled: true, lastUsed: null },
    { name: 'demo-fallback', url: 'internal://demo', priority: 3, enabled: true, lastUsed: null }
  ];
  private currentDataSource: DataSourceConfig;
  
  // Funding rate predictions
  private fundingPredictions: Map<string, number[]> = new Map();

  constructor() {
    super();
    
    // Initialize cache
    this.cache = new LRUCache({
      max: 1000,
      ttl: this.CACHE_TTL
    });
    
    // Set primary data source
    this.currentDataSource = this.dataSources[0];
    
    // Initialize circuit breakers for all data sources
    this.dataSources.forEach(source => {
      this.circuitBreakers.set(source.name, {
        failures: 0,
        lastFailureTime: null,
        state: 'CLOSED',
        nextAttemptTime: null
      });
    });
    
    this.initializeDemoData();
    this.startMarketDataSimulation();
    this.startMaintenanceTasks();
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
   * Get current market data for a symbol with caching
   */
  async getMarketData(symbol: string): Promise<MarketData | null> {
    // Check cache first
    const cacheKey = `market_${symbol}`;
    const cached = this.cache.get(cacheKey);
    if (cached) {
      logger.debug(`Cache hit for ${symbol}`);
      return cached;
    }
    
    // Get from memory or fetch from source
    let data = this.marketData.get(symbol);
    
    if (!data) {
      // Try to fetch from external source with circuit breaker
      const fetchedData = await this.fetchWithCircuitBreaker(symbol);
      if (fetchedData) {
        data = fetchedData;
      }
    }
    
    if (data) {
      this.cache.set(cacheKey, data);
      return data;
    }
    
    return null;
  }

  /**
   * Get market data for all symbols
   */
  async getAllMarketData(): Promise<MarketData[]> {
    return Array.from(this.marketData.values());
  }

  /**
   * Get funding rate history for a symbol with predictions
   */
  async getFundingHistory(symbol: string, limit: number = 100): Promise<FundingRateEntry[]> {
    const history = this.fundingRateHistory.get(symbol) || [];
    return history.slice(-limit);
  }
  
  /**
   * Get funding rate predictions for next 3 periods
   */
  async getFundingPredictions(symbol: string): Promise<number[]> {
    const existing = this.fundingPredictions.get(symbol);
    if (existing && existing.length > 0) {
      return existing;
    }
    
    // Generate predictions based on historical data
    const predictions = this.generateFundingPredictions(symbol);
    this.fundingPredictions.set(symbol, predictions);
    
    return predictions;
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
   * Fetch data with circuit breaker pattern
   */
  private async fetchWithCircuitBreaker(symbol: string): Promise<MarketData | null> {
    const circuitBreaker = this.circuitBreakers.get(this.currentDataSource.name);
    if (!circuitBreaker) return null;
    
    // Check circuit breaker state
    if (circuitBreaker.state === 'OPEN') {
      if (circuitBreaker.nextAttemptTime && new Date() < circuitBreaker.nextAttemptTime) {
        logger.warn(`Circuit breaker OPEN for ${this.currentDataSource.name}, using fallback`);
        return await this.tryFallbackDataSource(symbol);
      } else {
        // Try to transition to HALF_OPEN
        circuitBreaker.state = 'HALF_OPEN';
        logger.info(`Circuit breaker transitioning to HALF_OPEN for ${this.currentDataSource.name}`);
      }
    }
    
    try {
      // Check rate limiting
      if (!this.checkRateLimit(this.currentDataSource.name)) {
        logger.warn(`Rate limit exceeded for ${this.currentDataSource.name}`);
        await delay(1000); // Wait 1 second
        return null;
      }
      
      // Attempt to fetch data
      const data = await this.fetchFromDataSource(symbol, this.currentDataSource);
      
      // Success - reset circuit breaker
      if (circuitBreaker.state === 'HALF_OPEN') {
        circuitBreaker.state = 'CLOSED';
        circuitBreaker.failures = 0;
        logger.info(`Circuit breaker CLOSED for ${this.currentDataSource.name}`);
      }
      
      return data;
      
    } catch (error) {
      return await this.handleFetchFailure(symbol, error as Error);
    }
  }
  
  /**
   * Handle fetch failures and circuit breaker logic
   */
  private async handleFetchFailure(symbol: string, error: Error): Promise<MarketData | null> {
    const circuitBreaker = this.circuitBreakers.get(this.currentDataSource.name);
    if (!circuitBreaker) return null;
    
    circuitBreaker.failures++;
    circuitBreaker.lastFailureTime = new Date();
    
    logger.error(`Data fetch failed for ${this.currentDataSource.name}: ${error.message}`);
    
    // Open circuit breaker if threshold exceeded
    if (circuitBreaker.failures >= this.FAILURE_THRESHOLD) {
      circuitBreaker.state = 'OPEN';
      circuitBreaker.nextAttemptTime = new Date(Date.now() + this.RECOVERY_TIMEOUT);
      logger.warn(`Circuit breaker OPEN for ${this.currentDataSource.name} after ${circuitBreaker.failures} failures`);
    }
    
    // Try fallback data source
    return await this.tryFallbackDataSource(symbol);
  }
  
  /**
   * Try fallback data sources in priority order
   */
  private async tryFallbackDataSource(symbol: string): Promise<MarketData | null> {
    const availableSources = this.dataSources
      .filter(source => source.enabled && source.name !== this.currentDataSource.name)
      .sort((a, b) => a.priority - b.priority);
    
    for (const source of availableSources) {
      const circuitBreaker = this.circuitBreakers.get(source.name);
      if (circuitBreaker?.state === 'OPEN') continue;
      
      try {
        logger.info(`Trying fallback data source: ${source.name}`);
        const data = await this.fetchFromDataSource(symbol, source);
        
        if (data) {
          // Temporarily switch to this source
          const previousSource = this.currentDataSource;
          this.currentDataSource = source;
          
          logger.info(`Switched from ${previousSource.name} to ${source.name}`);
          return data;
        }
      } catch (error) {
        logger.error(`Fallback source ${source.name} also failed: ${error}`);
        continue;
      }
    }
    
    // All sources failed, return cached/demo data
    logger.warn(`All data sources failed for ${symbol}, using demo data`);
    return this.marketData.get(symbol) || null;
  }
  
  /**
   * Fetch from specific data source
   */
  private async fetchFromDataSource(symbol: string, source: DataSourceConfig): Promise<MarketData | null> {
    source.lastUsed = new Date();
    
    switch (source.name) {
      case 'extended-exchange':
        return await this.fetchFromExtendedExchange(symbol);
      case 'binance-futures':
        return await this.fetchFromBinance(symbol);
      case 'demo-fallback':
      default:
        return this.marketData.get(symbol) || null;
    }
  }
  
  /**
   * Integration method for Extended Exchange API
   */
  private async fetchFromExtendedExchange(symbol: string): Promise<MarketData | null> {
    // This method will be implemented when integrating with Extended Exchange
    // For now, return demo data to simulate successful fetch
    logger.info(`[DEMO] Fetching ${symbol} from Extended Exchange`);
    
    // Simulate network delay
    await delay(100 + Math.random() * 200);
    
    // Simulate occasional failures for testing circuit breaker
    if (Math.random() < 0.1) { // 10% failure rate
      throw new Error('Extended Exchange API temporarily unavailable');
    }
    
    return this.marketData.get(symbol) || null;
  }
  
  /**
   * Fetch from Binance Futures API (fallback)
   */
  private async fetchFromBinance(symbol: string): Promise<MarketData | null> {
    // This would implement actual Binance API integration
    logger.info(`[DEMO] Fetching ${symbol} from Binance Futures`);
    
    // Simulate network delay
    await delay(150 + Math.random() * 300);
    
    // Return demo data for now
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
   * Check rate limiting for a data source
   */
  private checkRateLimit(sourceName: string): boolean {
    const now = new Date();
    let rateLimiter = this.rateLimiters.get(sourceName);
    
    if (!rateLimiter) {
      rateLimiter = {
        requests: 0,
        windowStart: now,
        maxRequests: this.DEFAULT_RATE_LIMIT,
        windowMs: 60000 // 1 minute
      };
      this.rateLimiters.set(sourceName, rateLimiter);
    }
    
    // Reset window if expired
    if (now.getTime() - rateLimiter.windowStart.getTime() >= rateLimiter.windowMs) {
      rateLimiter.requests = 0;
      rateLimiter.windowStart = now;
    }
    
    // Check if under limit
    if (rateLimiter.requests >= rateLimiter.maxRequests) {
      return false;
    }
    
    rateLimiter.requests++;
    return true;
  }
  
  /**
   * Generate funding rate predictions based on historical data
   */
  private generateFundingPredictions(symbol: string): number[] {
    const history = this.fundingRateHistory.get(symbol) || [];
    if (history.length < 3) {
      // Not enough data, return neutral predictions
      return [0.0001, 0.0001, 0.0001];
    }
    
    // Simple prediction based on recent trend
    const recent = history.slice(-6); // Last 6 periods
    const trend = this.calculateTrend(recent.map(h => h.rate));
    
    const lastRate = recent[recent.length - 1].rate;
    const predictions = [];
    
    for (let i = 1; i <= 3; i++) {
      const prediction = lastRate + (trend * i * 0.5); // Dampened trend
      predictions.push(Math.max(-0.003, Math.min(0.003, prediction))); // Cap at ±0.3%
    }
    
    return predictions;
  }
  
  /**
   * Calculate trend from array of values
   */
  private calculateTrend(values: number[]): number {
    if (values.length < 2) return 0;
    
    let sum = 0;
    for (let i = 1; i < values.length; i++) {
      sum += values[i] - values[i - 1];
    }
    
    return sum / (values.length - 1);
  }
  
  /**
   * Start maintenance tasks
   */
  private startMaintenanceTasks(): void {
    // Clean up old cache entries every 5 minutes
    setInterval(() => {
      this.cache.clear();
      logger.debug('Cache cleared during maintenance');
    }, 5 * 60 * 1000);
    
    // Update funding predictions every hour
    setInterval(() => {
      for (const symbol of this.marketData.keys()) {
        const predictions = this.generateFundingPredictions(symbol);
        this.fundingPredictions.set(symbol, predictions);
      }
      logger.debug('Updated funding rate predictions');
    }, 60 * 60 * 1000);
    
    // Monitor circuit breaker health every 30 seconds
    setInterval(() => {
      this.monitorCircuitBreakerHealth();
    }, 30 * 1000);
  }
  
  /**
   * Monitor circuit breaker health and attempt recovery
   */
  private monitorCircuitBreakerHealth(): void {
    for (const [sourceName, breaker] of this.circuitBreakers) {
      if (breaker.state === 'OPEN' && breaker.nextAttemptTime && new Date() >= breaker.nextAttemptTime) {
        breaker.state = 'HALF_OPEN';
        logger.info(`Circuit breaker for ${sourceName} ready for retry`);
      }
    }
  }
  
  /**
   * Get service health status
   */
  getHealthStatus(): any {
    const circuitBreakerStatus: any = {};
    for (const [sourceName, breaker] of this.circuitBreakers) {
      circuitBreakerStatus[sourceName] = {
        state: breaker.state,
        failures: breaker.failures,
        lastFailure: breaker.lastFailureTime
      };
    }
    
    return {
      currentDataSource: this.currentDataSource.name,
      circuitBreakers: circuitBreakerStatus,
      cacheSize: this.cache.size,
      rateLimiters: Object.fromEntries(
        Array.from(this.rateLimiters.entries()).map(([key, limiter]) => [
          key,
          {
            requests: limiter.requests,
            maxRequests: limiter.maxRequests,
            windowStart: limiter.windowStart
          }
        ])
      ),
      activeSubscriptions: this.subscriptions.size,
      marketDataSymbols: Array.from(this.marketData.keys())
    };
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
    
    // Clear cache
    this.cache.clear();
    
    logger.info('Market data service cleaned up');
  }
}