// routes/userStats.js
const express = require('express');
const router = express.Router();
const userStatsController = require('../controllers/userStatsController');
const { authMiddleware } = require('../utils/authMiddleware');

// Protect all routes
router.use(authMiddleware);

// Get message count for past 7 days
router.get('/messages/:userId', userStatsController.getMessageStats);

// Get call durations for past 7 days
// Optional query param: ?type=audio or ?type=video
router.get('/calls/:userId', userStatsController.getCallStats);

// Get comprehensive user activity stats (messages and calls)
router.get('/activity/:userId', userStatsController.getUserActivityStats);

module.exports = router;