// routes/skillRecommendationRoutes.js
const express = require('express');
const router = express.Router();
const skillRecommendationController = require('../controllers/recommendationController');
const authMiddleware = require('../middleware/authMiddleware'); // Assuming you have auth middleware

// Apply authentication middleware to all routes
router.use(authMiddleware);

// Get basic skill recommendations
router.get('/', skillRecommendationController.getRecommendedSkills);

// Get advanced recommendations
router.get('/advanced', skillRecommendationController.getAdvancedRecommendations);

// Get personalized recommendations with expert suggestions
router.get('/personalized', skillRecommendationController.getPersonalizedRecommendations);

module.exports = router;