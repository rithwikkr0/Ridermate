import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import { createMemoryController, getMemoriesController } from '../controllers/memories.controller';

const router = Router();

/**
 * @route   POST /api/memories
 * @desc    Create a new memory
 * @access  Private
 */
router.post('/', authenticate, createMemoryController);

/**
 * @route   GET /api/memories/:userId
 * @desc    Get memories for a user
 * @access  Private
 */
router.get('/:userId', authenticate, getMemoriesController);

export default router;
