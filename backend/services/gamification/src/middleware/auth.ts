import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/app-error';

export const validateAuth = (req: Request, res: Response, next: NextFunction): void => {
  const userId = req.headers['x-user-id'] as string;

  if (!userId) {
    return next(new AppError('User ID required', 401));
  }

  next();
};