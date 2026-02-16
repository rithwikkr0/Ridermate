const badgeService = require('../services/BadgeService');

class BadgeController {
  // GET /api/badges/:userId
  async getUserBadges(req, res) {
    try {
      const { userId } = req.params;
      const badges = await badgeService.getUserBadges(userId);

      res.json({
        success: true,
        badges,
      });
    } catch (error) {
      console.error('Error in getUserBadges:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get user badges',
        error: error.message,
      });
    }
  }

  // GET /api/badges/all
  async getAllBadges(req, res) {
    try {
      const badges = await badgeService.getAllBadges();

      res.json({
        success: true,
        badges,
      });
    } catch (error) {
      console.error('Error in getAllBadges:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get all badges',
        error: error.message,
      });
    }
  }

  // GET /api/badges/:userId/progress
  async getBadgeProgress(req, res) {
    try {
      const { userId } = req.params;
      const { userStats } = req.body;

      if (!userStats) {
        return res.status(400).json({
          success: false,
          message: 'userStats required in request body',
        });
      }

      const progress = await badgeService.getBadgeProgress(userId, userStats);

      res.json({
        success: true,
        progress,
      });
    } catch (error) {
      console.error('Error in getBadgeProgress:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get badge progress',
        error: error.message,
      });
    }
  }

  // POST /api/badges/:userId/unlock
  async unlockBadge(req, res) {
    try {
      const { userId } = req.params;
      const { badgeId, userStats } = req.body;

      if (!badgeId || !userStats) {
        return res.status(400).json({
          success: false,
          message: 'badgeId and userStats required',
        });
      }

      const result = await badgeService.checkAndAwardBadge(userId, badgeId, userStats);

      res.json(result);
    } catch (error) {
      console.error('Error in unlockBadge:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to unlock badge',
        error: error.message,
      });
    }
  }
}

module.exports = new BadgeController();
