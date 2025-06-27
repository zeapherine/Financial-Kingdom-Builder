import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/app-error';
import { logger } from '../utils/logger';

export const errorHandler = (
  err: Error | AppError,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  let error = { ...err } as AppError;
  error.message = err.message;

  const statusCode = error.statusCode || 500;
  const message = error.message || 'Internal Server Error';

  logger.error(`${statusCode} - ${message} - ${req.originalUrl} - ${req.method}`);

  res.status(statusCode).json({
    error: 'Gamification Service Error',
    message,
    timestamp: new Date().toISOString(),
  });
};