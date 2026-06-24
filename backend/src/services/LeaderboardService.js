const { db } = require('../config/firebase');
const { LEADERBOARD_PERIODS } = require('../config/constants');

class LeaderboardService {
  constructor() {
    this.leaderboardCollection = db.collection('leaderboard');
    this.pointsCollection = db.collection('points');
    this.usersCollection = db.collection('users');
  }

  // Calculate and update leaderboard
  async updateLeaderboard(period = LEADERBOARD_PERIODS.ALL_TIME) {
    try {
      // Get all users with points
      const pointsSnapshot = await this.pointsCollection.get();
      const leaderboardData = [];

      for (const doc of pointsSnapshot.docs) {
        const pointsData = doc.data();
        const userId = doc.id;

        // Get user info
        const userDoc = await this.usersCollection.doc(userId).get();
        const userData = userDoc.exists ? userDoc.data() : {};

        let points = 0;
        if (period === LEADERBOARD_PERIODS.WEEKLY) {
          points = pointsData.weeklyPoints || 0;
        } else if (period === LEADERBOARD_PERIODS.MONTHLY) {
          points = pointsData.monthlyPoints || 0;
        } else {
          points = pointsData.totalPoints || 0;
        }

        leaderboardData.push({
          userId,
          username: userData.username || 'User',
          points,
          safetyScore: userData.safetyScore || 0,
          totalDistance: userData.totalDistance || 0,
          avatarUrl: userData.avatarUrl || '',
        });
      }

      // Sort by points
      leaderboardData.sort((a, b) => b.points - a.points);

      // Assign ranks
      leaderboardData.forEach((entry, index) => {
        entry.rank = index + 1;
      });

      // Save to leaderboard collection
      const batch = db.batch();
      const leaderboardRef = this.leaderboardCollection.doc(period);

      await leaderboardRef.set({
        period,
        entries: leaderboardData,
        updatedAt: new Date().toISOString(),
      });

      console.log(`Leaderboard updated for period: ${period}`);
      return leaderboardData;
    } catch (error) {
      console.error('Error updating leaderboard:', error);
      throw error;
    }
  }

  // Get global leaderboard
  async getGlobalLeaderboard(period = LEADERBOARD_PERIODS.ALL_TIME, limit = 100) {
    try {
      const leaderboardDoc = await this.leaderboardCollection.doc(period).get();

      if (!leaderboardDoc.exists) {
        // Generate it if it doesn't exist
        return await this.updateLeaderboard(period);
      }

      const data = leaderboardDoc.data();
      return data.entries.slice(0, limit);
    } catch (error) {
      console.error('Error getting global leaderboard:', error);
      throw error;
    }
  }

  // Get friends leaderboard
  async getFriendsLeaderboard(userId, period = LEADERBOARD_PERIODS.ALL_TIME) {
    try {
      // Get user's friends
      const userDoc = await this.usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        return [];
      }

      const userData = userDoc.data();
      const friendIds = userData.friends || [];

      // Get global leaderboard
      const globalLeaderboard = await this.getGlobalLeaderboard(period);

      // Filter to only friends + current user
      const friendsLeaderboard = globalLeaderboard.filter(
        (entry) => entry.userId === userId || friendIds.includes(entry.userId)
      );

      // Re-rank
      friendsLeaderboard.forEach((entry, index) => {
        entry.friendRank = index + 1;
      });

      return friendsLeaderboard;
    } catch (error) {
      console.error('Error getting friends leaderboard:', error);
      throw error;
    }
  }

  // Get leaderboard by safety score
  async getSafetyLeaderboard(limit = 100) {
    try {
      const usersSnapshot = await this.usersCollection
        .orderBy('safetyScore', 'desc')
        .limit(limit)
        .get();

      return usersSnapshot.docs.map((doc, index) => {
        const data = doc.data();
        return {
          userId: doc.id,
          username: data.username || 'User',
          safetyScore: data.safetyScore || 0,
          rank: index + 1,
        };
      });
    } catch (error) {
      console.error('Error getting safety leaderboard:', error);
      throw error;
    }
  }

  // Get leaderboard by distance
  async getDistanceLeaderboard(limit = 100) {
    try {
      const usersSnapshot = await this.usersCollection
        .orderBy('totalDistance', 'desc')
        .limit(limit)
        .get();

      return usersSnapshot.docs.map((doc, index) => {
        const data = doc.data();
        return {
          userId: doc.id,
          username: data.username || 'User',
          totalDistance: data.totalDistance || 0,
          rank: index + 1,
        };
      });
    } catch (error) {
      console.error('Error getting distance leaderboard:', error);
      throw error;
    }
  }

  // Get user rank
  async getUserRank(userId, period = LEADERBOARD_PERIODS.ALL_TIME) {
    try {
      const leaderboard = await this.getGlobalLeaderboard(period, 10000);
      const userEntry = leaderboard.find((entry) => entry.userId === userId);

      if (!userEntry) {
        return {
          rank: null,
          points: 0,
          totalUsers: leaderboard.length,
        };
      }

      // Calculate rank change (comparing to previous period)
      // For simplicity, we'll set it to 0 for now
      const rankChange = 0;

      return {
        rank: userEntry.rank,
        points: userEntry.points,
        totalUsers: leaderboard.length,
        rankChange,
      };
    } catch (error) {
      console.error('Error getting user rank:', error);
      throw error;
    }
  }

  // Compare user with another user
  async compareUsers(userId1, userId2, period = LEADERBOARD_PERIODS.ALL_TIME) {
    try {
      const leaderboard = await this.getGlobalLeaderboard(period, 10000);

      const user1Entry = leaderboard.find((entry) => entry.userId === userId1);
      const user2Entry = leaderboard.find((entry) => entry.userId === userId2);

      return {
        user1: user1Entry || null,
        user2: user2Entry || null,
        pointsDifference: (user1Entry?.points || 0) - (user2Entry?.points || 0),
        rankDifference: (user2Entry?.rank || 0) - (user1Entry?.rank || 0),
      };
    } catch (error) {
      console.error('Error comparing users:', error);
      throw error;
    }
  }
}

module.exports = new LeaderboardService();
