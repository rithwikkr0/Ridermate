import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { createFriendRequest, getUserFriends } from '../services/firebase.service';
import { FriendRequest } from '../types/other.types';
import { ApiResponse, AppError } from '../types/api.types';

export const sendFriendRequest = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.userId!;
    const { friendId } = req.body;

    if (!friendId) {
      throw new AppError(400, 'Friend ID is required', 'MISSING_FRIEND_ID');
    }

    if (userId === friendId) {
      throw new AppError(400, 'Cannot send friend request to yourself', 'INVALID_FRIEND_ID');
    }

    const friend = await createFriendRequest({
      userId,
      friendId,
      status: 'pending',
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    const response: ApiResponse = {
      success: true,
      data: friend,
      timestamp: new Date(),
    };

    res.status(201).json(response);
  } catch (error) {
    next(error);
  }
};

export const getFriends = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { userId } = req.params;

    const friends = await getUserFriends(userId);

    const response: ApiResponse = {
      success: true,
      data: friends,
      timestamp: new Date(),
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};
