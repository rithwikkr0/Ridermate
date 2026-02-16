import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { createMemory, getUserMemories } from '../services/firebase.service';
import { CreateMemoryData } from '../types/other.types';
import { ApiResponse, AppError } from '../types/api.types';

export const createMemoryController = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.userId!;
    const memoryData: CreateMemoryData = {
      ...req.body,
      userId,
    };

    if (!memoryData.title || !memoryData.description) {
      throw new AppError(400, 'Title and description are required', 'MISSING_FIELDS');
    }

    const memory = await createMemory({
      ...memoryData,
      isPublic: memoryData.isPublic ?? true,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    const response: ApiResponse = {
      success: true,
      data: memory,
      timestamp: new Date(),
    };

    res.status(201).json(response);
  } catch (error) {
    next(error);
  }
};

export const getMemoriesController = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit as string) || 50;

    const memories = await getUserMemories(userId, limit);

    const response: ApiResponse = {
      success: true,
      data: memories,
      timestamp: new Date(),
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};
