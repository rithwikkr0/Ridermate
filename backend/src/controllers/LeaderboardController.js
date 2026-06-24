const leaderboardService = require('../services/LeaderboardService');
const { LEADERBOARD_PERIODS } = require('../config/constants');

class LeaderboardController {
  // GET /api/leaderboard/global?period=weekly
  async getGlobalLeaderboard(req, res) {
    try {
      const { period = LEADERBOARD_PERIODS.ALL_TIME, limit = 100 } = req.query;
      const leaderboard = await leaderboardService.getGlobalLeaderboard(period, parseInt(limit));

      res.json({
        success: true,
        period,
        leaderboard,
      });
    } catch (error) {
      console.error('Error in getGlobalLeaderboard:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get global leaderboard',
        error: error.message,
      });
    }
  }

  // GET /api/leaderboard/friends/:userId
  async getFriendsLeaderboard(req, res) {
    try {
      const { userId } = req.params;
      const { period = LEADERBOARD_PERIODS.ALL_TIME } = req.query;

      const leaderboard = await leaderboardService.getFriendsLeaderboard(userId, period);

      res.json({
        success: true,
        period,
        leaderboard,
      });
    } catch (error) {
      console.error('Error in getFriendsLeaderboard:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get friends leaderboard',
        error: error.message,
      });
    }
  }

  // GET /api/leaderboard/safety
  async getSafetyLeaderboard(req, res) {
    try {
      const { limit = 100 } = req.query;
      const leaderboard = await leaderboardService.getSafetyLeaderboard(parseInt(limit));

      res.json({
        success: true,
        leaderboard,
      });
    } catch (error) {
      console.error('Error in getSafetyLeaderboard:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get safety leaderboard',
        error: error.message,
      });
    }
  }

  // GET /api/leaderboard/distance
  async getDistanceLeaderboard(req, res) {
    try {
      const { limit = 100 } = req.query;
      const leaderboard = await leaderboardService.getDistanceLeaderboard(parseInt(limit));

      res.json({
        success: true,
        leaderboard,
      });
    } catch (error) {
      console.error('Error in getDistanceLeaderboard:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get distance leaderboard',
        error: error.message,
      });
    }
  }

  // GET /api/users/:userId/rank
  async getUserRank(req, res) {
    try {
      const { userId } = req.params;
      const { period = LEADERBOARD_PERIODS.ALL_TIME } = req.query;

      const rankData = await leaderboardService.getUserRank(userId, period);

      res.json({
        success: true,
        ...rankData,
      });
    } catch (error) {
      console.error('Error in getUserRank:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get user rank',
        error: error.message,
      });
    }
  }

  // POST /api/leaderboard/update
  async updateLeaderboard(req, res) {
    try {
      const { period = LEADERBOARD_PERIODS.ALL_TIME } = req.body;
      const leaderboard = await leaderboardService.updateLeaderboard(period);

      res.json({
        success: true,
        message: 'Leaderboard updated successfully',
        entriesCount: leaderboard.length,
      });
    } catch (error) {
      console.error('Error in updateLeaderboard:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update leaderboard',
        error: error.message,
      });
    }
  }
}

module.exports = new LeaderboardController();
