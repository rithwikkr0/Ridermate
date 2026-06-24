import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { getRideById, updateRide } from '../services/firebase.service';
import { analyzeRide, chatWithAI } from '../services/openai.service';
import { ApiResponse, AppError } from '../types/api.types';
import { ChatRequest } from '../types/other.types';

export const analyzeRideController = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { rideId } = req.body;

    if (!rideId) {
      throw new AppError(400, 'Ride ID is required', 'MISSING_RIDE_ID');
    }

    const ride = await getRideById(rideId);
    if (!ride) {
      throw new AppError(404, 'Ride not found', 'RIDE_NOT_FOUND');
    }

    if (ride.userId !== req.userId) {
      throw new AppError(403, 'Unauthorized', 'UNAUTHORIZED');
    }

    // Perform AI analysis
    const analysis = await analyzeRide(ride);

    // Update ride with analysis
    await updateRide(rideId, {
      aiAnalysis: {
        ...analysis,
        analyzedAt: new Date(),
      },
    });

    const response: ApiResponse = {
      success: true,
      data: {
        rideId,
        analysis: {
          ...analysis,
          analyzedAt: new Date(),
        },
      },
      timestamp: new Date(),
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};

export const chatController = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { message, conversationHistory } = req.body as ChatRequest;

    if (!message) {
      throw new AppError(400, 'Message is required', 'MISSING_MESSAGE');
    }

    const aiResponse = await chatWithAI(message, conversationHistory);

    const response: ApiResponse = {
      success: true,
      data: {
        message: aiResponse,
        role: 'assistant',
      },
      timestamp: new Date(),
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};
