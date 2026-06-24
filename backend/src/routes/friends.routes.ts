import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import { sendFriendRequest, getFriends } from '../controllers/friends.controller';
import { apiLimiter } from '../middleware/rate-limit.middleware';

const router = Router();

/**
 * @route   POST /api/friends/request
 * @desc    Send a friend request
 * @access  Private
 */
router.post('/request', apiLimiter, authenticate, sendFriendRequest);

/**
 * @route   GET /api/friends/:userId
 * @desc    Get friends for a user
 * @access  Private
 */
router.get('/:userId', apiLimiter, authenticate, getFriends);

export default router;
