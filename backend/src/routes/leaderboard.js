const express = require('express');
const router = express.Router();
const leaderboardController = require('../controllers/LeaderboardController');

router.get('/global', leaderboardController.getGlobalLeaderboard);
router.get('/friends/:userId', leaderboardController.getFriendsLeaderboard);
router.get('/safety', leaderboardController.getSafetyLeaderboard);
router.get('/distance', leaderboardController.getDistanceLeaderboard);
router.post('/update', leaderboardController.updateLeaderboard);

module.exports = router;
