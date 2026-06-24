const express = require('express');
const router = express.Router();
const achievementController = require('../controllers/AchievementController');

router.get('/all', achievementController.getAllAchievements);
router.get('/:userId', achievementController.getUserAchievements);
router.get('/:userId/progress', achievementController.getAchievementProgress);
router.post('/:userId/unlock', achievementController.unlockAchievement);

module.exports = router;
