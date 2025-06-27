import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { AppError } from '../utils/app-error';
import { logger } from '../utils/logger';

interface JwtPayload {
  userId: string;
  email: string;
  tier: number;
  iat: number;
  exp: number;
}

declare global {
  namespace Express {
    interface Request {
      user?: JwtPayload;
    }
  }
}

export const authMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    let token: string | undefined;

    if (req.headers.authorization?.startsWith('Bearer ')) {
      token = req.headers.authorization.split(' ')[1];
    } else if (req.headers['x-api-key']) {
      token = req.headers['x-api-key'] as string;
    }

    if (!token) {
      return next(new AppError('Access token required', 401));
    }

    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) {
      logger.error('JWT_SECRET not configured');
      return next(new AppError('Server configuration error', 500));
    }

    try {
      const decoded = jwt.verify(token, jwtSecret) as JwtPayload;
      
      if (!decoded.userId || !decoded.email) {
        return next(new AppError('Invalid token payload', 401));
      }

      req.user = decoded;

      req.headers['x-user-id'] = decoded.userId;
      req.headers['x-user-email'] = decoded.email;
      req.headers['x-user-tier'] = decoded.tier.toString();

      logger.debug(`Authenticated user ${decoded.userId} for ${req.method} ${req.originalUrl}`);
      
      next();
    } catch (jwtError) {
      if (jwtError instanceof jwt.TokenExpiredError) {
        return next(new AppError('Token expired', 401));
      } else if (jwtError instanceof jwt.JsonWebTokenError) {
        return next(new AppError('Invalid token', 401));
      }
      
      logger.error('JWT verification error:', jwtError);
      return next(new AppError('Authentication failed', 401));
    }
  } catch (error) {
    logger.error('Auth middleware error:', error);
    next(new AppError('Authentication failed', 500));
  }
};

export const optionalAuth = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const token = req.headers.authorization?.startsWith('Bearer ')
      ? req.headers.authorization.split(' ')[1]
      : req.headers['x-api-key'] as string;

    if (!token) {
      return next();
    }

    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) {
      return next();
    }

    try {
      const decoded = jwt.verify(token, jwtSecret) as JwtPayload;
      req.user = decoded;
      req.headers['x-user-id'] = decoded.userId;
      req.headers['x-user-email'] = decoded.email;
      req.headers['x-user-tier'] = decoded.tier.toString();
    } catch {
      // Silent fail for optional auth
    }

    next();
  } catch (error) {
    logger.error('Optional auth middleware error:', error);
    next();
  }
};