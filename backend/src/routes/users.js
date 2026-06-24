const express = require('express');
const router = express.Router();
const leaderboardController = require('../controllers/LeaderboardController');

router.get('/:userId/rank', leaderboardController.getUserRank);

module.exports = router;
