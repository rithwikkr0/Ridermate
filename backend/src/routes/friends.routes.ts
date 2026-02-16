import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import { sendFriendRequest, getFriends } from '../controllers/friends.controller';

const router = Router();

/**
 * @route   POST /api/friends/request
 * @desc    Send a friend request
 * @access  Private
 */
router.post('/request', authenticate, sendFriendRequest);

/**
 * @route   GET /api/friends/:userId
 * @desc    Get friends for a user
 * @access  Private
 */
router.get('/:userId', authenticate, getFriends);

export default router;
