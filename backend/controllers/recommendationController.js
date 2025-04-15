// controllers/skillRecommendationController.js
const skillRecommendationService = require('../services/recommendationService');

/**
 * Controller for skill recommendations
 */
class SkillRecommendationController {
    /**
     * Get basic recommended skills for a user
     * @param {Object} req - Express request object
     * @param {Object} res - Express response object
     */
    async getRecommendedSkills(req, res) {
        try {
            const userId = req.user.userId; // Assuming authentication middleware sets req.user
            const limit = parseInt(req.query.limit) || 10;

            const recommendations = await skillRecommendationService.getRecommendedSkills(userId, limit);

            res.status(200).json({
                success: true,
                count: recommendations.length,
                data: recommendations
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: error.message || 'Failed to fetch recommendations',
                error: process.env.NODE_ENV === 'development' ? error : undefined
            });
        }
    }

    /**
     * Get advanced recommendations with collaborative filtering
     * @param {Object} req - Express request object
     * @param {Object} res - Express response object
     */
    async getAdvancedRecommendations(req, res) {
        try {
            const userId = req.user.userId;
            const limit = parseInt(req.query.limit) || 10;

            const recommendations = await skillRecommendationService.getAdvancedRecommendations(userId, limit);

            res.status(200).json({
                success: true,
                count: recommendations.length,
                data: recommendations
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: error.message || 'Failed to fetch advanced recommendations',
                error: process.env.NODE_ENV === 'development' ? error : undefined
            });
        }
    }

    /**
     * Get personalized recommendations with expert suggestions
     * @param {Object} req - Express request object
     * @param {Object} res - Express response object
     */
    async getPersonalizedRecommendations(req, res) {
        try {
            const userId = req.user.userId;
            const limit = parseInt(req.query.limit) || 10;

            const recommendations = await skillRecommendationService.getPersonalizedRecommendations(userId, limit);

            res.status(200).json({
                success: true,
                count: recommendations.length,
                data: recommendations
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: error.message || 'Failed to fetch personalized recommendations',
                error: process.env.NODE_ENV === 'development' ? error : undefined
            });
        }
    }
}

module.exports = new SkillRecommendationController();