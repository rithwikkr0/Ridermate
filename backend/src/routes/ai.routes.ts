import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import { analyzeRideController, chatController } from '../controllers/ai.controller';
import { aiLimiter } from '../middleware/rate-limit.middleware';

const router = Router();

/**
 * @route   POST /api/ai/analyze-ride
 * @desc    Analyze a ride with AI
 * @access  Private
 */
router.post('/analyze-ride', aiLimiter, authenticate, analyzeRideController);

/**
 * @route   POST /api/ai/chat
 * @desc    Chat with AI assistant
 * @access  Private
 */
router.post('/chat', aiLimiter, authenticate, chatController);

export default router;
