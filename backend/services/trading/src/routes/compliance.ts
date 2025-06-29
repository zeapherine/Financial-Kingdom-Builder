import { Router, Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/app-error';
import { ComplianceService, AuditEventType, ComplianceRiskLevel } from '../services/compliance.service';
import { logger } from '../utils/logger';

const router = Router();
const complianceService = new ComplianceService();

// Get compliance dashboard
router.get('/dashboard', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const dashboard = await complianceService.getComplianceDashboard();

    res.json({
      success: true,
      message: 'Compliance dashboard retrieved',
      data: dashboard
    });
  } catch (error) {
    next(error);
  }
});

// Get audit events
router.get('/audit-events', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { 
      userId, 
      eventType, 
      riskLevel, 
      startDate, 
      endDate, 
      limit = 100, 
      offset = 0 
    } = req.query;

    // In production, would query database with filters
    const events = []; // Placeholder for filtered events

    res.json({
      success: true,
      message: 'Audit events retrieved',
      data: {
        events,
        pagination: {
          limit: Number(limit),
          offset: Number(offset),
          total: events.length,
        },
        filters: {
          userId,
          eventType,
          riskLevel,
          startDate,
          endDate,
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

// Get compliance alerts
router.get('/alerts', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { 
      status = 'open', 
      riskLevel, 
      alertType,
      limit = 50, 
      offset = 0 
    } = req.query;

    // In production, would query database with filters
    const alerts = []; // Placeholder for filtered alerts

    res.json({
      success: true,
      message: 'Compliance alerts retrieved',
      data: {
        alerts,
        pagination: {
          limit: Number(limit),
          offset: Number(offset),
          total: alerts.length,
        },
        filters: {
          status,
          riskLevel,
          alertType,
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

// Update alert status
router.patch('/alerts/:alertId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { alertId } = req.params;
    const { status, assignedTo, resolution } = req.body;
    
    if (!alertId) {
      throw new AppError('Alert ID is required', 400);
    }

    if (!status || !['open', 'investigating', 'resolved', 'false_positive'].includes(status)) {
      throw new AppError('Valid status is required', 400);
    }

    // In production, would update alert in database
    logger.info(`Alert ${alertId} status updated to: ${status}`, { 
      assignedTo, 
      resolution 
    });

    res.json({
      success: true,
      message: 'Alert status updated successfully',
      data: {
        alertId,
        status,
        assignedTo,
        resolution,
        updatedAt: new Date().toISOString(),
      }
    });
  } catch (error) {
    next(error);
  }
});

// Create manual compliance alert
router.post('/alerts', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { 
      alertType, 
      userId, 
      riskLevel, 
      description, 
      metadata = {} 
    } = req.body;
    
    if (!alertType || !userId || !riskLevel || !description) {
      throw new AppError('Alert type, user ID, risk level, and description are required', 400);
    }

    if (!Object.values(ComplianceRiskLevel).includes(riskLevel)) {
      throw new AppError('Invalid risk level', 400);
    }

    const alertId = await complianceService.createComplianceAlert(
      alertType,
      userId,
      riskLevel,
      description,
      metadata
    );

    res.status(201).json({
      success: true,
      message: 'Compliance alert created successfully',
      data: { alertId }
    });
  } catch (error) {
    next(error);
  }
});

// Log audit event (for manual logging)
router.post('/audit-events', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { 
      eventType, 
      userId, 
      details = {}, 
      context = {} 
    } = req.body;
    
    if (!eventType) {
      throw new AppError('Event type is required', 400);
    }

    if (!Object.values(AuditEventType).includes(eventType)) {
      throw new AppError('Invalid event type', 400);
    }

    const eventId = await complianceService.logAuditEvent(
      eventType,
      details,
      context
    );

    res.status(201).json({
      success: true,
      message: 'Audit event logged successfully',
      data: { eventId }
    });
  } catch (error) {
    next(error);
  }
});

// Get user activity summary
router.get('/users/:userId/activity', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { userId } = req.params;
    const { timeWindow = '24h' } = req.query;
    
    if (!userId) {
      throw new AppError('User ID is required', 400);
    }

    // In production, would get activity from database
    const activity = {
      userId,
      timeWindow,
      summary: {
        totalTrades: 0,
        totalVolume: 0,
        totalPnl: 0,
        riskScore: 0,
      },
      alerts: [],
      recentEvents: [],
    };

    res.json({
      success: true,
      message: 'User activity retrieved',
      data: activity
    });
  } catch (error) {
    next(error);
  }
});

// Generate compliance report
router.post('/reports', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { 
      reportType, 
      startDate, 
      endDate, 
      includeDetails = false 
    } = req.body;
    
    if (!reportType) {
      throw new AppError('Report type is required', 400);
    }

    if (!['daily', 'weekly', 'monthly', 'suspicious_activity', 'large_transaction'].includes(reportType)) {
      throw new AppError('Invalid report type', 400);
    }

    // In production, would generate actual report
    const reportId = `report_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    logger.info(`Compliance report generation requested: ${reportType}`, {
      reportId,
      startDate,
      endDate,
      includeDetails,
    });

    res.status(202).json({
      success: true,
      message: 'Report generation started',
      data: {
        reportId,
        status: 'generating',
        estimatedCompletion: new Date(Date.now() + 5 * 60 * 1000), // 5 minutes
      }
    });
  } catch (error) {
    next(error);
  }
});

// Get compliance report
router.get('/reports/:reportId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { reportId } = req.params;
    
    if (!reportId) {
      throw new AppError('Report ID is required', 400);
    }

    // In production, would fetch report from database
    const report = {
      id: reportId,
      status: 'completed',
      reportType: 'daily',
      generatedAt: new Date().toISOString(),
      data: {
        summary: {
          totalUsers: 150,
          totalTrades: 1250,
          totalVolume: 85000,
          suspiciousActivities: 3,
          riskAlerts: 1,
        }
      }
    };

    res.json({
      success: true,
      message: 'Compliance report retrieved',
      data: report
    });
  } catch (error) {
    next(error);
  }
});

// Export audit data (for regulatory compliance)
router.post('/export', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { 
      startDate, 
      endDate, 
      format = 'json', 
      includeUserData = false 
    } = req.body;
    
    if (!startDate || !endDate) {
      throw new AppError('Start date and end date are required', 400);
    }

    if (!['json', 'csv', 'xml'].includes(format)) {
      throw new AppError('Invalid export format', 400);
    }

    // In production, would create export job
    const exportId = `export_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    logger.info(`Audit data export requested`, {
      exportId,
      startDate,
      endDate,
      format,
      includeUserData,
    });

    res.status(202).json({
      success: true,
      message: 'Export job started',
      data: {
        exportId,
        status: 'processing',
        estimatedCompletion: new Date(Date.now() + 10 * 60 * 1000), // 10 minutes
        downloadUrl: null, // Will be populated when ready
      }
    });
  } catch (error) {
    next(error);
  }
});

// Health check for compliance service
router.get('/health', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const health = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      services: {
        complianceService: 'operational',
        auditLogging: 'operational',
        alerting: 'operational',
        reporting: 'operational',
      },
      metrics: {
        totalEvents: 0, // Would get from database
        totalAlerts: 0,
        openAlerts: 0,
        processingLatency: '< 100ms',
      },
      uptime: process.uptime(),
    };

    res.json({
      success: true,
      message: 'Compliance service health check',
      data: health
    });
  } catch (error) {
    next(error);
  }
});

export { router as complianceRouter };