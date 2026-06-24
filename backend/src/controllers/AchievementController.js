const achievementService = require('../services/AchievementService');

class AchievementController {
  // GET /api/achievements/:userId
  async getUserAchievements(req, res) {
    try {
      const { userId } = req.params;
      const achievements = await achievementService.getUserAchievements(userId);

      res.json({
        success: true,
        achievements,
      });
    } catch (error) {
      console.error('Error in getUserAchievements:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get user achievements',
        error: error.message,
      });
    }
  }

  // GET /api/achievements/all
  async getAllAchievements(req, res) {
    try {
      const achievements = await achievementService.getAllAchievements();

      res.json({
        success: true,
        achievements,
      });
    } catch (error) {
      console.error('Error in getAllAchievements:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get all achievements',
        error: error.message,
      });
    }
  }

  // GET /api/achievements/:userId/progress
  async getAchievementProgress(req, res) {
    try {
      const { userId } = req.params;
      const { userStats } = req.body;

      if (!userStats) {
        return res.status(400).json({
          success: false,
          message: 'userStats required in request body',
        });
      }

      const progress = await achievementService.getAchievementProgress(userId, userStats);

      res.json({
        success: true,
        progress,
      });
    } catch (error) {
      console.error('Error in getAchievementProgress:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get achievement progress',
        error: error.message,
      });
    }
  }

  // POST /api/achievements/:userId/unlock
  async unlockAchievement(req, res) {
    try {
      const { userId } = req.params;
      const { achievementId, userStats } = req.body;

      if (!achievementId || !userStats) {
        return res.status(400).json({
          success: false,
          message: 'achievementId and userStats required',
        });
      }

      const result = await achievementService.checkAndAwardAchievement(
        userId,
        achievementId,
        userStats
      );

      res.json(result);
    } catch (error) {
      console.error('Error in unlockAchievement:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to unlock achievement',
        error: error.message,
      });
    }
  }
}

module.exports = new AchievementController();
