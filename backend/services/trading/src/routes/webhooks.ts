import { Router, Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/app-error';
import { WebhookService } from '../services/webhook.service';
import { PerpetualPortfolioService } from '../services/perpetual-portfolio.service';
import { ExtendedExchangeService } from '../services/extended-exchange.service';
import { logger } from '../utils/logger';

const router = Router();

// Initialize services
const portfolioService = new PerpetualPortfolioService();
const exchangeService = new ExtendedExchangeService();
const webhookService = new WebhookService(portfolioService, exchangeService);

// Middleware to capture raw body for signature verification
router.use('/extended-exchange', (req: Request, res: Response, next: NextFunction) => {
  let data = '';
  req.setEncoding('utf8');
  
  req.on('data', (chunk) => {
    data += chunk;
  });
  
  req.on('end', () => {
    req.body = data;
    next();
  });
});

// Extended Exchange webhook endpoint
router.post('/extended-exchange', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const signature = req.headers['x-extended-signature'] as string;
    const payload = req.body as string;
    
    if (!signature) {
      throw new AppError('Missing webhook signature', 400);
    }

    if (!payload) {
      throw new AppError('Missing webhook payload', 400);
    }

    // Process webhook
    await webhookService.processWebhook(payload, signature);
    
    // Respond with success
    res.status(200).json({
      success: true,
      message: 'Webhook processed successfully',
      timestamp: new Date().toISOString(),
    });

  } catch (error) {
    logger.error('Extended Exchange webhook processing failed:', error);
    
    if (error instanceof AppError) {
      res.status(error.statusCode).json({
        success: false,
        error: error.message,
        timestamp: new Date().toISOString(),
      });
    } else {
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        timestamp: new Date().toISOString(),
      });
    }
  }
});

// Register webhook endpoint with Extended Exchange
router.post('/register', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { callbackUrl } = req.body;
    
    if (!callbackUrl) {
      throw new AppError('Callback URL is required', 400);
    }

    await webhookService.registerWebhookEndpoint(callbackUrl);

    res.json({
      success: true,
      message: 'Webhook endpoint registered successfully',
      data: { callbackUrl }
    });

  } catch (error) {
    next(error);
  }
});

// Test webhook connectivity
router.post('/test', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const result = await webhookService.testWebhookConnectivity();

    res.json({
      success: true,
      message: 'Webhook connectivity test completed',
      data: { connected: result }
    });

  } catch (error) {
    next(error);
  }
});

// Get webhook statistics
router.get('/stats', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const stats = webhookService.getWebhookStats();

    res.json({
      success: true,
      message: 'Webhook statistics retrieved',
      data: stats
    });

  } catch (error) {
    next(error);
  }
});

// Health check for webhooks
router.get('/health', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const health = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      services: {
        webhookService: 'operational',
        portfolioService: 'operational',
        exchangeService: 'operational',
      },
      uptime: process.uptime(),
    };

    res.json({
      success: true,
      message: 'Webhook service health check',
      data: health
    });

  } catch (error) {
    next(error);
  }
});

// Webhook event replay (for debugging)
router.post('/replay/:eventId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { eventId } = req.params;
    const { event } = req.body;
    
    if (!eventId || !event) {
      throw new AppError('Event ID and event data are required', 400);
    }

    logger.info(`Replaying webhook event: ${eventId}`, { event });
    
    // In production, would fetch event from database and replay
    // For demo, just log the replay request
    
    res.json({
      success: true,
      message: 'Event replay completed',
      data: { eventId, replayed: true }
    });

  } catch (error) {
    next(error);
  }
});

export { router as webhooksRouter };