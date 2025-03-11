const Feedback = require('../models/Feedback');
const User = require('../models/user');

// Submit Feedback
exports.submitFeedback = async (req, res) => {
  try {
    const { recipientId, content, rating } = req.body;
    const senderId = req.user.userId;

    // Check if the recipient exists
    const recipient = await User.findById(recipientId);
    if (!recipient) {
      return res.status(404).json({ message: 'Recipient not found' });
    }

    // Create a new feedback entry
    const feedback = new Feedback({
      sender: senderId,
      recipient: recipientId,
      content,
      rating,
      date: new Date()
    });

    await feedback.save();
    res.status(201).json({ message: 'Feedback submitted successfully', feedback });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get Feedback for a User
exports.getFeedbackForUser = async (req, res) => {
  try {
    const { userId } = req.params;

    // Find feedback received by the specified user
    const feedbacks = await Feedback.find({ recipient: userId }).populate('sender', 'username email').sort({ date: -1 });

    res.json(feedbacks);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get All Feedback Received by the Logged-In User
exports.getMyFeedback = async (req, res) => {
  try {
    const currentUserId = req.user.userId;

    // Find feedback received by the logged-in user
    const feedbacks = await Feedback.find({ recipient: currentUserId }).populate('sender', 'username email').sort({ date: -1 });

    res.json(feedbacks);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};