import { Router } from 'express';
import { optionalAuth } from '../middleware/auth.middleware';
import { getLeaderboardController } from '../controllers/leaderboard.controller';

const router = Router();

/**
 * @route   GET /api/leaderboard
 * @desc    Get leaderboard
 * @access  Public
 */
router.get('/', optionalAuth, getLeaderboardController);

export default router;
