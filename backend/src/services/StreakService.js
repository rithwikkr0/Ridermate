const { db } = require('../config/firebase');

class StreakService {
  constructor() {
    this.streaksCollection = db.collection('streaks');
  }

  // Get user streak
  async getUserStreak(userId) {
    try {
      const streakDoc = await this.streaksCollection.doc(userId).get();

      if (!streakDoc.exists) {
        return {
          userId,
          currentStreak: 0,
          bestStreak: 0,
          lastRideDate: null,
        };
      }

      return streakDoc.data();
    } catch (error) {
      console.error('Error getting user streak:', error);
      throw error;
    }
  }

  // Update streak after ride
  async updateStreak(userId) {
    try {
      const streakRef = this.streaksCollection.doc(userId);
      const streakDoc = await streakRef.get();
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      if (!streakDoc.exists) {
        // First ride
        await streakRef.set({
          userId,
          currentStreak: 1,
          bestStreak: 1,
          lastRideDate: today.toISOString(),
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        });
        return { currentStreak: 1, bestStreak: 1 };
      }

      const data = streakDoc.data();
      const lastRideDate = new Date(data.lastRideDate);
      lastRideDate.setHours(0, 0, 0, 0);

      const daysDiff = Math.floor((today - lastRideDate) / (1000 * 60 * 60 * 24));

      let currentStreak = data.currentStreak || 0;
      let bestStreak = data.bestStreak || 0;

      if (daysDiff === 0) {
        // Same day, no change
        return { currentStreak, bestStreak };
      } else if (daysDiff === 1) {
        // Consecutive day
        currentStreak += 1;
        bestStreak = Math.max(bestStreak, currentStreak);
      } else {
        // Streak broken
        currentStreak = 1;
      }

      await streakRef.update({
        currentStreak,
        bestStreak,
        lastRideDate: today.toISOString(),
        updatedAt: new Date().toISOString(),
      });

      return { currentStreak, bestStreak, streakIncreased: daysDiff === 1 };
    } catch (error) {
      console.error('Error updating streak:', error);
      throw error;
    }
  }

  // Reset streak (if needed)
  async resetStreak(userId) {
    try {
      const streakRef = this.streaksCollection.doc(userId);
      await streakRef.update({
        currentStreak: 0,
        updatedAt: new Date().toISOString(),
      });
    } catch (error) {
      console.error('Error resetting streak:', error);
      throw error;
    }
  }

  // Get streak calendar data
  async getStreakCalendar(userId, year, month) {
    try {
      // This would require storing ride dates
      // For now, return a basic structure
      const streakData = await this.getUserStreak(userId);

      return {
        currentStreak: streakData.currentStreak,
        bestStreak: streakData.bestStreak,
        calendar: [], // Array of dates with rides
      };
    } catch (error) {
      console.error('Error getting streak calendar:', error);
      throw error;
    }
  }
}

module.exports = new StreakService();
