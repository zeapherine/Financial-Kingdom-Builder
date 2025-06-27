import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/app-error';
import { logger } from '../utils/logger';

interface ErrorResponse {
  error: string;
  message: string;
  timestamp: string;
  path: string;
  statusCode: number;
  stack?: string;
}

export const errorHandler = (
  err: Error | AppError,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  let error = { ...err } as AppError;
  error.message = err.message;

  if (err.name === 'CastError') {
    const message = 'Resource not found';
    error = new AppError(message, 404);
  }

  if (err.name === 'ValidationError') {
    const message = 'Validation Error';
    error = new AppError(message, 400);
  }

  if (err.name === 'JsonWebTokenError') {
    const message = 'Invalid token';
    error = new AppError(message, 401);
  }

  if (err.name === 'TokenExpiredError') {
    const message = 'Token expired';
    error = new AppError(message, 401);
  }

  const statusCode = error.statusCode || 500;
  const message = error.message || 'Internal Server Error';

  const errorResponse: ErrorResponse = {
    error: error.name || 'Error',
    message,
    timestamp: new Date().toISOString(),
    path: req.originalUrl,
    statusCode,
  };

  if (process.env.NODE_ENV === 'development') {
    errorResponse.stack = err.stack;
  }

  logger.error(`${statusCode} - ${message} - ${req.originalUrl} - ${req.method} - ${req.ip}`, {
    error: err,
    request: {
      method: req.method,
      url: req.originalUrl,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
    },
  });

  if (statusCode >= 500) {
    logger.error('Server Error:', err);
  }

  res.status(statusCode).json(errorResponse);
};