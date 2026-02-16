const { db } = require('../config/firebase');
const { ACHIEVEMENTS, ACHIEVEMENT_TYPES } = require('../config/constants');

class AchievementService {
  constructor() {
    this.achievementsCollection = db.collection('achievements');
    this.userAchievementsCollection = db.collection('user_achievements');
  }

  // Initialize all achievements in database
  async initializeAchievements() {
    try {
      const batch = db.batch();

      Object.values(ACHIEVEMENTS).forEach((achievement) => {
        const achievementRef = this.achievementsCollection.doc(achievement.id);
        batch.set(achievementRef, {
          ...achievement,
          unlockedBy: [],
          createdAt: new Date().toISOString(),
        });
      });

      await batch.commit();
      console.log('Achievements initialized successfully');
    } catch (error) {
      console.error('Error initializing achievements:', error);
      throw error;
    }
  }

  // Get all available achievements
  async getAllAchievements() {
    try {
      const snapshot = await this.achievementsCollection.get();
      return snapshot.docs.map((doc) => doc.data());
    } catch (error) {
      console.error('Error getting all achievements:', error);
      throw error;
    }
  }

  // Get user's achievements
  async getUserAchievements(userId) {
    try {
      const userAchievementsDoc = await this.userAchievementsCollection.doc(userId).get();

      if (!userAchievementsDoc.exists) {
        return [];
      }

      const data = userAchievementsDoc.data();
      return data.achievements || [];
    } catch (error) {
      console.error('Error getting user achievements:', error);
      throw error;
    }
  }

  // Check and award achievement
  async checkAndAwardAchievement(userId, achievementId, userStats) {
    try {
      const achievement = ACHIEVEMENTS[achievementId.toUpperCase()];
      if (!achievement) {
        throw new Error('Achievement not found');
      }

      // Check if user already has this achievement
      const userAchievements = await this.getUserAchievements(userId);
      const alreadyHas = userAchievements.some((a) => a.achievementId === achievement.id);

      if (alreadyHas) {
        return {
          success: false,
          message: 'User already has this achievement',
        };
      }

      // Check criteria
      const meetsRequirements = this.checkAchievementCriteria(achievement, userStats);

      if (!meetsRequirements) {
        return {
          success: false,
          message: 'User does not meet achievement requirements',
        };
      }

      // Award achievement
      const userAchievementsRef = this.userAchievementsCollection.doc(userId);
      const userAchievementsDoc = await userAchievementsRef.get();

      const newAchievement = {
        achievementId: achievement.id,
        name: achievement.name,
        type: achievement.type,
        icon: achievement.icon,
        unlockedAt: new Date().toISOString(),
      };

      if (userAchievementsDoc.exists) {
        const data = userAchievementsDoc.data();
        await userAchievementsRef.update({
          achievements: [...(data.achievements || []), newAchievement],
          updatedAt: new Date().toISOString(),
        });
      } else {
        await userAchievementsRef.set({
          userId,
          achievements: [newAchievement],
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        });
      }

      // Update achievement's unlockedBy list
      const achievementRef = this.achievementsCollection.doc(achievement.id);
      const achievementDoc = await achievementRef.get();
      if (achievementDoc.exists) {
        const achievementData = achievementDoc.data();
        await achievementRef.update({
          unlockedBy: [...(achievementData.unlockedBy || []), userId],
        });
      }

      return {
        success: true,
        achievement: newAchievement,
        message: `Achievement "${achievement.name}" unlocked!`,
      };
    } catch (error) {
      console.error('Error awarding achievement:', error);
      throw error;
    }
  }

  // Check if user meets achievement criteria
  checkAchievementCriteria(achievement, userStats) {
    switch (achievement.type) {
      case ACHIEVEMENT_TYPES.MILESTONE:
        if (achievement.id.startsWith('rides_')) {
          return (userStats.totalRides || 0) >= achievement.milestone;
        }
        if (achievement.id.startsWith('distance_')) {
          return (userStats.totalDistanceKm || 0) >= achievement.milestone;
        }
        break;

      case ACHIEVEMENT_TYPES.SKILL:
        if (achievement.id === 'perfect_ride') {
          return userStats.hasPerfectRide || false;
        }
        if (achievement.id === 'best_safety_score') {
          return (userStats.safetyScore || 0) >= 95;
        }
        break;

      case ACHIEVEMENT_TYPES.SOCIAL:
        if (achievement.id === 'first_friend') {
          return (userStats.friendsCount || 0) >= 1;
        }
        if (achievement.id === 'created_ride_room') {
          return userStats.hasCreatedRideRoom || false;
        }
        break;

      case ACHIEVEMENT_TYPES.TIME_BASED:
        if (achievement.id.startsWith('streak_')) {
          const days = parseInt(achievement.id.split('_')[1]);
          const current = userStats.currentStreak || 0;
          return Math.min(100, (current / days) * 100);
        }
        if (achievement.id === 'one_year_member') {
          if (!userStats.accountCreatedAt) {
            return 0;
          }
          const accountAge = Date.now() - new Date(userStats.accountCreatedAt).getTime();
          const oneYear = 365 * 24 * 60 * 60 * 1000;
          return accountAge >= oneYear;
        }
        break;
    }

    return false;
  }

  // Get achievement progress
  async getAchievementProgress(userId, userStats) {
    try {
      const allAchievements = Object.values(ACHIEVEMENTS);
      const userAchievements = await this.getUserAchievements(userId);
      const unlockedAchievementIds = userAchievements.map((a) => a.achievementId);

      return allAchievements.map((achievement) => {
        const unlocked = unlockedAchievementIds.includes(achievement.id);
        const progress = this.calculateAchievementProgress(achievement, userStats);

        return {
          ...achievement,
          unlocked,
          progress,
          unlockedAt: unlocked
            ? userAchievements.find((a) => a.achievementId === achievement.id)?.unlockedAt
            : null,
        };
      });
    } catch (error) {
      console.error('Error getting achievement progress:', error);
      throw error;
    }
  }

  // Calculate progress towards an achievement
  calculateAchievementProgress(achievement, userStats) {
    switch (achievement.type) {
      case ACHIEVEMENT_TYPES.MILESTONE:
        if (achievement.id.startsWith('rides_')) {
          const current = userStats.totalRides || 0;
          return Math.min(100, (current / achievement.milestone) * 100);
        }
        if (achievement.id.startsWith('distance_')) {
          const current = userStats.totalDistanceKm || 0;
          return Math.min(100, (current / achievement.milestone) * 100);
        }
        break;

      case ACHIEVEMENT_TYPES.SKILL:
        if (achievement.id === 'perfect_ride') {
          return userStats.hasPerfectRide ? 100 : 0;
        }
        if (achievement.id === 'best_safety_score') {
          const current = userStats.safetyScore || 0;
          return Math.min(100, (current / 95) * 100);
        }
        break;

      case ACHIEVEMENT_TYPES.SOCIAL:
        if (achievement.id === 'first_friend') {
          return (userStats.friendsCount || 0) >= 1 ? 100 : 0;
        }
        if (achievement.id === 'created_ride_room') {
          return userStats.hasCreatedRideRoom ? 100 : 0;
        }
        break;

      case ACHIEVEMENT_TYPES.TIME_BASED:
        if (achievement.id.startsWith('streak_')) {
          const days = parseInt(achievement.id.split('_')[1]);
          const current = userStats.currentStreak || 0;
          return Math.min(100, (current / days) * 100);
        }
        if (achievement.id === 'one_year_member') {
          if (!userStats.accountCreatedAt) {
            return 0;
          }
          const accountAge = Date.now() - new Date(userStats.accountCreatedAt).getTime();
          const oneYear = 365 * 24 * 60 * 60 * 1000;
          return Math.min(100, (accountAge / oneYear) * 100);
        }
        break;
    }

    return 0;
  }
}

module.exports = new AchievementService();
