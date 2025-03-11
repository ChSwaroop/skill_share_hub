const User = require('../models/user');
const Report = require('../models/report');

// Report a User
exports.reportUser = async (req, res) => {
  try {
    const { reportedUserId, reason } = req.body;
    const reporterUserId = req.user.userId;

    if (reportedUserId === reporterUserId) {
      return res.status(400).json({ message: "You can't report yourself" });
    }

    // Create a new report entry
    const report = new Report({
      reporter: reporterUserId,
      reportedUser: reportedUserId,
      reason,
      date: new Date()
    });

    await report.save();
    res.status(201).json({ message: 'User reported successfully', report });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Block or Unblock a User
exports.toggleBlockUser = async (req, res) => {
  try {
    const { blockUserId } = req.body;
    const currentUserId = req.user.userId;

    if (blockUserId === currentUserId) {
      return res.status(400).json({ message: "You can't block yourself" });
    }

    const user = await User.findById(currentUserId);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Check if the user is already blocked
    if (user.blockedUsers.includes(blockUserId)) {
      user.blockedUsers = user.blockedUsers.filter(id => id.toString() !== blockUserId);
      await user.save();
      res.json({ message: 'User unblocked successfully' });
    } else {
      user.blockedUsers.push(blockUserId);
      await user.save();
      res.json({ message: 'User blocked successfully' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get Blocked Users List
exports.getBlockedUsers = async (req, res) => {
  try {
    const currentUserId = req.user.userId;

    const user = await User.findById(currentUserId).populate('blockedUsers', 'username email');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ blockedUsers: user.blockedUsers });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};