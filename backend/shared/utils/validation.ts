import { body, param, query } from 'express-validator';

// Common validation rules
export const userIdValidation = param('userId').isUUID().withMessage('Invalid user ID format');

export const paginationValidation = [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
];

// Trading validations
export const orderValidation = [
  body('symbol').isString().isLength({ min: 2, max: 10 }).withMessage('Symbol must be 2-10 characters'),
  body('side').isIn(['buy', 'sell']).withMessage('Side must be buy or sell'),
  body('type').isIn(['market', 'limit', 'stop']).withMessage('Type must be market, limit, or stop'),
  body('quantity').isFloat({ min: 0.01 }).withMessage('Quantity must be positive'),
  body('price').optional().isFloat({ min: 0.01 }).withMessage('Price must be positive'),
];

// Education validations
export const quizSubmissionValidation = [
  body('moduleId').isUUID().withMessage('Invalid module ID format'),
  body('answers').isArray().withMessage('Answers must be an array'),
  body('answers.*.questionId').isUUID().withMessage('Invalid question ID format'),
  body('answers.*.answer').notEmpty().withMessage('Answer cannot be empty'),
];

// Social validations
export const messageValidation = [
  body('receiverId').isUUID().withMessage('Invalid receiver ID format'),
  body('content').isString().isLength({ min: 1, max: 1000 }).withMessage('Content must be 1-1000 characters'),
  body('type').isIn(['text', 'image', 'trade-share']).withMessage('Invalid message type'),
];

export const friendRequestValidation = [
  body('receiverId').isUUID().withMessage('Invalid receiver ID format'),
];

// Notification validations
export const notificationPreferencesValidation = [
  body('pushEnabled').isBoolean().withMessage('Push enabled must be boolean'),
  body('emailEnabled').isBoolean().withMessage('Email enabled must be boolean'),
  body('categories.trading').isBoolean().withMessage('Trading category must be boolean'),
  body('categories.education').isBoolean().withMessage('Education category must be boolean'),
  body('categories.social').isBoolean().withMessage('Social category must be boolean'),
  body('categories.achievements').isBoolean().withMessage('Achievements category must be boolean'),
  body('categories.system').isBoolean().withMessage('System category must be boolean'),
];