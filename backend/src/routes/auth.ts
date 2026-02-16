import { Router } from 'express';
import { authenticate } from '../middleware/auth';

const router = Router();

// Register endpoint (handled by Firebase client SDK)
router.post('/register', (req, res) => {
  res.status(200).json({ 
    message: 'Registration handled by Firebase client SDK' 
  });
});

// Login endpoint (handled by Firebase client SDK)
router.post('/login', (req, res) => {
  res.status(200).json({ 
    message: 'Login handled by Firebase client SDK' 
  });
});

// Verify token endpoint
router.get('/verify', authenticate, (req, res) => {
  res.status(200).json({ 
    message: 'Token is valid',
    user: req.user 
  });
});

// Logout endpoint
router.post('/logout', authenticate, (req, res) => {
  res.status(200).json({ message: 'Logged out successfully' });
});

export default router;
