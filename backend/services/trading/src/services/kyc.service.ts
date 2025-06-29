import { logger } from '../utils/logger';
import { AppError } from '../utils/app-error';
import { TimestampedRecord } from '../types/common';

export enum KycStatus {
  NOT_STARTED = 'not_started',
  IN_PROGRESS = 'in_progress',
  SUBMITTED = 'submitted',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  NEEDS_REVIEW = 'needs_review',
}

export interface PersonalInfo {
  firstName: string;
  lastName: string;
  dateOfBirth: string;
  phoneNumber: string;
}

export interface AddressInfo {
  streetAddress: string;
  city: string;
  state: string;
  zipCode: string;
  country: string;
}

export interface DocumentInfo {
  frontIdImageUrl: string;
  backIdImageUrl: string;
  selfieImageUrl: string;
  documentType: 'passport' | 'drivers_license' | 'national_id';
}

export interface KycSubmission {
  id: string;
  userId: string;
  personalInfo: PersonalInfo;
  addressInfo: AddressInfo;
  documents: DocumentInfo;
  status: KycStatus;
  submittedAt: Date;
  reviewedAt?: Date;
  approvedAt?: Date;
  rejectionReasons: string[];
  reviewNotes: string[];
  canTrade: boolean;
  metadata: Record<string, any>;
}

export interface KycProfile extends TimestampedRecord {
  userId: string;
  status: KycStatus;
  personalInfo?: PersonalInfo;
  addressInfo?: AddressInfo;
  documents: DocumentInfo[];
  submissions: string[]; // submission IDs
  lastSubmissionId?: string;
  submittedAt?: Date;
  approvedAt?: Date;
  rejectionReasons: string[];
  canTrade: boolean;
  riskLevel: 'low' | 'medium' | 'high';
  metadata: Record<string, any>;
}

export interface KycVerificationRequest {
  personalInfo: PersonalInfo;
  addressInfo: AddressInfo;
  documents: {
    frontIdImage: Buffer;
    backIdImage: Buffer;
    selfieImage: Buffer;
    documentType: 'passport' | 'drivers_license' | 'national_id';
  };
}

export interface KycVerificationResult {
  submissionId: string;
  status: KycStatus;
  message: string;
  estimatedReviewTime: string;
  requiredActions?: string[];
}

export class KycService {
  private profiles: Map<string, KycProfile> = new Map();
  private submissions: Map<string, KycSubmission> = new Map();
  private pendingReviews: Map<string, KycSubmission> = new Map();

  constructor() {
    this.initializeService();
  }

  private initializeService() {
    logger.info('KYC Service initialized');
    
    // In production, this would connect to database and external KYC providers
    // For demo, we'll simulate the process
  }

  /**
   * Get KYC profile for a user
   */
  async getKycProfile(userId: string): Promise<KycProfile> {
    let profile = this.profiles.get(userId);
    
    if (!profile) {
      profile = {
        id: this.generateId(),
        userId,
        status: KycStatus.NOT_STARTED,
        documents: [],
        submissions: [],
        rejectionReasons: [],
        canTrade: false,
        riskLevel: 'medium',
        metadata: {},
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      
      this.profiles.set(userId, profile);
    }
    
    return profile;
  }

  /**
   * Submit KYC verification request
   */
  async submitKycVerification(
    userId: string, 
    request: KycVerificationRequest
  ): Promise<KycVerificationResult> {
    try {
      const profile = await this.getKycProfile(userId);
      
      // Validate request
      this.validateKycRequest(request);
      
      // Create submission
      const submission: KycSubmission = {
        id: this.generateSubmissionId(),
        userId,
        personalInfo: request.personalInfo,
        addressInfo: request.addressInfo,
        documents: {
          frontIdImageUrl: await this.uploadDocument(request.documents.frontIdImage, 'front_id'),
          backIdImageUrl: await this.uploadDocument(request.documents.backIdImage, 'back_id'),
          selfieImageUrl: await this.uploadDocument(request.documents.selfieImage, 'selfie'),
          documentType: request.documents.documentType,
        },
        status: KycStatus.SUBMITTED,
        submittedAt: new Date(),
        rejectionReasons: [],
        reviewNotes: [],
        canTrade: false,
        metadata: {
          ipAddress: 'demo', // Would get from request
          userAgent: 'demo', // Would get from request
          submissionMethod: 'mobile_app',
        },
      };
      
      // Store submission
      this.submissions.set(submission.id, submission);
      this.pendingReviews.set(submission.id, submission);
      
      // Update profile
      profile.status = KycStatus.SUBMITTED;
      profile.personalInfo = request.personalInfo;
      profile.addressInfo = request.addressInfo;
      profile.submissions.push(submission.id);
      profile.lastSubmissionId = submission.id;
      profile.submittedAt = new Date();
      profile.updatedAt = new Date();
      
      this.profiles.set(userId, profile);
      
      // Start automated verification process
      this.processKycSubmission(submission.id);
      
      logger.info(`KYC verification submitted for user ${userId}: ${submission.id}`);
      
      return {
        submissionId: submission.id,
        status: KycStatus.SUBMITTED,
        message: 'Verification submitted successfully. We will review your documents within 1-2 business days.',
        estimatedReviewTime: '1-2 business days',
      };
      
    } catch (error) {
      logger.error(`KYC submission failed for user ${userId}:`, error);
      throw new AppError(`KYC submission failed: ${error instanceof Error ? error.message : 'Unknown error'}`, 400);
    }
  }

  /**
   * Process KYC submission with automated checks
   */
  private async processKycSubmission(submissionId: string): Promise<void> {
    const submission = this.submissions.get(submissionId);
    if (!submission) return;

    try {
      // Simulate automated verification process
      logger.info(`Processing KYC submission ${submissionId}`);
      
      // In production, this would:
      // 1. Run document verification checks
      // 2. Perform identity verification
      // 3. Check against sanctions lists
      // 4. Validate address information
      // 5. Assess risk level
      
      // For demo purposes, we'll auto-approve after a short delay
      setTimeout(async () => {
        try {
          await this.simulateKycVerification(submissionId);
        } catch (error) {
          logger.error(`KYC processing failed for submission ${submissionId}:`, error);
        }
      }, 5000); // 5 second delay for demo
      
    } catch (error) {
      logger.error(`KYC processing error for submission ${submissionId}:`, error);
      await this.rejectKycSubmission(submissionId, ['Internal processing error']);
    }
  }

  /**
   * Simulate KYC verification process
   */
  private async simulateKycVerification(submissionId: string): Promise<void> {
    const submission = this.submissions.get(submissionId);
    if (!submission) return;

    const profile = this.profiles.get(submission.userId);
    if (!profile) return;

    // Simulate verification checks
    const checks = {
      documentValid: true,
      identityVerified: true,
      addressVerified: true,
      sanctionsCheck: true,
      riskAssessment: 'low',
    };

    if (checks.documentValid && checks.identityVerified && checks.addressVerified && checks.sanctionsCheck) {
      // Approve KYC
      submission.status = KycStatus.APPROVED;
      submission.reviewedAt = new Date();
      submission.approvedAt = new Date();
      submission.canTrade = true;
      submission.reviewNotes.push('Automated verification successful');

      profile.status = KycStatus.APPROVED;
      profile.approvedAt = new Date();
      profile.canTrade = true;
      profile.riskLevel = checks.riskAssessment as 'low' | 'medium' | 'high';
      profile.updatedAt = new Date();

      this.pendingReviews.delete(submissionId);

      logger.info(`KYC approved for user ${submission.userId}: ${submissionId}`);
      
      // Notify user (in production, would send push notification/email)
      await this.notifyKycStatusChange(submission.userId, KycStatus.APPROVED);
      
    } else {
      // Reject KYC
      const rejectionReasons = [];
      if (!checks.documentValid) rejectionReasons.push('Document verification failed');
      if (!checks.identityVerified) rejectionReasons.push('Identity verification failed');
      if (!checks.addressVerified) rejectionReasons.push('Address verification failed');
      if (!checks.sanctionsCheck) rejectionReasons.push('Sanctions check failed');

      await this.rejectKycSubmission(submissionId, rejectionReasons);
    }
  }

  /**
   * Reject KYC submission
   */
  private async rejectKycSubmission(submissionId: string, reasons: string[]): Promise<void> {
    const submission = this.submissions.get(submissionId);
    if (!submission) return;

    const profile = this.profiles.get(submission.userId);
    if (!profile) return;

    submission.status = KycStatus.REJECTED;
    submission.reviewedAt = new Date();
    submission.rejectionReasons = reasons;
    submission.canTrade = false;

    profile.status = KycStatus.REJECTED;
    profile.rejectionReasons = reasons;
    profile.canTrade = false;
    profile.updatedAt = new Date();

    this.pendingReviews.delete(submissionId);

    logger.warn(`KYC rejected for user ${submission.userId}: ${submissionId}`, { reasons });
    
    // Notify user
    await this.notifyKycStatusChange(submission.userId, KycStatus.REJECTED, reasons);
  }

  /**
   * Check if user can trade (KYC approved)
   */
  async canUserTrade(userId: string): Promise<boolean> {
    const profile = await this.getKycProfile(userId);
    return profile.canTrade && profile.status === KycStatus.APPROVED;
  }

  /**
   * Get KYC status for user
   */
  async getKycStatus(userId: string): Promise<{
    status: KycStatus;
    canTrade: boolean;
    message: string;
    nextSteps?: string[];
  }> {
    const profile = await this.getKycProfile(userId);
    
    const statusMessages = {
      [KycStatus.NOT_STARTED]: 'Complete identity verification to enable real trading',
      [KycStatus.IN_PROGRESS]: 'Please complete all verification steps',
      [KycStatus.SUBMITTED]: 'We\'re reviewing your documents. This usually takes 1-2 business days.',
      [KycStatus.APPROVED]: 'Your identity has been verified. You can now trade with real money.',
      [KycStatus.REJECTED]: 'Verification was rejected. Please review the reasons and resubmit.',
      [KycStatus.NEEDS_REVIEW]: 'Additional information is required. Please check your messages.',
    };

    const nextSteps: Record<KycStatus, string[]> = {
      [KycStatus.NOT_STARTED]: ['Complete personal information', 'Upload identification documents', 'Submit for review'],
      [KycStatus.IN_PROGRESS]: ['Complete remaining verification steps'],
      [KycStatus.SUBMITTED]: ['Wait for review completion'],
      [KycStatus.APPROVED]: [],
      [KycStatus.REJECTED]: ['Review rejection reasons', 'Correct issues', 'Resubmit verification'],
      [KycStatus.NEEDS_REVIEW]: ['Check messages for required actions', 'Provide additional information'],
    };

    return {
      status: profile.status,
      canTrade: profile.canTrade,
      message: statusMessages[profile.status],
      nextSteps: nextSteps[profile.status],
    };
  }

  /**
   * Get submission details
   */
  async getSubmission(submissionId: string): Promise<KycSubmission | null> {
    return this.submissions.get(submissionId) || null;
  }

  /**
   * Validate KYC request
   */
  private validateKycRequest(request: KycVerificationRequest): void {
    const { personalInfo, addressInfo, documents } = request;

    // Validate personal info
    if (!personalInfo.firstName || !personalInfo.lastName) {
      throw new AppError('First name and last name are required', 400);
    }

    if (!personalInfo.dateOfBirth) {
      throw new AppError('Date of birth is required', 400);
    }

    if (!personalInfo.phoneNumber) {
      throw new AppError('Phone number is required', 400);
    }

    // Validate address
    if (!addressInfo.streetAddress || !addressInfo.city || !addressInfo.state || !addressInfo.country) {
      throw new AppError('Complete address information is required', 400);
    }

    // Validate documents
    if (!documents.frontIdImage || !documents.backIdImage || !documents.selfieImage) {
      throw new AppError('All document images are required', 400);
    }

    if (!documents.documentType) {
      throw new AppError('Document type is required', 400);
    }
  }

  /**
   * Upload document (placeholder implementation)
   */
  private async uploadDocument(buffer: Buffer, type: string): Promise<string> {
    // In production, this would upload to S3/GCS/Azure and return URL
    // For demo, return a placeholder URL
    const documentId = this.generateId();
    return `https://documents.kingdom.com/${type}/${documentId}`;
  }

  /**
   * Notify user of KYC status change
   */
  private async notifyKycStatusChange(
    userId: string, 
    status: KycStatus, 
    reasons?: string[]
  ): Promise<void> {
    // In production, this would send push notifications, emails, etc.
    logger.info(`KYC status notification for user ${userId}: ${status}`, { reasons });
  }

  /**
   * Admin: Get all pending reviews
   */
  async getPendingReviews(): Promise<KycSubmission[]> {
    return Array.from(this.pendingReviews.values());
  }

  /**
   * Admin: Manually review submission
   */
  async manualReview(
    submissionId: string, 
    decision: 'approve' | 'reject', 
    notes: string,
    reasons?: string[]
  ): Promise<void> {
    const submission = this.submissions.get(submissionId);
    if (!submission) {
      throw new AppError('Submission not found', 404);
    }

    const profile = this.profiles.get(submission.userId);
    if (!profile) {
      throw new AppError('Profile not found', 404);
    }

    if (decision === 'approve') {
      submission.status = KycStatus.APPROVED;
      submission.canTrade = true;
      profile.status = KycStatus.APPROVED;
      profile.canTrade = true;
      profile.approvedAt = new Date();
    } else {
      submission.status = KycStatus.REJECTED;
      submission.canTrade = false;
      submission.rejectionReasons = reasons || [];
      profile.status = KycStatus.REJECTED;
      profile.canTrade = false;
      profile.rejectionReasons = reasons || [];
    }

    submission.reviewedAt = new Date();
    submission.reviewNotes.push(notes);
    profile.updatedAt = new Date();

    this.pendingReviews.delete(submissionId);

    logger.info(`Manual KYC review completed for ${submissionId}: ${decision}`, { notes, reasons });
    
    await this.notifyKycStatusChange(submission.userId, submission.status, reasons);
  }

  private generateId(): string {
    return `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  private generateSubmissionId(): string {
    return `kyc_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}