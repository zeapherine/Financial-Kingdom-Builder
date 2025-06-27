import { Request, Response, NextFunction } from 'express';
import { body, param, query, validationResult, ValidationChain, Meta } from 'express-validator';
import DOMPurify from 'isomorphic-dompurify';
import { logger } from '../utils/logger-factory';

// Extend Request interface for file uploads
interface RequestWithFile extends Request {
  file?: {
    size: number;
    mimetype: string;
  };
}

export interface ValidationConfig {
  sanitizeHtml: boolean;
  trimWhitespace: boolean;
  allowXSSProtection: boolean;
  maxStringLength: number;
  customSanitizers: Record<string, (value: any) => any>;
}

export interface ValidationError {
  field: string;
  message: string;
  value: any;
  location: string;
}

export class InputValidator {
  private config: ValidationConfig;

  constructor(config?: Partial<ValidationConfig>) {
    this.config = {
      sanitizeHtml: true,
      trimWhitespace: true,
      allowXSSProtection: true,
      maxStringLength: 10000,
      customSanitizers: {},
      ...config
    };
  }

  /**
   * Sanitize string input
   */
  public sanitizeString(value: string): string {
    if (typeof value !== 'string') {
      return String(value);
    }

    let sanitized = value;

    // Trim whitespace
    if (this.config.trimWhitespace) {
      sanitized = sanitized.trim();
    }

    // HTML sanitization
    if (this.config.sanitizeHtml) {
      sanitized = DOMPurify.sanitize(sanitized, { ALLOWED_TAGS: [] });
    }

    // Length validation
    if (sanitized.length > this.config.maxStringLength) {
      sanitized = sanitized.substring(0, this.config.maxStringLength);
    }

    // Remove null bytes
    sanitized = sanitized.replace(/\0/g, '');

    // Remove control characters except newlines and tabs
    sanitized = sanitized.replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '');

    return sanitized;
  }

  /**
   * Sanitize object recursively
   */
  public sanitizeObject(obj: any): any {
    if (obj === null || obj === undefined) {
      return obj;
    }

    if (typeof obj === 'string') {
      return this.sanitizeString(obj);
    }

    if (typeof obj === 'number' || typeof obj === 'boolean') {
      return obj;
    }

    if (Array.isArray(obj)) {
      return obj.map(item => this.sanitizeObject(item));
    }

    if (typeof obj === 'object') {
      const sanitized: any = {};
      for (const [key, value] of Object.entries(obj)) {
        const sanitizedKey = this.sanitizeString(key);
        sanitized[sanitizedKey] = this.sanitizeObject(value);
      }
      return sanitized;
    }

    return obj;
  }

  /**
   * Validation middleware factory
   */
  public validate(validations: ValidationChain[]) {
    return async (req: Request, res: Response, next: NextFunction) => {
      try {
        // Apply sanitization first
        req.body = this.sanitizeObject(req.body);
        req.query = this.sanitizeObject(req.query);
        req.params = this.sanitizeObject(req.params);

        // Run validations
        await Promise.all(validations.map(validation => validation.run(req)));

        // Check for validation errors
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
          const validationErrors: ValidationError[] = errors.array().map(error => ({
            field: (error as any).param || 'unknown',
            message: error.msg,
            value: (error as any).value,
            location: (error as any).location
          }));

          logger.warn('Validation failed', {
            path: req.path,
            method: req.method,
            errors: validationErrors,
            ip: req.ip
          });

          res.status(400).json({
            error: 'Validation Error',
            message: 'Invalid input data',
            details: validationErrors
          });
          return;
        }

        next();
      } catch (error) {
        logger.error('Validation middleware error', {
          error: error instanceof Error ? error.message : 'Unknown error',
          path: req.path,
          method: req.method
        });

        res.status(500).json({
          error: 'Internal Server Error',
          message: 'Validation processing failed'
        });
      }
    };
  }
}

/**
 * Common validation rules
 */
export const ValidationRules = {
  // User authentication
  email: () => body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Must be a valid email address'),

  password: () => body('password')
    .isLength({ min: 8, max: 128 })
    .withMessage('Password must be between 8 and 128 characters')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])/)
    .withMessage('Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character'),

  username: () => body('username')
    .isLength({ min: 3, max: 30 })
    .matches(/^[a-zA-Z0-9_-]+$/)
    .withMessage('Username must be 3-30 characters and contain only letters, numbers, hyphens, and underscores'),

  // User profile
  firstName: () => body('firstName')
    .isLength({ min: 1, max: 50 })
    .matches(/^[a-zA-Z\s'-]+$/)
    .withMessage('First name must be 1-50 characters and contain only letters, spaces, hyphens, and apostrophes'),

  lastName: () => body('lastName')
    .isLength({ min: 1, max: 50 })
    .matches(/^[a-zA-Z\s'-]+$/)
    .withMessage('Last name must be 1-50 characters and contain only letters, spaces, hyphens, and apostrophes'),

  // Trading
  amount: () => body('amount')
    .isFloat({ min: 0.01, max: 1000000 })
    .withMessage('Amount must be a positive number between 0.01 and 1,000,000'),

  symbol: () => body('symbol')
    .isLength({ min: 1, max: 20 })
    .matches(/^[A-Z0-9-]+$/)
    .withMessage('Symbol must be 1-20 characters and contain only uppercase letters, numbers, and hyphens'),

  orderType: () => body('orderType')
    .isIn(['market', 'limit', 'stop', 'stop-limit'])
    .withMessage('Order type must be one of: market, limit, stop, stop-limit'),

  side: () => body('side')
    .isIn(['buy', 'sell'])
    .withMessage('Side must be either buy or sell'),

  price: () => body('price')
    .optional()
    .isFloat({ min: 0.00001 })
    .withMessage('Price must be a positive number'),

  // UUID validation
  uuid: (field: string = 'id') => param(field)
    .isUUID()
    .withMessage(`${field} must be a valid UUID`),

  // Pagination
  page: () => query('page')
    .optional()
    .isInt({ min: 1, max: 1000 })
    .withMessage('Page must be an integer between 1 and 1000'),

  limit: () => query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be an integer between 1 and 100'),

  // Dates
  dateRange: () => [
    query('startDate')
      .optional()
      .isISO8601()
      .withMessage('Start date must be a valid ISO 8601 date'),
    query('endDate')
      .optional()
      .isISO8601()
      .withMessage('End date must be a valid ISO 8601 date')
      .custom((endDate, { req }) => {
        if (req.query?.startDate && endDate) {
          const start = new Date(req.query.startDate as string);
          const end = new Date(endDate);
          if (end <= start) {
            throw new Error('End date must be after start date');
          }
        }
        return true;
      })
  ],

  // Text content
  title: () => body('title')
    .isLength({ min: 1, max: 200 })
    .withMessage('Title must be between 1 and 200 characters'),

  description: () => body('description')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Description must not exceed 1000 characters'),

  // Educational content
  moduleContent: () => body('content')
    .isLength({ min: 10, max: 50000 })
    .withMessage('Module content must be between 10 and 50,000 characters'),

  tier: () => body('tier')
    .isInt({ min: 1, max: 4 })
    .withMessage('Tier must be an integer between 1 and 4'),

  category: () => body('category')
    .isIn(['financial-literacy', 'risk-management', 'technical-analysis', 'options', 'perpetuals'])
    .withMessage('Category must be one of the allowed educational categories'),

  // File uploads
  fileSize: (maxSizeBytes: number) => (req: RequestWithFile, res: Response, next: NextFunction) => {
    if (req.file && req.file.size > maxSizeBytes) {
      return res.status(400).json({
        error: 'File Too Large',
        message: `File size must not exceed ${maxSizeBytes / 1024 / 1024}MB`
      });
    }
    next();
  },

  fileType: (allowedTypes: string[]) => (req: RequestWithFile, res: Response, next: NextFunction) => {
    if (req.file && !allowedTypes.includes(req.file.mimetype)) {
      return res.status(400).json({
        error: 'Invalid File Type',
        message: `File type must be one of: ${allowedTypes.join(', ')}`
      });
    }
    next();
  },

  // Security
  ipAddress: () => body('ipAddress')
    .optional()
    .isIP()
    .withMessage('Must be a valid IP address'),

  userAgent: () => body('userAgent')
    .optional()
    .isLength({ max: 500 })
    .withMessage('User agent must not exceed 500 characters'),

  // Financial
  cryptoAddress: () => body('address')
    .matches(/^(0x)?[0-9a-fA-F]{40}$/)
    .withMessage('Must be a valid Ethereum address'),

  percentage: () => body('percentage')
    .isFloat({ min: 0, max: 100 })
    .withMessage('Percentage must be between 0 and 100'),

  // Social features
  message: () => body('message')
    .isLength({ min: 1, max: 500 })
    .withMessage('Message must be between 1 and 500 characters'),

  tags: () => body('tags')
    .optional()
    .isArray({ max: 10 })
    .withMessage('Tags must be an array with maximum 10 items')
    .custom((tags) => {
      if (Array.isArray(tags)) {
        return tags.every(tag => 
          typeof tag === 'string' && 
          tag.length >= 1 && 
          tag.length <= 50 &&
          /^[a-zA-Z0-9-_]+$/.test(tag)
        );
      }
      return true;
    })
    .withMessage('Each tag must be 1-50 characters and contain only letters, numbers, hyphens, and underscores')
};

/**
 * Validation rule sets for common endpoints
 */
export const ValidationSets = {
  userRegistration: [
    ValidationRules.email(),
    ValidationRules.password(),
    ValidationRules.username(),
    ValidationRules.firstName(),
    ValidationRules.lastName()
  ],

  userLogin: [
    ValidationRules.email(),
    ValidationRules.password()
  ],

  placeOrder: [
    ValidationRules.symbol(),
    ValidationRules.amount(),
    ValidationRules.side(),
    ValidationRules.orderType(),
    ValidationRules.price()
  ],

  createModule: [
    ValidationRules.title(),
    ValidationRules.description(),
    ValidationRules.moduleContent(),
    ValidationRules.tier(),
    ValidationRules.category(),
    ValidationRules.tags()
  ],

  pagination: [
    ValidationRules.page(),
    ValidationRules.limit()
  ],

  dateFilter: ValidationRules.dateRange()
};

/**
 * Create input validator with default configuration
 */
export function createInputValidator(config?: Partial<ValidationConfig>): InputValidator {
  return new InputValidator(config);
}

/**
 * XSS protection middleware
 */
export function xssProtection() {
  return (req: Request, res: Response, next: NextFunction) => {
    const validator = createInputValidator();
    
    // Sanitize all incoming data
    req.body = validator.sanitizeObject(req.body);
    req.query = validator.sanitizeObject(req.query);
    req.params = validator.sanitizeObject(req.params);
    
    next();
  };
}

/**
 * Custom validation for file uploads
 */
export function validateFileUpload(options: {
  maxSize?: number;
  allowedTypes?: string[];
  required?: boolean;
}) {
  return (req: RequestWithFile, res: Response, next: NextFunction) => {
    if (options.required && !req.file) {
      return res.status(400).json({
        error: 'File Required',
        message: 'A file must be uploaded'
      });
    }

    if (req.file) {
      if (options.maxSize && req.file.size > options.maxSize) {
        return res.status(400).json({
          error: 'File Too Large',
          message: `File size must not exceed ${options.maxSize / 1024 / 1024}MB`
        });
      }

      if (options.allowedTypes && !options.allowedTypes.includes(req.file.mimetype)) {
        return res.status(400).json({
          error: 'Invalid File Type',
          message: `File type must be one of: ${options.allowedTypes.join(', ')}`
        });
      }
    }

    next();
  };
}