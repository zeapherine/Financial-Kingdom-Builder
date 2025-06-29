// Perpetual Trading Types for Extended Exchange Integration
// Designed to match Extended's API structure while supporting paper trading

export enum PositionSide {
  LONG = 'long',
  SHORT = 'short'
}

export enum PositionStatus {
  OPEN = 'open',
  CLOSED = 'closed',
  LIQUIDATED = 'liquidated'
}

export enum OrderType {
  MARKET = 'market',
  LIMIT = 'limit',
  STOP_MARKET = 'stop_market',
  STOP_LIMIT = 'stop_limit',
  TAKE_PROFIT_MARKET = 'take_profit_market',
  TAKE_PROFIT_LIMIT = 'take_profit_limit'
}

export enum OrderStatus {
  NEW = 'new',
  PARTIALLY_FILLED = 'partially_filled',
  FILLED = 'filled',
  CANCELED = 'canceled',
  REJECTED = 'rejected',
  EXPIRED = 'expired'
}

export interface PerpetualPosition {
  id: string;
  userId: string;
  symbol: string; // e.g., 'BTCUSDT'
  side: PositionSide;
  entryPrice: number;
  markPrice: number;
  size: number; // Position size in base currency
  leverage: number;
  margin: number; // Initial margin requirement
  marginRatio: number; // Current margin ratio
  unrealizedPnl: number;
  realizedPnl: number;
  liquidationPrice: number;
  status: PositionStatus;
  openTime: Date;
  closeTime?: Date;
  closePrice?: number;
  fundingPaid: number; // Cumulative funding payments
  isPaperTrading: boolean;
  
  // Extended Exchange specific fields (for future real trading)
  extendedPositionId?: string;
  extendedOrderId?: string;
  
  // Risk management
  stopLoss?: number;
  takeProfit?: number;
  autoDeleverage?: boolean;
}

export interface PerpetualOrder {
  id: string;
  userId: string;
  clientOrderId?: string;
  symbol: string;
  side: PositionSide;
  type: OrderType;
  size: number;
  price?: number; // For limit orders
  stopPrice?: number; // For stop orders
  leverage: number;
  status: OrderStatus;
  filledSize: number;
  avgFillPrice?: number;
  fee: number;
  timestamp: Date;
  updateTime: Date;
  isPaperTrading: boolean;
  
  // Extended Exchange specific fields
  extendedOrderId?: string;
  extendedClientId?: string;
  
  // Risk management
  reduceOnly?: boolean; // Position reduction only
  postOnly?: boolean; // Maker-only order
  timeInForce?: 'GTC' | 'IOC' | 'FOK'; // Good Till Cancel, Immediate Or Cancel, Fill Or Kill
}

export interface MarketData {
  symbol: string;
  price: number; // Current mark price
  indexPrice: number; // Underlying index price
  markPrice: number; // Mark price for liquidation calculations
  change24h: number;
  changePercent24h: number;
  volume24h: number;
  fundingRate: number; // Current funding rate
  fundingTime: Date; // Next funding time
  fundingHistory: FundingRateEntry[];
  openInterest: number;
  lastUpdate: Date;
  
  // Extended Exchange specific fields
  extendedSymbol?: string;
  extendedData?: any;
  
  // Additional perpetual-specific data
  maxLeverage: number;
  minOrderSize: number;
  tickSize: number; // Minimum price increment
  stepSize: number; // Minimum quantity increment
}

export interface FundingRateEntry {
  timestamp: Date;
  rate: number;
  symbol: string;
}

export interface PerpetualPortfolio {
  userId: string;
  totalBalance: number; // Total account balance
  availableBalance: number; // Available for new positions
  usedMargin: number; // Margin tied up in positions
  unrealizedPnl: number; // Total unrealized P&L
  totalEquity: number; // Total balance + unrealized PnL
  marginRatio: number; // Used margin / total equity
  positions: PerpetualPosition[];
  isPaperTrading: boolean;
  
  // Risk metrics
  maxDrawdown: number;
  dailyPnl: number;
  totalFees: number;
  totalFunding: number;
  
  // Extended Exchange specific
  extendedAccountId?: string;
  extendedApiKey?: string; // Encrypted
}

export interface LiquidationEvent {
  id: string;
  userId: string;
  positionId: string;
  symbol: string;
  side: PositionSide;
  size: number;
  liquidationPrice: number;
  markPrice: number;
  pnl: number;
  fee: number;
  timestamp: Date;
  isPaperTrading: boolean;
}

export interface FundingPayment {
  id: string;
  userId: string;
  positionId: string;
  symbol: string;
  rate: number;
  payment: number; // Positive = received, negative = paid
  timestamp: Date;
  isPaperTrading: boolean;
}

// Request/Response types for API endpoints
export interface OpenPositionRequest {
  symbol: string;
  side: PositionSide;
  size: number;
  leverage: number;
  orderType?: OrderType;
  price?: number; // For limit orders
  stopLoss?: number;
  takeProfit?: number;
  isPaperTrading: boolean;
}

export interface ClosePositionRequest {
  positionId: string;
  size?: number; // Partial close if specified
  orderType?: OrderType;
  price?: number; // For limit orders
}

export interface UpdatePositionRequest {
  positionId: string;
  stopLoss?: number;
  takeProfit?: number;
  leverage?: number; // Adjust leverage
}

export interface MarketDataSubscription {
  symbols: string[];
  userId: string;
  includeOrderBook?: boolean;
  includeTrades?: boolean;
  includeFunding?: boolean;
}

// Extended Exchange API Integration Types
export interface ExtendedExchangeConfig {
  apiKey: string;
  apiSecret: string;
  testnet: boolean;
  baseUrl: string;
}

export interface ExtendedOrderRequest {
  symbol: string;
  side: 'buy' | 'sell';
  type: string;
  quantity: string;
  price?: string;
  timeInForce?: string;
  reduceOnly?: boolean;
  postOnly?: boolean;
  leverage?: number;
}

export interface ExtendedPositionResponse {
  symbol: string;
  positionAmt: string;
  entryPrice: string;
  markPrice: string;
  unRealizedProfit: string;
  liquidationPrice: string;
  leverage: string;
  marginType: string;
  isolatedMargin: string;
  isAutoAddMargin: string;
  positionSide: string;
  notional: string;
  isolatedWallet: string;
  updateTime: number;
}

// Risk management types
export interface RiskLimits {
  maxLeverage: number;
  maxPositionSize: number;
  maxDailyLoss: number;
  maxOpenPositions: number;
  maxOrderValue: number;
  forceStopLoss: boolean; // For beginner users
}

export interface RiskWarning {
  type: 'liquidation' | 'margin' | 'daily_loss' | 'position_size';
  severity: 'low' | 'medium' | 'high' | 'critical';
  message: string;
  positionId?: string;
  threshold?: number;
  current?: number;
}