import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import { createMemoryController, getMemoriesController } from '../controllers/memories.controller';
import { apiLimiter } from '../middleware/rate-limit.middleware';

const router = Router();

/**
 * @route   POST /api/memories
 * @desc    Create a new memory
 * @access  Private
 */
router.post('/', apiLimiter, authenticate, createMemoryController);

/**
 * @route   GET /api/memories/:userId
 * @desc    Get memories for a user
 * @access  Private
 */
router.get('/:userId', apiLimiter, authenticate, getMemoriesController);

export default router;
