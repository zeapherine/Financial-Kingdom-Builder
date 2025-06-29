import { Router, Request, Response, NextFunction } from 'express';
import multer from 'multer';
import { AppError } from '../utils/app-error';
import { KycService, KycVerificationRequest } from '../services/kyc.service';
import { logger } from '../utils/logger';

const router = Router();
const kycService = new KycService();

// Configure multer for file uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  },
});

// Get KYC status for user
router.get('/status/:userId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { userId } = req.params;
    
    if (!userId) {
      throw new AppError('User ID is required', 400);
    }

    const profile = await kycService.getKycProfile(userId);
    const status = await kycService.getKycStatus(userId);

    res.json({
      success: true,
      message: 'KYC status retrieved successfully',
      data: {
        ...profile,
        statusInfo: status,
      }
    });
  } catch (error) {
    next(error);
  }
});

// Submit KYC verification
router.post('/submit', 
  upload.fields([
    { name: 'frontIdImage', maxCount: 1 },
    { name: 'backIdImage', maxCount: 1 },
    { name: 'selfieImage', maxCount: 1 }
  ]), 
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = req.headers['x-user-id'] as string;
      
      if (!userId) {
        throw new AppError('User ID is required', 400);
      }

      const files = req.files as { [fieldname: string]: Express.Multer.File[] };
      
      if (!files.frontIdImage || !files.backIdImage || !files.selfieImage) {
        throw new AppError('All document images are required', 400);
      }

      const { personalInfo, addressInfo } = req.body;
      
      if (!personalInfo || !addressInfo) {
        throw new AppError('Personal information and address are required', 400);
      }

      const parsedPersonalInfo = typeof personalInfo === 'string' 
        ? JSON.parse(personalInfo) 
        : personalInfo;
        
      const parsedAddressInfo = typeof addressInfo === 'string' 
        ? JSON.parse(addressInfo) 
        : addressInfo;

      const kycRequest: KycVerificationRequest = {
        personalInfo: parsedPersonalInfo,
        addressInfo: parsedAddressInfo,
        documents: {
          frontIdImage: files.frontIdImage[0].buffer,
          backIdImage: files.backIdImage[0].buffer,
          selfieImage: files.selfieImage[0].buffer,
          documentType: req.body.documentType || 'drivers_license',
        },
      };

      const result = await kycService.submitKycVerification(userId, kycRequest);

      res.status(201).json({
        success: true,
        message: 'KYC verification submitted successfully',
        data: result
      });
    } catch (error) {
      next(error);
    }
  }
);

// Check if user can trade
router.get('/can-trade/:userId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { userId } = req.params;
    
    if (!userId) {
      throw new AppError('User ID is required', 400);
    }

    const canTrade = await kycService.canUserTrade(userId);
    const status = await kycService.getKycStatus(userId);

    res.json({
      success: true,
      message: 'Trading eligibility checked',
      data: {
        canTrade,
        status: status.status,
        message: status.message,
        nextSteps: status.nextSteps,
      }
    });
  } catch (error) {
    next(error);
  }
});

// Get submission details
router.get('/submission/:submissionId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { submissionId } = req.params;
    const userId = req.headers['x-user-id'] as string;
    
    if (!submissionId) {
      throw new AppError('Submission ID is required', 400);
    }

    const submission = await kycService.getSubmission(submissionId);
    
    if (!submission) {
      throw new AppError('Submission not found', 404);
    }

    // Ensure user can only access their own submissions
    if (submission.userId !== userId) {
      throw new AppError('Access denied', 403);
    }

    res.json({
      success: true,
      message: 'Submission details retrieved',
      data: submission
    });
  } catch (error) {
    next(error);
  }
});

// Resubmit KYC (for rejected applications)
router.post('/resubmit', 
  upload.fields([
    { name: 'frontIdImage', maxCount: 1 },
    { name: 'backIdImage', maxCount: 1 },
    { name: 'selfieImage', maxCount: 1 }
  ]), 
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = req.headers['x-user-id'] as string;
      
      if (!userId) {
        throw new AppError('User ID is required', 400);
      }

      // Check if user has a rejected submission
      const profile = await kycService.getKycProfile(userId);
      if (profile.status !== 'rejected') {
        throw new AppError('Can only resubmit rejected applications', 400);
      }

      const files = req.files as { [fieldname: string]: Express.Multer.File[] };
      
      if (!files.frontIdImage || !files.backIdImage || !files.selfieImage) {
        throw new AppError('All document images are required', 400);
      }

      const { personalInfo, addressInfo } = req.body;
      
      const parsedPersonalInfo = typeof personalInfo === 'string' 
        ? JSON.parse(personalInfo) 
        : personalInfo;
        
      const parsedAddressInfo = typeof addressInfo === 'string' 
        ? JSON.parse(addressInfo) 
        : addressInfo;

      const kycRequest: KycVerificationRequest = {
        personalInfo: parsedPersonalInfo,
        addressInfo: parsedAddressInfo,
        documents: {
          frontIdImage: files.frontIdImage[0].buffer,
          backIdImage: files.backIdImage[0].buffer,
          selfieImage: files.selfieImage[0].buffer,
          documentType: req.body.documentType || 'drivers_license',
        },
      };

      const result = await kycService.submitKycVerification(userId, kycRequest);

      res.status(201).json({
        success: true,
        message: 'KYC verification resubmitted successfully',
        data: result
      });
    } catch (error) {
      next(error);
    }
  }
);

// Admin: Get pending reviews
router.get('/admin/pending', async (req: Request, res: Response, next: NextFunction) => {
  try {
    // In production, would check admin permissions
    const pendingReviews = await kycService.getPendingReviews();

    res.json({
      success: true,
      message: 'Pending reviews retrieved',
      data: {
        count: pendingReviews.length,
        submissions: pendingReviews,
      }
    });
  } catch (error) {
    next(error);
  }
});

// Admin: Manual review
router.post('/admin/review/:submissionId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { submissionId } = req.params;
    const { decision, notes, reasons } = req.body;
    
    if (!submissionId) {
      throw new AppError('Submission ID is required', 400);
    }

    if (!decision || !['approve', 'reject'].includes(decision)) {
      throw new AppError('Decision must be "approve" or "reject"', 400);
    }

    if (!notes) {
      throw new AppError('Review notes are required', 400);
    }

    if (decision === 'reject' && (!reasons || !Array.isArray(reasons) || reasons.length === 0)) {
      throw new AppError('Rejection reasons are required when rejecting', 400);
    }

    await kycService.manualReview(submissionId, decision, notes, reasons);

    res.json({
      success: true,
      message: `KYC submission ${decision}d successfully`,
      data: { submissionId, decision }
    });
  } catch (error) {
    next(error);
  }
});

// KYC status webhook (for external KYC providers)
router.post('/webhook/status', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { submissionId, status, reasons, confidence } = req.body;
    
    // Verify webhook signature in production
    // const signature = req.headers['x-webhook-signature'];
    
    if (!submissionId || !status) {
      throw new AppError('Submission ID and status are required', 400);
    }

    logger.info(`KYC webhook received for submission ${submissionId}: ${status}`, {
      reasons,
      confidence,
    });

    // Process webhook based on status
    if (status === 'approved') {
      await kycService.manualReview(submissionId, 'approve', 'Automated approval via webhook');
    } else if (status === 'rejected') {
      await kycService.manualReview(submissionId, 'reject', 'Automated rejection via webhook', reasons);
    }

    res.json({
      success: true,
      message: 'Webhook processed successfully'
    });
  } catch (error) {
    logger.error('KYC webhook processing failed:', error);
    next(error);
  }
});

export { router as kycRouter };