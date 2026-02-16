const express = require('express');
const cors = require('cors');
require('dotenv').config();

const { initializeFirebase } = require('./config/firebase');
const leaderboardRoutes = require('./routes/leaderboard');
const pointsRoutes = require('./routes/points');
const badgesRoutes = require('./routes/badges');
const achievementsRoutes = require('./routes/achievements');
const usersRoutes = require('./routes/users');

// Initialize Firebase
initializeFirebase();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/leaderboard', leaderboardRoutes);
app.use('/api/points', pointsRoutes);
app.use('/api/badges', badgesRoutes);
app.use('/api/achievements', achievementsRoutes);
app.use('/api/users', usersRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: err.message,
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`RiderMate Backend running on port ${PORT}`);
});

module.exports = app;
