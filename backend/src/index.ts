import express, { Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';

import { config } from './config/server.config';
import { initializeFirebase } from './config/firebase.config';
import { errorHandler, notFoundHandler } from './middleware/error.middleware';

// Routes
import authRoutes from './routes/auth.routes';
import ridesRoutes from './routes/rides.routes';
import aiRoutes from './routes/ai.routes';
import memoriesRoutes from './routes/memories.routes';
import friendsRoutes from './routes/friends.routes';
import leaderboardRoutes from './routes/leaderboard.routes';

// Load environment variables
dotenv.config();

// Initialize Express app
const app = express();

// Initialize Firebase
initializeFirebase();

// Middleware
app.use(helmet()); // Security headers
app.use(cors({
  origin: config.cors.origin,
  credentials: true,
}));
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies
app.use(morgan(config.nodeEnv === 'production' ? 'combined' : 'dev')); // Request logging

// Health check endpoint
app.get('/health', (_req: Request, res: Response) => {
  res.status(200).json({
    success: true,
    message: 'RiderMate API is running',
    timestamp: new Date(),
    environment: config.nodeEnv,
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/rides', ridesRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/memories', memoriesRoutes);
app.use('/api/friends', friendsRoutes);
app.use('/api/leaderboard', leaderboardRoutes);

// 404 handler
app.use(notFoundHandler);

// Error handler (must be last)
app.use(errorHandler);

// Start server
const PORT = config.port;

app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════╗
║                                                   ║
║   🚴 RiderMate Backend API Server                ║
║                                                   ║
║   Environment: ${config.nodeEnv.padEnd(35)}║
║   Port:        ${PORT.toString().padEnd(35)}║
║   Status:      Running ✓                         ║
║                                                   ║
╚═══════════════════════════════════════════════════╝

Available endpoints:
  GET  /health
  POST /api/auth/register
  POST /api/auth/login
  POST /api/rides/start
  POST /api/rides/end
  POST /api/rides/pause
  POST /api/rides/resume
  GET  /api/rides/:rideId
  GET  /api/rides/user/:userId
  POST /api/ai/analyze-ride
  POST /api/ai/chat
  POST /api/memories
  GET  /api/memories/:userId
  POST /api/friends/request
  GET  /api/friends/:userId
  GET  /api/leaderboard
  `);
});

export default app;
