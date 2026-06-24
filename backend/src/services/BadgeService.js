const { db } = require('../config/firebase');
const { BADGE_TYPES } = require('../config/constants');

class BadgeService {
  constructor() {
    this.badgesCollection = db.collection('badges');
    this.userBadgesCollection = db.collection('user_badges');
  }

  // Initialize all badges in database
  async initializeBadges() {
    try {
      const batch = db.batch();

      Object.values(BADGE_TYPES).forEach((badge) => {
        const badgeRef = this.badgesCollection.doc(badge.id);
        batch.set(badgeRef, {
          ...badge,
          unlockedBy: [],
          createdAt: new Date().toISOString(),
        });
      });

      await batch.commit();
      console.log('Badges initialized successfully');
    } catch (error) {
      console.error('Error initializing badges:', error);
      throw error;
    }
  }

  // Get all available badges
  async getAllBadges() {
    try {
      const snapshot = await this.badgesCollection.get();
      return snapshot.docs.map((doc) => doc.data());
    } catch (error) {
      console.error('Error getting all badges:', error);
      throw error;
    }
  }

  // Get user's badges
  async getUserBadges(userId) {
    try {
      const userBadgesDoc = await this.userBadgesCollection.doc(userId).get();

      if (!userBadgesDoc.exists) {
        return [];
      }

      const data = userBadgesDoc.data();
      return data.badges || [];
    } catch (error) {
      console.error('Error getting user badges:', error);
      throw error;
    }
  }

  // Check and award badge to user
  async checkAndAwardBadge(userId, badgeId, userStats) {
    try {
      const badge = BADGE_TYPES[badgeId.toUpperCase()];
      if (!badge) {
        throw new Error('Badge not found');
      }

      // Check if user already has this badge
      const userBadges = await this.getUserBadges(userId);
      const alreadyHas = userBadges.some((b) => b.badgeId === badge.id);

      if (alreadyHas) {
        return {
          success: false,
          message: 'User already has this badge',
        };
      }

      // Check criteria
      const meetsRequirements = this.checkBadgeCriteria(badge, userStats);

      if (!meetsRequirements) {
        return {
          success: false,
          message: 'User does not meet badge requirements',
        };
      }

      // Award badge
      const userBadgesRef = this.userBadgesCollection.doc(userId);
      const userBadgesDoc = await userBadgesRef.get();

      const newBadge = {
        badgeId: badge.id,
        name: badge.name,
        icon: badge.icon,
        unlockedAt: new Date().toISOString(),
      };

      if (userBadgesDoc.exists) {
        const data = userBadgesDoc.data();
        await userBadgesRef.update({
          badges: [...(data.badges || []), newBadge],
          updatedAt: new Date().toISOString(),
        });
      } else {
        await userBadgesRef.set({
          userId,
          badges: [newBadge],
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        });
      }

      // Update badge's unlockedBy list
      const badgeRef = this.badgesCollection.doc(badge.id);
      const badgeDoc = await badgeRef.get();
      if (badgeDoc.exists) {
        const badgeData = badgeDoc.data();
        await badgeRef.update({
          unlockedBy: [...(badgeData.unlockedBy || []), userId],
        });
      }

      return {
        success: true,
        badge: newBadge,
        message: `Badge "${badge.name}" unlocked!`,
      };
    } catch (error) {
      console.error('Error awarding badge:', error);
      throw error;
    }
  }

  // Check if user meets badge criteria
  checkBadgeCriteria(badge, userStats) {
    const { criteria } = badge;

    // Safe Rider
    if (criteria.rides_with_zero_overspeeds) {
      return (userStats.ridesWithZeroOverspeeds || 0) >= criteria.rides_with_zero_overspeeds;
    }

    // Long Distance
    if (criteria.total_distance_km) {
      return (userStats.totalDistanceKm || 0) >= criteria.total_distance_km;
    }

    // Weekly Warrior
    if (criteria.consecutive_days) {
      return (userStats.currentStreak || 0) >= criteria.consecutive_days;
    }

    // AI Pro
    if (criteria.ai_interactions) {
      return (userStats.aiInteractions || 0) >= criteria.ai_interactions;
    }

    // Social Butterfly
    if (criteria.friends_count) {
      return (userStats.friendsCount || 0) >= criteria.friends_count;
    }

    // Memory Keeper
    if (criteria.memories_count) {
      return (userStats.memoriesCount || 0) >= criteria.memories_count;
    }

    // Speed Master
    if (criteria.avg_speed_kmh && criteria.min_rides) {
      return (
        (userStats.avgSpeedKmh || 0) >= criteria.avg_speed_kmh &&
        (userStats.totalRides || 0) >= criteria.min_rides
      );
    }

    // Consistency King
    if (criteria.streak_days) {
      return (userStats.currentStreak || 0) >= criteria.streak_days;
    }

    // Night Rider
    if (criteria.night_rides) {
      return (userStats.nightRides || 0) >= criteria.night_rides;
    }

    // Early Bird
    if (criteria.early_rides) {
      return (userStats.earlyRides || 0) >= criteria.early_rides;
    }

    return false;
  }

  // Get badge progress for user
  async getBadgeProgress(userId, userStats) {
    try {
      const allBadges = Object.values(BADGE_TYPES);
      const userBadges = await this.getUserBadges(userId);
      const unlockedBadgeIds = userBadges.map((b) => b.badgeId);

      return allBadges.map((badge) => {
        const unlocked = unlockedBadgeIds.includes(badge.id);
        const progress = this.calculateBadgeProgress(badge, userStats);

        return {
          ...badge,
          unlocked,
          progress,
          unlockedAt: unlocked
            ? userBadges.find((b) => b.badgeId === badge.id)?.unlockedAt
            : null,
        };
      });
    } catch (error) {
      console.error('Error getting badge progress:', error);
      throw error;
    }
  }

  // Calculate progress towards a badge
  calculateBadgeProgress(badge, userStats) {
    const { criteria } = badge;

    if (criteria.rides_with_zero_overspeeds) {
      const current = userStats.ridesWithZeroOverspeeds || 0;
      return Math.min(100, (current / criteria.rides_with_zero_overspeeds) * 100);
    }

    if (criteria.total_distance_km) {
      const current = userStats.totalDistanceKm || 0;
      return Math.min(100, (current / criteria.total_distance_km) * 100);
    }

    if (criteria.consecutive_days || criteria.streak_days) {
      const target = criteria.consecutive_days || criteria.streak_days;
      const current = userStats.currentStreak || 0;
      return Math.min(100, (current / target) * 100);
    }

    if (criteria.ai_interactions) {
      const current = userStats.aiInteractions || 0;
      return Math.min(100, (current / criteria.ai_interactions) * 100);
    }

    if (criteria.friends_count) {
      const current = userStats.friendsCount || 0;
      return Math.min(100, (current / criteria.friends_count) * 100);
    }

    if (criteria.memories_count) {
      const current = userStats.memoriesCount || 0;
      return Math.min(100, (current / criteria.memories_count) * 100);
    }

    if (criteria.night_rides) {
      const current = userStats.nightRides || 0;
      return Math.min(100, (current / criteria.night_rides) * 100);
    }

    if (criteria.early_rides) {
      const current = userStats.earlyRides || 0;
      return Math.min(100, (current / criteria.early_rides) * 100);
    }

    return 0;
  }
}

module.exports = new BadgeService();
