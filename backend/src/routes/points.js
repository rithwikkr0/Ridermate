const express = require('express');
const router = express.Router();
const pointsController = require('../controllers/PointsController');

router.get('/:userId', pointsController.getUserPoints);
router.get('/:userId/history', pointsController.getPointsHistory);
router.post('/award', pointsController.awardPoints);

module.exports = router;
