import { Request, Response, NextFunction } from 'express';
import { registerUser, loginUser } from '../services/auth.service';
import { UserRegistrationData, UserLoginData } from '../types/user.types';
import { ApiResponse } from '../types/api.types';

export const register = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userData: UserRegistrationData = req.body;

    // Basic validation
    if (!userData.email || !userData.username || !userData.password) {
      res.status(400).json({
        success: false,
        error: {
          message: 'Email, username, and password are required',
          code: 'MISSING_FIELDS',
        },
        timestamp: new Date(),
      });
      return;
    }

    const authResponse = await registerUser(userData);

    const response: ApiResponse = {
      success: true,
      data: authResponse,
      timestamp: new Date(),
    };

    res.status(201).json(response);
  } catch (error) {
    next(error);
  }
};

export const login = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const loginData: UserLoginData = req.body;

    // Basic validation
    if (!loginData.email || !loginData.password) {
      res.status(400).json({
        success: false,
        error: {
          message: 'Email and password are required',
          code: 'MISSING_FIELDS',
        },
        timestamp: new Date(),
      });
      return;
    }

    const authResponse = await loginUser(loginData);

    const response: ApiResponse = {
      success: true,
      data: authResponse,
      timestamp: new Date(),
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};
