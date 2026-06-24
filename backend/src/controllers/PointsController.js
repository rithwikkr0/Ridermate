const pointsService = require('../services/PointsService');

class PointsController {
  // GET /api/points/:userId
  async getUserPoints(req, res) {
    try {
      const { userId } = req.params;
      const points = await pointsService.getUserPoints(userId);

      res.json({
        success: true,
        ...points,
      });
    } catch (error) {
      console.error('Error in getUserPoints:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get user points',
        error: error.message,
      });
    }
  }

  // GET /api/points/:userId/history
  async getPointsHistory(req, res) {
    try {
      const { userId } = req.params;
      const { limit = 50 } = req.query;

      const history = await pointsService.getPointsHistory(userId, parseInt(limit));

      res.json({
        success: true,
        history,
      });
    } catch (error) {
      console.error('Error in getPointsHistory:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get points history',
        error: error.message,
      });
    }
  }

  // POST /api/points/award
  async awardPoints(req, res) {
    try {
      const { userId, activityType, reason } = req.body;

      if (!userId || !activityType || !reason) {
        return res.status(400).json({
          success: false,
          message: 'Missing required fields: userId, activityType, reason',
        });
      }

      const multiplier = pointsService.getPointsMultiplier();
      const result = await pointsService.awardPoints(userId, activityType, reason, multiplier);

      res.json(result);
    } catch (error) {
      console.error('Error in awardPoints:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to award points',
        error: error.message,
      });
    }
  }
}

module.exports = new PointsController();
