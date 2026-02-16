const cron = require('node-cron');
const pointsService = require('../services/PointsService');
const leaderboardService = require('../services/LeaderboardService');
const { LEADERBOARD_PERIODS } = require('../config/constants');

// Reset daily points at midnight every day
cron.schedule('0 0 * * *', async () => {
  console.log('Running daily points reset...');
  try {
    await pointsService.resetDailyPoints();
  } catch (error) {
    console.error('Error in daily points reset:', error);
  }
});

// Reset weekly points at midnight every Monday
cron.schedule('0 0 * * 1', async () => {
  console.log('Running weekly points reset...');
  try {
    await pointsService.resetWeeklyPoints();
  } catch (error) {
    console.error('Error in weekly points reset:', error);
  }
});

// Update weekly leaderboard every hour
cron.schedule('0 * * * *', async () => {
  console.log('Updating weekly leaderboard...');
  try {
    await leaderboardService.updateLeaderboard(LEADERBOARD_PERIODS.WEEKLY);
  } catch (error) {
    console.error('Error updating weekly leaderboard:', error);
  }
});

// Update all-time leaderboard every 6 hours
cron.schedule('0 */6 * * *', async () => {
  console.log('Updating all-time leaderboard...');
  try {
    await leaderboardService.updateLeaderboard(LEADERBOARD_PERIODS.ALL_TIME);
  } catch (error) {
    console.error('Error updating all-time leaderboard:', error);
  }
});

console.log('Cron jobs initialized');

module.exports = {
  // Export for manual triggering if needed
  resetDailyPoints: () => pointsService.resetDailyPoints(),
  resetWeeklyPoints: () => pointsService.resetWeeklyPoints(),
  updateLeaderboard: (period) => leaderboardService.updateLeaderboard(period),
};
