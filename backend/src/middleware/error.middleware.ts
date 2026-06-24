import { Request, Response, NextFunction } from 'express';
import { AppError, ErrorResponse } from '../types/api.types';

export const errorHandler = (
  err: Error | AppError,
  _req: Request,
  res: Response,
  _next: NextFunction
): void => {
  console.error('Error:', err);

  if (err instanceof AppError) {
    const response: ErrorResponse = {
      success: false,
      error: {
        message: err.message,
        code: err.code,
        details: err.details,
      },
      timestamp: new Date(),
    };
    res.status(err.statusCode).json(response);
    return;
  }

  // Handle specific error types
  if (err.name === 'ValidationError') {
    const response: ErrorResponse = {
      success: false,
      error: {
        message: 'Validation error',
        code: 'VALIDATION_ERROR',
        details: err.message,
      },
      timestamp: new Date(),
    };
    res.status(400).json(response);
    return;
  }

  if (err.name === 'JsonWebTokenError') {
    const response: ErrorResponse = {
      success: false,
      error: {
        message: 'Invalid token',
        code: 'INVALID_TOKEN',
      },
      timestamp: new Date(),
    };
    res.status(401).json(response);
    return;
  }

  // Default error response
  const response: ErrorResponse = {
    success: false,
    error: {
      message: process.env.NODE_ENV === 'production' 
        ? 'Internal server error' 
        : err.message,
      code: 'INTERNAL_ERROR',
      details: process.env.NODE_ENV === 'production' ? undefined : err.stack,
    },
    timestamp: new Date(),
  };
  res.status(500).json(response);
};

export const notFoundHandler = (
  req: Request,
  _res: Response,
  next: NextFunction
): void => {
  const error = new AppError(404, `Route ${req.originalUrl} not found`, 'NOT_FOUND');
  next(error);
};
