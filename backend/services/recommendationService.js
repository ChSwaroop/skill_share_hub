// skillRecommendationService.js
const { User, Skill, Analytics } = require('../models/user');
const mongoose = require('mongoose');

/**
 * Service to provide skill recommendations based on user connections and similarities
 */
class SkillRecommendationService {

    /**
     * Get skills recommended for a specific user
     * @param {string} userId - The ID of the user to get recommendations for
     * @param {number} limit - Maximum number of recommendations to return
     * @returns {Promise<Array>} Array of recommended skill objects
     */
    async getRecommendedSkills(userId, limit = 10) {
        try {
            // Validate userId
            if (!mongoose.Types.ObjectId.isValid(userId)) {
                throw new Error('Invalid user ID');
            }

            // Get current user with their skills
            const user = await User.findById(userId)
                .populate('skills')
                .populate('connections')
                .lean();

            if (!user) {
                throw new Error('User not found');
            }

            // Get all of the user's connections with their skills
            const connections = await User.find({
                _id: { $in: user.connections }
            }).populate('skills').lean();

            // Extract the user's existing skill IDs
            const userSkillIds = user.skills.map(skill => skill._id.toString());

            // Build a map of potential skills from connections with their frequency
            const skillFrequencyMap = {};

            // Process each connection's skills
            connections.forEach(connection => {
                connection.skills.forEach(skill => {
                    const skillId = skill._id.toString();

                    // Only consider skills the user doesn't already have
                    if (!userSkillIds.includes(skillId)) {
                        if (!skillFrequencyMap[skillId]) {
                            skillFrequencyMap[skillId] = {
                                count: 1,
                                skill: skill
                            };
                        } else {
                            skillFrequencyMap[skillId].count += 1;
                        }
                    }
                });
            });

            // Convert the map to an array and sort by frequency
            const recommendedSkills = Object.values(skillFrequencyMap)
                .sort((a, b) => b.count - a.count)
                .slice(0, limit)
                .map(item => ({
                    ...item.skill,
                    recommendationScore: item.count,
                    recommendationReason: `${item.count} of your connections have this skill`
                }));

            return recommendedSkills;
        } catch (error) {
            console.error('Error in getRecommendedSkills:', error);
            throw error;
        }
    }

    /**
     * Get more advanced recommendations using collaborative filtering techniques
     * @param {string} userId - The ID of the user to get recommendations for
     * @param {number} limit - Maximum number of recommendations to return
     * @returns {Promise<Array>} Array of recommended skill objects with scores
     */
    async getAdvancedRecommendations(userId, limit = 10) {
        try {
            // Get current user
            const user = await User.findById(userId)
                .populate('skills')
                .lean();

            if (!user) {
                throw new Error('User not found');
            }

            // Extract the user's existing skill IDs
            const userSkillIds = user.skills.map(skill => skill._id.toString());

            // Find users with at least one skill in common with the current user
            // This helps find users with similar interests
            const similarUsers = await User.find({
                _id: { $ne: userId }, // Not the current user
                skills: { $in: user.skills.map(s => s._id) } // Has at least one skill in common
            }).populate('skills').lean();

            // Calculate similarity scores and potential skills
            const skillScores = {};
            const similarityScores = {};

            for (const similarUser of similarUsers) {
                const similarUserSkillIds = similarUser.skills.map(s => s._id.toString());

                // Calculate Jaccard similarity: intersection / union
                const intersection = userSkillIds.filter(id => similarUserSkillIds.includes(id)).length;
                const union = new Set([...userSkillIds, ...similarUserSkillIds]).size;
                const similarity = intersection / union;

                similarityScores[similarUser._id.toString()] = similarity;

                // Only consider users with meaningful similarity
                if (similarity > 0.1) {
                    // For each skill the similar user has that the current user doesn't
                    similarUser.skills.forEach(skill => {
                        const skillId = skill._id.toString();

                        if (!userSkillIds.includes(skillId)) {
                            if (!skillScores[skillId]) {
                                skillScores[skillId] = {
                                    score: similarity,
                                    skill: skill,
                                    userCount: 1
                                };
                            } else {
                                skillScores[skillId].score += similarity;
                                skillScores[skillId].userCount += 1;
                            }
                        }
                    });
                }
            }

            // Consider skill categories from user's existing skills for content-based recommendations
            const userSkillCategories = user.skills
                .map(skill => skill.category)
                .filter(Boolean); // Filter out undefined categories

            // Get all skills that the user doesn't have but are in categories they're interested in
            if (userSkillCategories.length > 0) {
                const categoryBasedSkills = await Skill.find({
                    _id: { $nin: userSkillIds },
                    category: { $in: userSkillCategories }
                }).lean();

                // Add content-based recommendations with a base score
                categoryBasedSkills.forEach(skill => {
                    const skillId = skill._id.toString();

                    if (!skillScores[skillId]) {
                        skillScores[skillId] = {
                            score: 0.3, // Base score for category match
                            skill: skill,
                            userCount: 0,
                            categoryMatch: true
                        };
                    } else if (!skillScores[skillId].categoryMatch) {
                        // Boost score for skills that match both collaborative and content filtering
                        skillScores[skillId].score += 0.3;
                        skillScores[skillId].categoryMatch = true;
                    }
                });
            }

            // Get popular skills as fallback recommendations
            const popularSkills = await Skill.aggregate([
                { $match: { _id: { $nin: userSkillIds.map(id => new mongoose.Types.ObjectId(id)) } } },
                {
                    $lookup: {
                        from: 'users',
                        localField: '_id',
                        foreignField: 'skills',
                        as: 'users'
                    }
                },
                {
                    $project: {
                        name: 1,
                        category: 1,
                        description: 1,
                        popularity: { $size: '$users' }
                    }
                },
                { $sort: { popularity: -1 } },
                { $limit: 20 }
            ]);

            // Add popular skills with a lower base score
            popularSkills.forEach(skill => {
                const skillId = skill._id.toString();

                if (!skillScores[skillId]) {
                    skillScores[skillId] = {
                        score: 0.1 + (skill.popularity / 100), // Base score plus popularity factor
                        skill: {
                            _id: skill._id,
                            name: skill.name,
                            category: skill.category,
                            description: skill.description,
                        },
                        userCount: skill.popularity,
                        popularityBased: true
                    };
                }
            });

            // Convert to array, sort by score, and take top recommendations
            const recommendedSkills = Object.values(skillScores)
                .sort((a, b) => b.score - a.score)
                .slice(0, limit)
                .map(item => {
                    // Create recommendation reason based on the recommendation source
                    let reason = '';
                    if (item.userCount > 0) {
                        reason = `${item.userCount} connection${item.userCount > 1 ? 's' : ''} with similar interests have this skill`;
                    }
                    if (item.categoryMatch) {
                        reason = reason ? `${reason} and matches your interests` : 'Matches your interests';
                    }
                    if (item.popularityBased && !reason) {
                        reason = 'Popular skill in our community';
                    }

                    return {
                        ...item.skill,
                        recommendationScore: parseFloat(item.score.toFixed(2)),
                        recommendationReason: reason
                    };
                });

            return recommendedSkills;
        } catch (error) {
            console.error('Error in getAdvancedRecommendations:', error);
            throw error;
        }
    }

    /**
 * Get personalized skill recommendations including analytics and connection data
 * @param {string} userId - The ID of the user to get recommendations for
 * @param {number} limit - Maximum number of recommendations to return 
 * @returns {Promise<Array>} Array of recommended skills with detailed metadata
 */
    async getPersonalizedRecommendations(userId, limit = 10) {
        try {
            // Get basic recommendations first
            const basicRecommendations = await this.getAdvancedRecommendations(userId, limit * 2);

            // Get user's analytics data if available
            const userAnalytics = await Analytics.findOne({ userId }).lean();

            // Find users who have these recommended skills
            const skillIds = basicRecommendations.map(rec => rec._id);
            const skillExperts = await User.find({
                skills: { $in: skillIds },
                _id: { $ne: userId }
            }).select('_id username firstName lastName skills profilePicture').lean();

            // 1. Collect all unique skill IDs from experts
            const allExpertSkillIds = new Set();
            skillExperts.forEach(expert => {
                expert.skills.forEach(skillId => allExpertSkillIds.add(skillId.toString()));
            });

            // 2. Fetch skill documents for those IDs
            const allSkills = await Skill.find({
                _id: { $in: Array.from(allExpertSkillIds) }
            }).select('_id name').lean();

            // 3. Create a mapping of skillId -> skill name
            const skillIdToNameMap = {};
            allSkills.forEach(skill => {
                skillIdToNameMap[skill._id.toString()] = skill.name;
            });

            // 4. Replace skill IDs in expert.skills with full skill objects
            skillExperts.forEach(expert => {
                expert.skills = expert.skills.map(skillId => ({
                    _id: skillId,
                    name: skillIdToNameMap[skillId.toString()] || 'Unknown'
                }));
            });

            // Create a map of skill IDs to users who have that skill
            const skillToExpertsMap = {};
            skillExperts.forEach(expert => {
                expert.skills.forEach(skill => {
                    const skillIdStr = skill._id.toString();
                    if (!skillToExpertsMap[skillIdStr]) {
                        skillToExpertsMap[skillIdStr] = [];
                    }
                    skillToExpertsMap[skillIdStr].push(expert);
                });
            });

            // Enhance recommendations with additional data
            const enhancedRecommendations = basicRecommendations.map(rec => {
                const skillId = rec._id.toString();

                // Check if user has any progress in this skill from analytics
                let progressData = null;
                if (userAnalytics && userAnalytics.progressTracking &&
                    userAnalytics.progressTracking.skillName === rec.name) {
                    progressData = {
                        hoursSpent: userAnalytics.progressTracking.hoursSpent,
                        progressPercentage: userAnalytics.progressTracking.progressPercentage
                    };
                }

                // Add experts who have this skill
                const experts = skillToExpertsMap[skillId] || [];

                return {
                    ...rec,
                    progress: progressData,
                    experts: experts.slice(0, 3), // Limit to top 3 experts
                    totalExperts: experts.length
                };
            });

            // Apply final ranking (could consider progress, recency, etc.)
            return enhancedRecommendations
                .sort((a, b) => {
                    const aHasExperts = a.experts && a.experts.length > 0 ? 1 : 0;
                    const bHasExperts = b.experts && b.experts.length > 0 ? 1 : 0;

                    if (aHasExperts !== bHasExperts) {
                        return bHasExperts - aHasExperts;
                    }

                    return b.recommendationScore - a.recommendationScore;
                })
                .slice(0, limit);

        } catch (error) {
            console.error('Error in getPersonalizedRecommendations:', error);
            throw error;
        }
    }

}

module.exports = new SkillRecommendationService();