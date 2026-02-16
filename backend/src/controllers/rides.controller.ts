import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { createRide, getRideById, updateRide, getUserRides, updateUser, getUserById } from '../services/firebase.service';
import { Ride, Location } from '../types/ride.types';
import { ApiResponse, AppError } from '../types/api.types';

export const startRide = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.userId!;
    const { startLocation } = req.body;

    if (!startLocation || !startLocation.latitude || !startLocation.longitude) {
      throw new AppError(400, 'Start location is required', 'MISSING_LOCATION');
    }

    const location: Location = {
      latitude: startLocation.latitude,
      longitude: startLocation.longitude,
      timestamp: new Date(),
      speed: startLocation.speed,
      altitude: startLocation.altitude,
    };

    const ride = await createRide({
      userId,
      startTime: new Date(),
      status: 'active',
      route: [location],
      stats: {
        distance: 0,
        duration: 0,
        averageSpeed: 0,
        maxSpeed: 0,
        elevationGain: 0,
      },
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    const response: ApiResponse = {
      success: true,
      data: ride,
      timestamp: new Date(),
    };

    res.status(201).json(response);
  } catch (error) {
    next(error);
  }
};

export const endRide = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { rideId } = req.body;
    const { endLocation } = req.body;

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

    if (ride.status === 'completed') {
      throw new AppError(400, 'Ride already completed', 'RIDE_COMPLETED');
    }

    // Add end location to route
    if (endLocation) {
      const location: Location = {
        latitude: endLocation.latitude,
        longitude: endLocation.longitude,
        timestamp: new Date(),
        speed: endLocation.speed,
        altitude: endLocation.altitude,
      };
      ride.route.push(location);
    }

    // Calculate final stats
    const endTime = new Date();
    const duration = (endTime.getTime() - ride.startTime.getTime()) / 1000;
    const pausedDuration = ride.pausedDuration || 0;
    const activeDuration = duration - pausedDuration;

    await updateRide(rideId, {
      status: 'completed',
      endTime,
      route: ride.route,
      stats: {
        ...ride.stats,
        duration: activeDuration,
      },
    });

    // Update user stats
    const user = await getUserById(ride.userId);
    if (user) {
      await updateUser(ride.userId, {
        stats: {
          totalRides: (user.stats?.totalRides || 0) + 1,
          totalDistance: (user.stats?.totalDistance || 0) + ride.stats.distance,
          totalDuration: (user.stats?.totalDuration || 0) + activeDuration,
          averageSpeed: user.stats?.averageSpeed || ride.stats.averageSpeed,
        },
      });
    }

    const updatedRide = await getRideById(rideId);

    const response: ApiResponse = {
      success: true,
      data: updatedRide,
      timestamp: new Date(),
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};

export const pauseRide = async (
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

    if (ride.status !== 'active') {
      throw new AppError(400, 'Ride is not active', 'RIDE_NOT_ACTIVE');
    }

    const pauseTimestamps = ride.pauseTimestamps || [];
    pauseTimestamps.push({
      pausedAt: new Date(),
    });

    await updateRide(rideId, {
      status: 'paused',
      pauseTimestamps,
    });

    const updatedRide = await getRideById(rideId);

    const response: ApiResponse = {
      success: true,
      data: updatedRide,
      timestamp: new Date(),
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};

export const resumeRide = async (
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

    if (ride.status !== 'paused') {
      throw new AppError(400, 'Ride is not paused', 'RIDE_NOT_PAUSED');
    }

    const pauseTimestamps = ride.pauseTimestamps || [];
    const lastPause = pauseTimestamps[pauseTimestamps.length - 1];
    
    if (lastPause) {
      lastPause.resumedAt = new Date();
      const pauseDuration = (lastPause.resumedAt.getTime() - lastPause.pausedAt.getTime()) / 1000;
      const totalPausedDuration = (ride.pausedDuration || 0) + pauseDuration;

      await updateRide(rideId, {
        status: 'active',
        pauseTimestamps,
        pausedDuration: totalPausedDuration,
      });
    } else {
      await updateRide(rideId, {
        status: 'active',
      });
    }

    const updatedRide = await getRideById(rideId);

    const response: ApiResponse = {
      success: true,
      data: updatedRide,
      timestamp: new Date(),
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};

export const getRide = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { rideId } = req.params;

    const ride = await getRideById(rideId);
    if (!ride) {
      throw new AppError(404, 'Ride not found', 'RIDE_NOT_FOUND');
    }

    const response: ApiResponse = {
      success: true,
      data: ride,
      timestamp: new Date(),
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};

export const getUserRidesController = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit as string) || 50;

    const rides = await getUserRides(userId, limit);

    const response: ApiResponse = {
      success: true,
      data: rides,
      timestamp: new Date(),
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};
