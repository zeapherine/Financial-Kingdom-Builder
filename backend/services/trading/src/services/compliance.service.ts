import { logger } from '../utils/logger';
import { TimestampedRecord } from '../types/common';
import { PerpetualPosition, PositionSide } from '../types/perpetual';

export enum AuditEventType {
  // User Actions
  USER_LOGIN = 'user.login',
  USER_LOGOUT = 'user.logout',
  USER_KYC_SUBMITTED = 'user.kyc_submitted',
  USER_KYC_APPROVED = 'user.kyc_approved',
  USER_KYC_REJECTED = 'user.kyc_rejected',
  
  // Trading Actions
  POSITION_OPENED = 'position.opened',
  POSITION_CLOSED = 'position.closed',
  POSITION_LIQUIDATED = 'position.liquidated',
  ORDER_PLACED = 'order.placed',
  ORDER_CANCELLED = 'order.cancelled',
  ORDER_FILLED = 'order.filled',
  
  // Risk Management
  STOP_LOSS_TRIGGERED = 'stop_loss.triggered',
  MARGIN_CALL = 'margin.call',
  TRADING_SUSPENDED = 'trading.suspended',
  RISK_LIMIT_EXCEEDED = 'risk.limit_exceeded',
  
  // System Events
  FUNDING_PAYMENT = 'funding.payment',
  PRICE_UPDATE = 'price.update',
  SYSTEM_ERROR = 'system.error',
  API_REQUEST = 'api.request',
  
  // Compliance Events
  SUSPICIOUS_ACTIVITY = 'compliance.suspicious_activity',
  LARGE_TRANSACTION = 'compliance.large_transaction',
  RAPID_TRADING = 'compliance.rapid_trading',
  JURISDICTION_VIOLATION = 'compliance.jurisdiction_violation',
}

export enum ComplianceRiskLevel {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  CRITICAL = 'critical',
}

export interface AuditEvent extends TimestampedRecord {
  eventType: AuditEventType;
  userId?: string;
  sessionId?: string;
  ipAddress?: string;
  userAgent?: string;
  positionId?: string;
  orderId?: string;
  symbol?: string;
  amount?: number;
  price?: number;
  riskLevel: ComplianceRiskLevel;
  details: Record<string, any>;
  metadata: {
    source: string;
    version: string;
    environment: string;
    traceId?: string;
  };
}

export interface ComplianceAlert extends TimestampedRecord {
  alertType: string;
  userId: string;
  riskLevel: ComplianceRiskLevel;
  description: string;
  triggerEvents: string[];
  status: 'open' | 'investigating' | 'resolved' | 'false_positive';
  assignedTo?: string;
  resolution?: string;
  resolvedAt?: Date;
  metadata: Record<string, any>;
}

export interface TradingActivity {
  userId: string;
  timeWindow: string; // e.g., '1h', '24h', '7d'
  totalTrades: number;
  totalVolume: number;
  totalPnl: number;
  maxPositionSize: number;
  uniqueSymbols: number;
  suspiciousPatterns: string[];
  riskScore: number;
}

export interface ComplianceReport {
  id: string;
  reportType: 'daily' | 'weekly' | 'monthly' | 'suspicious_activity' | 'large_transaction';
  period: {
    startDate: Date;
    endDate: Date;
  };
  summary: {
    totalUsers: number;
    totalTrades: number;
    totalVolume: number;
    newKycApplications: number;
    suspiciousActivities: number;
    riskAlerts: number;
  };
  details: Record<string, any>;
  generatedAt: Date;
  generatedBy: string;
}

export class ComplianceService {
  private auditEvents: Map<string, AuditEvent> = new Map();
  private complianceAlerts: Map<string, ComplianceAlert> = new Map();
  private tradingActivities: Map<string, TradingActivity> = new Map();
  private complianceReports: Map<string, ComplianceReport> = new Map();

  // Compliance thresholds
  private readonly LARGE_TRANSACTION_THRESHOLD = 10000; // $10k
  private readonly RAPID_TRADING_THRESHOLD = 50; // 50 trades per hour
  private readonly MAX_DAILY_VOLUME_THRESHOLD = 100000; // $100k per day
  private readonly SUSPICIOUS_PNL_THRESHOLD = 5000; // $5k profit in short time

  constructor() {
    this.initializeService();
  }

  private initializeService() {
    logger.info('Compliance Service initialized');
    
    // Start periodic compliance checks
    setInterval(() => {
      this.runComplianceChecks();
    }, 60000); // Run every minute
    
    // Generate daily reports
    setInterval(() => {
      this.generateDailyReport();
    }, 24 * 60 * 60 * 1000); // Run daily
  }

  /**
   * Log audit event
   */
  async logAuditEvent(
    eventType: AuditEventType,
    details: Record<string, any>,
    context: {
      userId?: string;
      sessionId?: string;
      ipAddress?: string;
      userAgent?: string;
      positionId?: string;
      orderId?: string;
      symbol?: string;
      amount?: number;
      price?: number;
      traceId?: string;
    } = {}
  ): Promise<string> {
    const eventId = this.generateId();
    
    const auditEvent: AuditEvent = {
      id: eventId,
      eventType,
      riskLevel: this.calculateRiskLevel(eventType, details),
      details,
      metadata: {
        source: 'trading_service',
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'development',
        traceId: context.traceId,
      },
      createdAt: new Date(),
      updatedAt: new Date(),
      ...context,
    };

    this.auditEvents.set(eventId, auditEvent);
    
    // Log to external systems in production
    logger.info(`Audit event logged: ${eventType}`, {
      eventId,
      userId: context.userId,
      riskLevel: auditEvent.riskLevel,
      details,
    });

    // Check for compliance violations
    await this.checkComplianceViolations(auditEvent);

    return eventId;
  }

  /**
   * Log trading activity
   */
  async logTradingActivity(
    userId: string,
    action: 'position_opened' | 'position_closed' | 'order_placed',
    details: {
      symbol: string;
      side: PositionSide;
      size: number;
      price: number;
      leverage?: number;
      pnl?: number;
    }
  ): Promise<void> {
    // Log audit event
    const eventType = action === 'position_opened' ? AuditEventType.POSITION_OPENED :
                     action === 'position_closed' ? AuditEventType.POSITION_CLOSED :
                     AuditEventType.ORDER_PLACED;

    await this.logAuditEvent(eventType, details, {
      userId,
      symbol: details.symbol,
      amount: details.size,
      price: details.price,
    });

    // Update trading activity tracking
    await this.updateTradingActivity(userId, details);

    // Check for suspicious patterns
    await this.checkSuspiciousTrading(userId);
  }

  /**
   * Log KYC event
   */
  async logKycEvent(
    userId: string,
    eventType: AuditEventType.USER_KYC_SUBMITTED | AuditEventType.USER_KYC_APPROVED | AuditEventType.USER_KYC_REJECTED,
    details: Record<string, any>
  ): Promise<void> {
    await this.logAuditEvent(eventType, details, { userId });
  }

  /**
   * Log risk management event
   */
  async logRiskEvent(
    userId: string,
    eventType: AuditEventType,
    details: Record<string, any>
  ): Promise<void> {
    await this.logAuditEvent(eventType, details, { userId });
    
    // Create compliance alert for high-risk events
    if (this.isHighRiskEvent(eventType)) {
      await this.createComplianceAlert(
        'high_risk_trading',
        userId,
        ComplianceRiskLevel.HIGH,
        `High-risk event detected: ${eventType}`,
        details
      );
    }
  }

  /**
   * Create compliance alert
   */
  async createComplianceAlert(
    alertType: string,
    userId: string,
    riskLevel: ComplianceRiskLevel,
    description: string,
    metadata: Record<string, any> = {}
  ): Promise<string> {
    const alertId = this.generateId();
    
    const alert: ComplianceAlert = {
      id: alertId,
      alertType,
      userId,
      riskLevel,
      description,
      triggerEvents: [], // Would populate with related event IDs
      status: 'open',
      metadata,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    this.complianceAlerts.set(alertId, alert);
    
    logger.warn(`Compliance alert created: ${alertType}`, {
      alertId,
      userId,
      riskLevel,
      description,
    });

    // In production, would notify compliance team
    await this.notifyComplianceTeam(alert);

    return alertId;
  }

  /**
   * Update trading activity tracking
   */
  private async updateTradingActivity(
    userId: string,
    details: {
      symbol: string;
      size: number;
      price: number;
      pnl?: number;
    }
  ): Promise<void> {
    const key = `${userId}_24h`;
    let activity = this.tradingActivities.get(key);
    
    if (!activity) {
      activity = {
        userId,
        timeWindow: '24h',
        totalTrades: 0,
        totalVolume: 0,
        totalPnl: 0,
        maxPositionSize: 0,
        uniqueSymbols: 0,
        suspiciousPatterns: [],
        riskScore: 0,
      };
    }

    activity.totalTrades += 1;
    activity.totalVolume += details.size;
    activity.totalPnl += details.pnl || 0;
    activity.maxPositionSize = Math.max(activity.maxPositionSize, details.size);
    
    // Update risk score
    activity.riskScore = this.calculateTradingRiskScore(activity);
    
    this.tradingActivities.set(key, activity);
  }

  /**
   * Check for suspicious trading patterns
   */
  private async checkSuspiciousTrading(userId: string): Promise<void> {
    const activity = this.tradingActivities.get(`${userId}_24h`);
    if (!activity) return;

    const suspiciousPatterns = [];

    // Check for rapid trading
    if (activity.totalTrades > this.RAPID_TRADING_THRESHOLD) {
      suspiciousPatterns.push('rapid_trading');
    }

    // Check for large volume
    if (activity.totalVolume > this.MAX_DAILY_VOLUME_THRESHOLD) {
      suspiciousPatterns.push('large_volume');
    }

    // Check for suspicious profits
    if (activity.totalPnl > this.SUSPICIOUS_PNL_THRESHOLD) {
      suspiciousPatterns.push('high_profits');
    }

    // Create alerts for suspicious patterns
    for (const pattern of suspiciousPatterns) {
      if (!activity.suspiciousPatterns.includes(pattern)) {
        activity.suspiciousPatterns.push(pattern);
        
        await this.createComplianceAlert(
          pattern,
          userId,
          ComplianceRiskLevel.MEDIUM,
          `Suspicious trading pattern detected: ${pattern}`,
          { activity }
        );
      }
    }
  }

  /**
   * Check for compliance violations
   */
  private async checkComplianceViolations(event: AuditEvent): Promise<void> {
    // Check for large transactions
    if (event.amount && event.amount > this.LARGE_TRANSACTION_THRESHOLD) {
      await this.createComplianceAlert(
        'large_transaction',
        event.userId!,
        ComplianceRiskLevel.MEDIUM,
        `Large transaction detected: $${event.amount}`,
        { event }
      );
    }

    // Check for high-risk events
    if (event.riskLevel === ComplianceRiskLevel.HIGH || event.riskLevel === ComplianceRiskLevel.CRITICAL) {
      await this.createComplianceAlert(
        'high_risk_event',
        event.userId!,
        event.riskLevel,
        `High-risk event: ${event.eventType}`,
        { event }
      );
    }
  }

  /**
   * Run periodic compliance checks
   */
  private async runComplianceChecks(): Promise<void> {
    try {
      // Check all active trading activities
      for (const [key, activity] of this.tradingActivities) {
        await this.checkSuspiciousTrading(activity.userId);
      }

      // Check for stale alerts
      await this.checkStaleAlerts();

    } catch (error) {
      logger.error('Compliance checks failed:', error);
    }
  }

  /**
   * Check for stale compliance alerts
   */
  private async checkStaleAlerts(): Promise<void> {
    const now = new Date();
    const staleThreshold = 24 * 60 * 60 * 1000; // 24 hours

    for (const [alertId, alert] of this.complianceAlerts) {
      if (alert.status === 'open' && 
          (now.getTime() - alert.createdAt.getTime()) > staleThreshold) {
        
        logger.warn(`Stale compliance alert detected: ${alertId}`, { alert });
        
        // Escalate stale alerts
        await this.escalateAlert(alertId);
      }
    }
  }

  /**
   * Generate daily compliance report
   */
  private async generateDailyReport(): Promise<void> {
    try {
      const reportId = this.generateId();
      const today = new Date();
      const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);

      // Get events from last 24 hours
      const dailyEvents = Array.from(this.auditEvents.values())
        .filter(event => event.createdAt >= yesterday);

      // Get alerts from last 24 hours
      const dailyAlerts = Array.from(this.complianceAlerts.values())
        .filter(alert => alert.createdAt >= yesterday);

      const report: ComplianceReport = {
        id: reportId,
        reportType: 'daily',
        period: {
          startDate: yesterday,
          endDate: today,
        },
        summary: {
          totalUsers: new Set(dailyEvents.map(e => e.userId).filter(Boolean)).size,
          totalTrades: dailyEvents.filter(e => 
            [AuditEventType.POSITION_OPENED, AuditEventType.POSITION_CLOSED, AuditEventType.ORDER_FILLED]
              .includes(e.eventType)
          ).length,
          totalVolume: dailyEvents
            .filter(e => e.amount)
            .reduce((sum, e) => sum + (e.amount || 0), 0),
          newKycApplications: dailyEvents.filter(e => e.eventType === AuditEventType.USER_KYC_SUBMITTED).length,
          suspiciousActivities: dailyAlerts.filter(a => a.alertType.includes('suspicious')).length,
          riskAlerts: dailyAlerts.filter(a => a.riskLevel === ComplianceRiskLevel.HIGH).length,
        },
        details: {
          events: dailyEvents.length,
          alerts: dailyAlerts.length,
          eventBreakdown: this.summarizeEventsByType(dailyEvents),
          alertBreakdown: this.summarizeAlertsByType(dailyAlerts),
        },
        generatedAt: new Date(),
        generatedBy: 'compliance_service',
      };

      this.complianceReports.set(reportId, report);
      
      logger.info(`Daily compliance report generated: ${reportId}`, { summary: report.summary });

    } catch (error) {
      logger.error('Daily report generation failed:', error);
    }
  }

  /**
   * Get compliance dashboard data
   */
  async getComplianceDashboard(): Promise<{
    alerts: ComplianceAlert[];
    recentEvents: AuditEvent[];
    riskMetrics: Record<string, number>;
    reports: ComplianceReport[];
  }> {
    const now = new Date();
    const last24Hours = new Date(now.getTime() - 24 * 60 * 60 * 1000);

    const openAlerts = Array.from(this.complianceAlerts.values())
      .filter(alert => alert.status === 'open')
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());

    const recentEvents = Array.from(this.auditEvents.values())
      .filter(event => event.createdAt >= last24Hours)
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
      .slice(0, 100);

    const riskMetrics = {
      totalAlerts: this.complianceAlerts.size,
      openAlerts: openAlerts.length,
      highRiskAlerts: openAlerts.filter(a => a.riskLevel === ComplianceRiskLevel.HIGH).length,
      criticalAlerts: openAlerts.filter(a => a.riskLevel === ComplianceRiskLevel.CRITICAL).length,
      eventsLast24h: recentEvents.length,
      suspiciousActivities: openAlerts.filter(a => a.alertType.includes('suspicious')).length,
    };

    const reports = Array.from(this.complianceReports.values())
      .sort((a, b) => b.generatedAt.getTime() - a.generatedAt.getTime())
      .slice(0, 10);

    return {
      alerts: openAlerts,
      recentEvents,
      riskMetrics,
      reports,
    };
  }

  // Helper methods

  private calculateRiskLevel(eventType: AuditEventType, details: Record<string, any>): ComplianceRiskLevel {
    // High-risk events
    if ([
      AuditEventType.POSITION_LIQUIDATED,
      AuditEventType.TRADING_SUSPENDED,
      AuditEventType.SUSPICIOUS_ACTIVITY,
      AuditEventType.JURISDICTION_VIOLATION
    ].includes(eventType)) {
      return ComplianceRiskLevel.HIGH;
    }

    // Medium-risk events
    if ([
      AuditEventType.LARGE_TRANSACTION,
      AuditEventType.RAPID_TRADING,
      AuditEventType.MARGIN_CALL,
      AuditEventType.RISK_LIMIT_EXCEEDED
    ].includes(eventType)) {
      return ComplianceRiskLevel.MEDIUM;
    }

    return ComplianceRiskLevel.LOW;
  }

  private calculateTradingRiskScore(activity: TradingActivity): number {
    let score = 0;
    
    // Risk factors
    if (activity.totalTrades > this.RAPID_TRADING_THRESHOLD) score += 30;
    if (activity.totalVolume > this.MAX_DAILY_VOLUME_THRESHOLD) score += 25;
    if (activity.totalPnl > this.SUSPICIOUS_PNL_THRESHOLD) score += 20;
    if (activity.maxPositionSize > this.LARGE_TRANSACTION_THRESHOLD) score += 15;
    if (activity.suspiciousPatterns.length > 0) score += activity.suspiciousPatterns.length * 10;

    return Math.min(score, 100); // Cap at 100
  }

  private isHighRiskEvent(eventType: AuditEventType): boolean {
    return [
      AuditEventType.POSITION_LIQUIDATED,
      AuditEventType.TRADING_SUSPENDED,
      AuditEventType.RISK_LIMIT_EXCEEDED,
      AuditEventType.SUSPICIOUS_ACTIVITY,
    ].includes(eventType);
  }

  private async notifyComplianceTeam(alert: ComplianceAlert): Promise<void> {
    // In production, would send notifications via email, Slack, etc.
    logger.info(`Compliance team notified of alert: ${alert.id}`);
  }

  private async escalateAlert(alertId: string): Promise<void> {
    const alert = this.complianceAlerts.get(alertId);
    if (!alert) return;

    alert.riskLevel = ComplianceRiskLevel.HIGH;
    alert.updatedAt = new Date();
    
    logger.warn(`Alert escalated: ${alertId}`);
    await this.notifyComplianceTeam(alert);
  }

  private summarizeEventsByType(events: AuditEvent[]): Record<string, number> {
    const summary: Record<string, number> = {};
    for (const event of events) {
      summary[event.eventType] = (summary[event.eventType] || 0) + 1;
    }
    return summary;
  }

  private summarizeAlertsByType(alerts: ComplianceAlert[]): Record<string, number> {
    const summary: Record<string, number> = {};
    for (const alert of alerts) {
      summary[alert.alertType] = (summary[alert.alertType] || 0) + 1;
    }
    return summary;
  }

  private generateId(): string {
    return `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}