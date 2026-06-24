const { db } = require('../config/firebase');
const badgeService = require('../services/BadgeService');
const achievementService = require('../services/AchievementService');

/**
 * Initialize database collections with default data
 * Run this script once to set up the database
 */
async function initializeDatabase() {
  console.log('Starting database initialization...');

  try {
    // Initialize badges
    console.log('Initializing badges...');
    await badgeService.initializeBadges();

    // Initialize achievements
    console.log('Initializing achievements...');
    await achievementService.initializeAchievements();

    // Create sample user (optional)
    console.log('Creating sample user...');
    await createSampleUser();

    console.log('Database initialization complete!');
  } catch (error) {
    console.error('Error initializing database:', error);
    throw error;
  }
}

async function createSampleUser() {
  const usersCollection = db.collection('users');
  const userId = 'demo_user';

  const userData = {
    userId,
    username: 'Demo User',
    email: 'demo@ridermate.com',
    safetyScore: 85,
    totalDistance: 234.5,
    totalRides: 15,
    friends: [],
    createdAt: new Date().toISOString(),
  };

  await usersCollection.doc(userId).set(userData);
  console.log('Sample user created:', userId);

  // Initialize points for demo user
  const pointsCollection = db.collection('points');
  await pointsCollection.doc(userId).set({
    userId,
    totalPoints: 150,
    dailyPoints: 25,
    weeklyPoints: 75,
    pointHistory: [
      {
        points: 10,
        reason: 'Completed ride',
        activityType: 'COMPLETE_RIDE',
        multiplier: 1.0,
        timestamp: new Date().toISOString(),
      },
      {
        points: 15,
        reason: 'Safe riding',
        activityType: 'SAFE_RIDE',
        multiplier: 1.0,
        timestamp: new Date(Date.now() - 86400000).toISOString(),
      },
    ],
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  });

  // Initialize streak for demo user
  const streaksCollection = db.collection('streaks');
  await streaksCollection.doc(userId).set({
    userId,
    currentStreak: 5,
    bestStreak: 12,
    lastRideDate: new Date().toISOString(),
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  });

  console.log('Sample user data initialized');
}

// Run if executed directly
if (require.main === module) {
  const { initializeFirebase } = require('../config/firebase');
  initializeFirebase();

  initializeDatabase()
    .then(() => {
      console.log('Success!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('Failed:', error);
      process.exit(1);
    });
}

module.exports = { initializeDatabase };
