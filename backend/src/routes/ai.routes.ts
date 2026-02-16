import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import { analyzeRideController, chatController } from '../controllers/ai.controller';

const router = Router();

/**
 * @route   POST /api/ai/analyze-ride
 * @desc    Analyze a ride with AI
 * @access  Private
 */
router.post('/analyze-ride', authenticate, analyzeRideController);

/**
 * @route   POST /api/ai/chat
 * @desc    Chat with AI assistant
 * @access  Private
 */
router.post('/chat', authenticate, chatController);

export default router;
