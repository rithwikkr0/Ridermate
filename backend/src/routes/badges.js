const express = require('express');
const router = express.Router();
const badgeController = require('../controllers/BadgeController');

router.get('/all', badgeController.getAllBadges);
router.get('/:userId', badgeController.getUserBadges);
router.get('/:userId/progress', badgeController.getBadgeProgress);
router.post('/:userId/unlock', badgeController.unlockBadge);

module.exports = router;
