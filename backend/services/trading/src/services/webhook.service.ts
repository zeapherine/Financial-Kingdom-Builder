import crypto from 'crypto';
import { logger } from '../utils/logger';
import { AppError } from '../utils/app-error';
import { PerpetualPortfolioService } from './perpetual-portfolio.service';
import { ExtendedExchangeService } from './extended-exchange.service';
import { PositionSide, PositionStatus } from '../types/perpetual';

export interface WebhookEvent {
  id: string;
  type: string;
  timestamp: Date;
  data: any;
  signature?: string;
}

export interface PositionUpdateEvent {
  type: 'position.updated' | 'position.closed' | 'position.liquidated';
  userId: string;
  positionId: string;
  symbol: string;
  side: PositionSide;
  size: number;
  entryPrice: number;
  markPrice: number;
  unrealizedPnl: number;
  margin: number;
  leverage: number;
  status: PositionStatus;
  timestamp: string;
}

export interface OrderUpdateEvent {
  type: 'order.filled' | 'order.cancelled' | 'order.rejected';
  userId: string;
  orderId: string;
  positionId?: string;
  symbol: string;
  side: PositionSide;
  size: number;
  price: number;
  status: string;
  timestamp: string;
}

export interface AccountUpdateEvent {
  type: 'account.updated';
  userId: string;
  balance: number;
  availableBalance: number;
  usedMargin: number;
  unrealizedPnl: number;
  timestamp: string;
}

export interface LiquidationEvent {
  type: 'position.liquidated';
  userId: string;
  positionId: string;
  symbol: string;
  side: PositionSide;
  size: number;
  liquidationPrice: number;
  liquidationTime: string;
  liquidationType: 'partial' | 'full';
}

export interface FundingPaymentEvent {
  type: 'funding.payment';
  userId: string;
  positionId: string;
  symbol: string;
  rate: number;
  payment: number;
  timestamp: string;
}

export class WebhookService {
  private portfolioService: PerpetualPortfolioService;
  private exchangeService: ExtendedExchangeService;
  private webhookSecret: string;
  private eventProcessors: Map<string, (event: any) => Promise<void>>;

  constructor(
    portfolioService: PerpetualPortfolioService,
    exchangeService: ExtendedExchangeService
  ) {
    this.portfolioService = portfolioService;
    this.exchangeService = exchangeService;
    this.webhookSecret = process.env.EXTENDED_EXCHANGE_WEBHOOK_SECRET || 'default_secret';
    
    this.eventProcessors = new Map([
      ['position.updated', this.handlePositionUpdate.bind(this)],
      ['position.closed', this.handlePositionClosed.bind(this)],
      ['position.liquidated', this.handlePositionLiquidated.bind(this)],
      ['order.filled', this.handleOrderFilled.bind(this)],
      ['order.cancelled', this.handleOrderCancelled.bind(this)],
      ['order.rejected', this.handleOrderRejected.bind(this)],
      ['account.updated', this.handleAccountUpdate.bind(this)],
      ['funding.payment', this.handleFundingPayment.bind(this)],
    ]);

    logger.info('Webhook Service initialized with Extended Exchange integration');
  }

  /**
   * Verify webhook signature from Extended Exchange
   */
  verifyWebhookSignature(payload: string, signature: string): boolean {
    try {
      const expectedSignature = crypto
        .createHmac('sha256', this.webhookSecret)
        .update(payload)
        .digest('hex');
      
      const providedSignature = signature.replace('sha256=', '');
      
      return crypto.timingSafeEqual(
        Buffer.from(expectedSignature, 'hex'),
        Buffer.from(providedSignature, 'hex')
      );
    } catch (error) {
      logger.error('Webhook signature verification failed:', error);
      return false;
    }
  }

  /**
   * Process incoming webhook from Extended Exchange
   */
  async processWebhook(payload: string, signature: string): Promise<void> {
    try {
      // Verify signature
      if (!this.verifyWebhookSignature(payload, signature)) {
        throw new AppError('Invalid webhook signature', 401);
      }

      const event: WebhookEvent = JSON.parse(payload);
      
      // Validate event structure
      if (!event.type || !event.data || !event.timestamp) {
        throw new AppError('Invalid webhook event structure', 400);
      }

      logger.info(`Processing webhook event: ${event.type}`, { eventId: event.id });

      // Get processor for event type
      const processor = this.eventProcessors.get(event.type);
      if (!processor) {
        logger.warn(`No processor found for event type: ${event.type}`);
        return;
      }

      // Process event
      await processor(event.data);
      
      logger.info(`Successfully processed webhook event: ${event.type}`, { eventId: event.id });

    } catch (error) {
      logger.error('Webhook processing failed:', error);
      throw error;
    }
  }

  /**
   * Handle position update events
   */
  private async handlePositionUpdate(data: PositionUpdateEvent): Promise<void> {
    try {
      const { userId, positionId, markPrice, unrealizedPnl, status } = data;
      
      // Update position in our system
      await this.portfolioService.updatePositionFromExchange(
        userId,
        positionId,
        {
          markPrice,
          unrealizedPnl,
          status,
          lastUpdate: new Date(data.timestamp),
        }
      );

      logger.info(`Position updated for user ${userId}: ${positionId}`, {
        markPrice,
        unrealizedPnl,
        status,
      });

    } catch (error) {
      logger.error('Position update handling failed:', error);
      throw error;
    }
  }

  /**
   * Handle position closed events
   */
  private async handlePositionClosed(data: PositionUpdateEvent): Promise<void> {
    try {
      const { userId, positionId, markPrice } = data;
      
      // Close position in our system
      await this.portfolioService.closePositionFromExchange(
        userId,
        positionId,
        markPrice,
        new Date(data.timestamp)
      );

      logger.info(`Position closed for user ${userId}: ${positionId}`, {
        closePrice: markPrice,
        closeTime: data.timestamp,
      });

    } catch (error) {
      logger.error('Position close handling failed:', error);
      throw error;
    }
  }

  /**
   * Handle position liquidation events
   */
  private async handlePositionLiquidated(data: LiquidationEvent): Promise<void> {
    try {
      const { userId, positionId, liquidationPrice, liquidationType } = data;
      
      // Handle liquidation in our system
      await this.portfolioService.liquidatePositionFromExchange(
        userId,
        positionId,
        liquidationPrice,
        liquidationType,
        new Date(data.liquidationTime)
      );

      logger.warn(`Position liquidated for user ${userId}: ${positionId}`, {
        liquidationPrice,
        liquidationType,
        liquidationTime: data.liquidationTime,
      });

      // Send emergency notification to user
      await this.sendLiquidationAlert(userId, positionId, liquidationPrice, liquidationType);

    } catch (error) {
      logger.error('Position liquidation handling failed:', error);
      throw error;
    }
  }

  /**
   * Handle order filled events
   */
  private async handleOrderFilled(data: OrderUpdateEvent): Promise<void> {
    try {
      const { userId, orderId, positionId, symbol, side, size, price } = data;
      
      // Update order status and position
      await this.portfolioService.updateOrderStatus(
        userId,
        orderId,
        'filled',
        {
          fillPrice: price,
          fillSize: size,
          fillTime: new Date(data.timestamp),
          positionId,
        }
      );

      logger.info(`Order filled for user ${userId}: ${orderId}`, {
        symbol,
        side,
        size,
        price,
        positionId,
      });

    } catch (error) {
      logger.error('Order fill handling failed:', error);
      throw error;
    }
  }

  /**
   * Handle order cancelled events
   */
  private async handleOrderCancelled(data: OrderUpdateEvent): Promise<void> {
    try {
      const { userId, orderId } = data;
      
      await this.portfolioService.updateOrderStatus(
        userId,
        orderId,
        'cancelled',
        {
          cancelledAt: new Date(data.timestamp),
        }
      );

      logger.info(`Order cancelled for user ${userId}: ${orderId}`);

    } catch (error) {
      logger.error('Order cancellation handling failed:', error);
      throw error;
    }
  }

  /**
   * Handle order rejected events
   */
  private async handleOrderRejected(data: OrderUpdateEvent): Promise<void> {
    try {
      const { userId, orderId } = data;
      
      await this.portfolioService.updateOrderStatus(
        userId,
        orderId,
        'rejected',
        {
          rejectedAt: new Date(data.timestamp),
          rejectionReason: 'Order rejected by exchange',
        }
      );

      logger.warn(`Order rejected for user ${userId}: ${orderId}`);

    } catch (error) {
      logger.error('Order rejection handling failed:', error);
      throw error;
    }
  }

  /**
   * Handle account update events
   */
  private async handleAccountUpdate(data: AccountUpdateEvent): Promise<void> {
    try {
      const { userId, balance, availableBalance, usedMargin, unrealizedPnl } = data;
      
      // Update portfolio balances
      await this.portfolioService.updateAccountBalance(
        userId,
        {
          totalBalance: balance,
          availableBalance,
          usedMargin,
          unrealizedPnl,
          lastUpdate: new Date(data.timestamp),
        }
      );

      logger.info(`Account updated for user ${userId}`, {
        balance,
        availableBalance,
        usedMargin,
        unrealizedPnl,
      });

    } catch (error) {
      logger.error('Account update handling failed:', error);
      throw error;
    }
  }

  /**
   * Handle funding payment events
   */
  private async handleFundingPayment(data: FundingPaymentEvent): Promise<void> {
    try {
      const { userId, positionId, symbol, rate, payment } = data;
      
      // Apply funding payment
      await this.portfolioService.applyFundingPaymentFromExchange(
        userId,
        positionId,
        {
          symbol,
          rate,
          payment,
          timestamp: new Date(data.timestamp),
        }
      );

      logger.info(`Funding payment applied for user ${userId}`, {
        positionId,
        symbol,
        rate,
        payment,
      });

    } catch (error) {
      logger.error('Funding payment handling failed:', error);
      throw error;
    }
  }

  /**
   * Send liquidation alert to user
   */
  private async sendLiquidationAlert(
    userId: string,
    positionId: string,
    liquidationPrice: number,
    liquidationType: string
  ): Promise<void> {
    try {
      // In production, would send push notification, email, SMS
      logger.info(`Liquidation alert sent to user ${userId}`, {
        positionId,
        liquidationPrice,
        liquidationType,
      });

      // Could integrate with notification service here
      // await notificationService.sendLiquidationAlert(userId, { positionId, liquidationPrice, liquidationType });

    } catch (error) {
      logger.error('Failed to send liquidation alert:', error);
    }
  }

  /**
   * Register webhook endpoint with Extended Exchange
   */
  async registerWebhookEndpoint(callbackUrl: string): Promise<void> {
    try {
      const result = await this.exchangeService.registerWebhook(callbackUrl, {
        events: [
          'position.updated',
          'position.closed',
          'position.liquidated',
          'order.filled',
          'order.cancelled',
          'order.rejected',
          'account.updated',
          'funding.payment',
        ],
        secret: this.webhookSecret,
      });

      logger.info('Webhook endpoint registered with Extended Exchange', {
        callbackUrl,
        webhookId: result.webhookId,
      });

    } catch (error) {
      logger.error('Failed to register webhook endpoint:', error);
      throw error;
    }
  }

  /**
   * Test webhook connectivity
   */
  async testWebhookConnectivity(): Promise<boolean> {
    try {
      // Send test event
      const testEvent = {
        type: 'test.ping',
        timestamp: new Date().toISOString(),
        data: { message: 'Test webhook connectivity' },
      };

      const result = await this.exchangeService.sendTestWebhook(testEvent);
      
      logger.info('Webhook connectivity test completed', { result });
      return result;

    } catch (error) {
      logger.error('Webhook connectivity test failed:', error);
      return false;
    }
  }

  /**
   * Get webhook statistics
   */
  getWebhookStats(): {
    totalEvents: number;
    eventsByType: Record<string, number>;
    errors: number;
    lastEventTime?: Date;
  } {
    // In production, would track these metrics
    return {
      totalEvents: 0,
      eventsByType: {},
      errors: 0,
    };
  }
}