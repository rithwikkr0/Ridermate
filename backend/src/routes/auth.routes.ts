import { Router } from 'express';
import { register, login } from '../controllers/auth.controller';
import { authLimiter } from '../middleware/rate-limit.middleware';

const router = Router();

/**
 * @route   POST /api/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post('/register', authLimiter, register);

/**
 * @route   POST /api/auth/login
 * @desc    Login user
 * @access  Public
 */
router.post('/login', authLimiter, login);

export default router;
