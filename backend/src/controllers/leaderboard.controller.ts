import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { getLeaderboard } from '../services/firebase.service';
import { ApiResponse } from '../types/api.types';

export const getLeaderboardController = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const limit = parseInt(req.query.limit as string) || 10;

    const leaderboard = await getLeaderboard(limit);

    const response: ApiResponse = {
      success: true,
      data: leaderboard,
      timestamp: new Date(),
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};
