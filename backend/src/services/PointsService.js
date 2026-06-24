const { db } = require('../config/firebase');
const { POINT_VALUES } = require('../config/constants');

class PointsService {
  constructor() {
    this.pointsCollection = db.collection('points');
    this.dailyPointsCap = parseInt(process.env.DAILY_POINTS_CAP) || 500;
    this.weeklyPointsCap = parseInt(process.env.WEEKLY_POINTS_CAP) || 2000;
  }

  // Award points for an activity
  async awardPoints(userId, activityType, reason, multiplier = 1.0) {
    try {
      const basePoints = POINT_VALUES[activityType] || 0;
      const points = Math.floor(basePoints * multiplier);

      // Check daily and weekly caps
      const canAward = await this.checkPointsCap(userId, points);
      if (!canAward) {
        return {
          success: false,
          message: 'Daily or weekly points cap reached',
          points: 0,
        };
      }

      // Get or create user points document
      const userPointsRef = this.pointsCollection.doc(userId);
      const userPointsDoc = await userPointsRef.get();

      const timestamp = new Date();
      const transaction = {
        points,
        reason,
        activityType,
        multiplier,
        timestamp: timestamp.toISOString(),
      };

      if (userPointsDoc.exists) {
        const data = userPointsDoc.data();
        await userPointsRef.update({
          totalPoints: (data.totalPoints || 0) + points,
          dailyPoints: (data.dailyPoints || 0) + points,
          weeklyPoints: (data.weeklyPoints || 0) + points,
          pointHistory: [...(data.pointHistory || []), transaction],
          updatedAt: timestamp.toISOString(),
        });
      } else {
        await userPointsRef.set({
          userId,
          totalPoints: points,
          dailyPoints: points,
          weeklyPoints: points,
          pointHistory: [transaction],
          createdAt: timestamp.toISOString(),
          updatedAt: timestamp.toISOString(),
        });
      }

      return {
        success: true,
        points,
        message: `Awarded ${points} points for ${reason}`,
      };
    } catch (error) {
      console.error('Error awarding points:', error);
      throw error;
    }
  }

  // Check if user can receive more points (cap check)
  async checkPointsCap(userId, pointsToAdd) {
    const userPointsRef = this.pointsCollection.doc(userId);
    const userPointsDoc = await userPointsRef.get();

    if (!userPointsDoc.exists) {
      return true;
    }

    const data = userPointsDoc.data();
    const dailyPoints = data.dailyPoints || 0;
    const weeklyPoints = data.weeklyPoints || 0;

    if (dailyPoints + pointsToAdd > this.dailyPointsCap) {
      return false;
    }

    if (weeklyPoints + pointsToAdd > this.weeklyPointsCap) {
      return false;
    }

    return true;
  }

  // Get user points
  async getUserPoints(userId) {
    try {
      const userPointsDoc = await this.pointsCollection.doc(userId).get();

      if (!userPointsDoc.exists) {
        return {
          userId,
          totalPoints: 0,
          dailyPoints: 0,
          weeklyPoints: 0,
          pointHistory: [],
        };
      }

      return userPointsDoc.data();
    } catch (error) {
      console.error('Error getting user points:', error);
      throw error;
    }
  }

  // Get points history
  async getPointsHistory(userId, limit = 50) {
    try {
      const userPointsDoc = await this.pointsCollection.doc(userId).get();

      if (!userPointsDoc.exists) {
        return [];
      }

      const data = userPointsDoc.data();
      const history = data.pointHistory || [];

      // Return last N transactions
      return history.slice(-limit).reverse();
    } catch (error) {
      console.error('Error getting points history:', error);
      throw error;
    }
  }

  // Reset daily points (called by cron job)
  async resetDailyPoints() {
    try {
      const snapshot = await this.pointsCollection.get();
      const batch = db.batch();

      snapshot.docs.forEach((doc) => {
        batch.update(doc.ref, { dailyPoints: 0 });
      });

      await batch.commit();
      console.log('Daily points reset completed');
    } catch (error) {
      console.error('Error resetting daily points:', error);
      throw error;
    }
  }

  // Reset weekly points (called by cron job)
  async resetWeeklyPoints() {
    try {
      const snapshot = await this.pointsCollection.get();
      const batch = db.batch();

      snapshot.docs.forEach((doc) => {
        batch.update(doc.ref, { weeklyPoints: 0 });
      });

      await batch.commit();
      console.log('Weekly points reset completed');
    } catch (error) {
      console.error('Error resetting weekly points:', error);
      throw error;
    }
  }

  // Calculate multiplier based on day of week and holidays
  getPointsMultiplier() {
    const now = new Date();
    const dayOfWeek = now.getDay();

    // Weekend multiplier (Saturday = 6, Sunday = 0)
    if (dayOfWeek === 0 || dayOfWeek === 6) {
      return parseFloat(process.env.WEEKEND_MULTIPLIER) || 1.5;
    }

    // Add holiday check logic here if needed
    // For now, return base multiplier
    return 1.0;
  }
}

module.exports = new PointsService();
