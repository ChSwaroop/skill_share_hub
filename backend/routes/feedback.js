const express = require('express');
const router = express.Router();
const feedbackController = require('../controllers/feedbackController');
const authMiddleware = require('../utils/authMiddleware');

// Route to submit feedback
router.post('/submit', authMiddleware, feedbackController.submitFeedback);

// Route to get feedback for a specific user (for admins or the user themselves)
router.get('/:userId', authMiddleware, feedbackController.getFeedback);

// Route to get all feedbacks (admin only)
router.get('/', authMiddleware, feedbackController.getAllFeedback);

module.exports = router;