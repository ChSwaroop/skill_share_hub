const express = require('express');
const router = express.Router();
const reportController = require('../controllers/reportController');
const authMiddleware = require('../utils/authMiddleware');

// Route to block a user
router.post('/block/:userId', authMiddleware, reportController.blockUser);

// Route to unblock a user
router.post('/unblock/:userId', authMiddleware, reportController.unblockUser);

// Route to report a user for inappropriate behavior
router.post('/report/:userId', authMiddleware, reportController.reportUser);

// Route to get the list of blocked users for the authenticated user
router.get('/blocked', authMiddleware, reportController.getBlockedUsers);

module.exports = router;