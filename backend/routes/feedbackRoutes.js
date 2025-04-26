// const express = require('express');
// const router = express.Router();
// const feedbackController = require('../controllers/feedbackController');
// const authMiddleware = require('../utils/authMiddleware');

// // Route to submit feedback
// router.post('/submit', authMiddleware, feedbackController.submitFeedback);

// // Route to get feedback for a specific user (for admins or the user themselves)
// router.get('/:userId', authMiddleware, feedbackController.getFeedback);

// // Route to get all feedbacks (admin only)
// router.get('/', authMiddleware, feedbackController.getAllFeedback);

// module.exports = router;

// routes/feedbackRoutes.js
const express = require('express');
const router = express.Router();
const feedbackController = require('../controllers/feedbackController');
// const { protect, isAdmin } = require('../utils/authMiddleware'); // If you have auth middleware
const { authMiddleware } = require('../utils/authMiddleware');

// Submit feedback
router.post('/', authMiddleware, feedbackController.createFeedback);

// Get all feedback (admin only)
router.get('/', authMiddleware, feedbackController.getAllFeedback);

// Get feedback statistics (admin only)
router.get('/statistics', authMiddleware, feedbackController.getFeedbackStatistics);

module.exports = router;