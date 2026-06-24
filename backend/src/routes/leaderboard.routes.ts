import { Router } from 'express';
import { optionalAuth } from '../middleware/auth.middleware';
import { getLeaderboardController } from '../controllers/leaderboard.controller';
import { apiLimiter } from '../middleware/rate-limit.middleware';

const router = Router();

/**
 * @route   GET /api/leaderboard
 * @desc    Get leaderboard
 * @access  Public
 */
router.get('/', apiLimiter, optionalAuth, getLeaderboardController);

export default router;
