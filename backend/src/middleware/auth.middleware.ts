import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config/server.config';
import { AppError } from '../types/api.types';

export interface AuthRequest extends Request {
  userId?: string;
  user?: any;
}

export const authenticate = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AppError(401, 'No token provided', 'UNAUTHORIZED');
    }

    const token = authHeader.substring(7);

    try {
      const decoded = jwt.verify(token, config.jwt.secret) as { userId: string };
      req.userId = decoded.userId;
      req.user = decoded;
      next();
    } catch (error) {
      throw new AppError(401, 'Invalid or expired token', 'INVALID_TOKEN');
    }
  } catch (error) {
    next(error);
  }
};

export const optionalAuth = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void => {
  try {
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      try {
        const decoded = jwt.verify(token, config.jwt.secret) as { userId: string };
        req.userId = decoded.userId;
        req.user = decoded;
      } catch (error) {
        // Ignore token errors for optional auth
      }
    }
    next();
  } catch (error) {
    next(error);
  }
};
