const SkillProgress = require('../models/skillProgress');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const { User, Chat, Todo, ChatbotHistory, Analytics, Skill } = require('../models/user.js');

// Get User Profile
exports.getUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.userId).select('-password').populate('skills').populate('communities').populate('messages').populate('feedbacks');
    if (!user) return res.status(404).json({ message: 'User not found' });

    res.json(user);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Update User Profile
exports.updateUserProfile = async (req, res) => {
  try {
    const { username, email } = req.body;
    const updatedData = {};
    if (username) updatedData.username = username;
    if (email) updatedData.email = email;

    const user = await User.findByIdAndUpdate(req.user.userId, updatedData, { new: true }).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });

    res.json(user);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get Skill Progress
exports.getSkillProgress = async (req, res) => {
  try {
    const userId = req.user.userId;

    // Fetch the skill progress for the logged-in user
    const skillProgress = await SkillProgress.find({ user: userId }).populate('skill');

    if (!skillProgress || skillProgress.length === 0) {
      return res.status(404).json({ message: 'No skill progress found for this user' });
    }

    res.json(skillProgress);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};


// Update Skill Progress
exports.updateSkillProgress = async (req, res) => {
  try {
    const { skill, progress } = req.body;
    const userId = req.user.userId;

    let skillProgress = await SkillProgress.findOne({ user: userId, skill });
    if (!skillProgress) {
      skillProgress = new SkillProgress({ user: userId, skill, progress });
    } else {
      skillProgress.progress = progress;
    }

    await skillProgress.save();
    res.json({ message: 'Skill progress updated successfully', skillProgress });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Join a Community
exports.joinCommunity = async (req, res) => {
  try {
    const { communityId } = req.body;
    const user = await User.findById(req.user.userId);

    if (!user.communities.includes(communityId)) {
      user.communities.push(communityId);
      await user.save();
      res.json({ message: 'Joined community successfully' });
    } else {
      res.status(400).json({ message: 'Already a member of this community' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Leave a Community
exports.leaveCommunity = async (req, res) => {
  try {
    const { communityId } = req.body;
    const user = await User.findById(req.user.userId);

    if (!user) return res.status(404).json({ message: 'User not found' });

    if (user.communities.includes(communityId)) {
      user.communities = user.communities.filter(id => id.toString() !== communityId);
      await user.save();
      res.json({ message: 'Left community successfully' });
    } else {
      res.status(400).json({ message: 'You are not a member of this community' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get Personalized Dashboard
exports.getDashboard = async (req, res) => {
  try {
    const user = await User.findById(req.user.userId)
      .populate('skills')
      .populate('communities')
      .populate('messages')
      .populate('feedbacks');

    if (!user) return res.status(404).json({ message: 'User not found' });

    const dashboardData = {
      username: user.username,
      skills: user.skills,
      communities: user.communities,
      recentMessages: user.messages.slice(-5),
      feedbacks: user.feedbacks,
    };

    res.json(dashboardData);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Block/Unblock a User
exports.blockUser = async (req, res) => {
  try {
    const { blockUserId } = req.body;
    const user = await User.findById(req.user.userId);

    if (!user) return res.status(404).json({ message: 'User not found' });

    if (user.blockedUsers.includes(blockUserId)) {
      user.blockedUsers = user.blockedUsers.filter(id => id.toString() !== blockUserId);
      await user.save();
      res.json({ message: 'User unblocked' });
    } else {
      user.blockedUsers.push(blockUserId);
      await user.save();
      res.json({ message: 'User blocked' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Delete User Account
exports.deleteUserAccount = async (req, res) => {
  try {
    const userId = req.user.userId;
    await User.findByIdAndDelete(userId);
    res.json({ message: 'User account deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.searchUsersBySkill = async (req, res) => {
  let skillQuery = req.query.skill;

  if (!skillQuery || typeof skillQuery !== 'string') {
    return res.status(400).json({ message: "A valid skill query is required." });
  }

  // Trim and escape the query to prevent regex injection
  const escapeRegex = (text) => text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const escapedQuery = escapeRegex(skillQuery.trim());

  try {
    // Find skills that match the query (using partial match if needed)
    const skills = await Skill.find({
      name: { $regex: new RegExp(escapedQuery, 'i') }
    });

    if (!skills || skills.length === 0) {
      return res.status(404).json({ message: "No skills found", users: [] });
    }

    // Extract skill IDs from the found skills
    const skillIds = skills.map(skill => skill._id);

    // Find Users who have any of these skills in their skills array, excluding the authenticated user
    const users = await User.find({
      skills: { $in: skillIds },
      _id: { $ne: req.user.userId } // Exclude the authenticated user
    })
      .populate({
        path: 'skills',
        model: 'Skill'
      });

    return res.status(200).json({ message: "Users found", users });
  } catch (error) {
    console.error("Error searching users by skill:", error);
    return res.status(500).json({ message: "Server error" });
  }
};


exports.getUserConnections = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findById(userId).populate('connections', 'username profilePicture isOnline lastSeen skills');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json(user.connections);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getPendingConnections = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findById(userId).populate('pendingConnections', 'username profilePicture skills');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json(user.pendingConnections);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.searchUsers = async (req, res) => {
  try {
    const { query, skills } = req.query;
    let searchQuery = {};

    if (query) {
      searchQuery.$or = [
        { username: { $regex: query, $options: 'i' } },
        { email: { $regex: query, $options: 'i' } }
      ];
    }

    if (skills) {
      const skillsArray = skills.split(',');
      searchQuery.skills = { $in: skillsArray };
    }

    const users = await User.find(searchQuery)
      .select('username profilePicture isOnline lastSeen skills');

    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
