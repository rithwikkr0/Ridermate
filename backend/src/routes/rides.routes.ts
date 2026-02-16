import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import {
  startRide,
  endRide,
  pauseRide,
  resumeRide,
  getRide,
  getUserRidesController,
} from '../controllers/rides.controller';
import { apiLimiter } from '../middleware/rate-limit.middleware';

const router = Router();

/**
 * @route   POST /api/rides/start
 * @desc    Start a new ride
 * @access  Private
 */
router.post('/start', apiLimiter, authenticate, startRide);

/**
 * @route   POST /api/rides/end
 * @desc    End an active ride
 * @access  Private
 */
router.post('/end', apiLimiter, authenticate, endRide);

/**
 * @route   POST /api/rides/pause
 * @desc    Pause an active ride
 * @access  Private
 */
router.post('/pause', apiLimiter, authenticate, pauseRide);

/**
 * @route   POST /api/rides/resume
 * @desc    Resume a paused ride
 * @access  Private
 */
router.post('/resume', apiLimiter, authenticate, resumeRide);

/**
 * @route   GET /api/rides/:rideId
 * @desc    Get a specific ride by ID
 * @access  Private
 */
router.get('/:rideId', apiLimiter, authenticate, getRide);

/**
 * @route   GET /api/rides/user/:userId
 * @desc    Get all rides for a user
 * @access  Private
 */
router.get('/user/:userId', apiLimiter, authenticate, getUserRidesController);

export default router;
