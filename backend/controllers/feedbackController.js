// const Feedback = require('../models/Feedback');
// const User = require('../models/user');

// // Submit Feedback
// exports.submitFeedback = async (req, res) => {
//   try {
//     const { recipientId, content, rating } = req.body;
//     const senderId = req.user.userId;

//     // Check if the recipient exists
//     const recipient = await User.findById(recipientId);
//     if (!recipient) {
//       return res.status(404).json({ message: 'Recipient not found' });
//     }

//     // Create a new feedback entry
//     const feedback = new Feedback({
//       sender: senderId,
//       recipient: recipientId,
//       content,
//       rating,
//       date: new Date()
//     });

//     await feedback.save();
//     res.status(201).json({ message: 'Feedback submitted successfully', feedback });
//   } catch (error) {
//     console.error(error);
//     res.status(500).json({ message: 'Server error' });
//   }
// };

// // Get Feedback for a User
// exports.getFeedbackForUser = async (req, res) => {
//   try {
//     const { userId } = req.params;

//     // Find feedback received by the specified user
//     const feedbacks = await Feedback.find({ recipient: userId }).populate('sender', 'username email').sort({ date: -1 });

//     res.json(feedbacks);
//   } catch (error) {
//     console.error(error);
//     res.status(500).json({ message: 'Server error' });
//   }
// };

// // Get All Feedback Received by the Logged-In User
// exports.getMyFeedback = async (req, res) => {
//   try {
//     const currentUserId = req.user.userId;

//     // Find feedback received by the logged-in user
//     const feedbacks = await Feedback.find({ recipient: currentUserId }).populate('sender', 'username email').sort({ date: -1 });

//     res.json(feedbacks);
//   } catch (error) {
//     console.error(error);
//     res.status(500).json({ message: 'Server error' });
//   }
// };

// controllers/feedbackController.js
const Feedback = require('../models/Feedback');

exports.createFeedback = async (req, res) => {
  try {
    const { starRating, satisfactionRating, contentClear, topicsCovered, comments } = req.body;
    const userId = req.user ? req.user.userId : null; // If you have authentication

    // Validate input
    if (!starRating || !satisfactionRating || contentClear === undefined || topicsCovered === undefined) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    // Create new feedback
    const feedback = new Feedback({
      starRating,
      satisfactionRating,
      contentClear,
      topicsCovered,
      comments,
      userId,
    });

    // Save feedback to database
    await feedback.save();

    return res.status(201).json({
      success: true,
      data: feedback,
      message: 'Feedback submitted successfully',
    });
  } catch (error) {
    console.error('Error submitting feedback:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

exports.getAllFeedback = async (req, res) => {
  try {
    // Pagination
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 10;
    const skip = (page - 1) * limit;

    // Get all feedback with pagination
    const feedback = await Feedback.find()
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    // Get total count for pagination
    const totalCount = await Feedback.countDocuments();

    return res.status(200).json({
      success: true,
      count: feedback.length,
      totalCount,
      totalPages: Math.ceil(totalCount / limit),
      currentPage: page,
      data: feedback,
    });
  } catch (error) {
    console.error('Error fetching feedback:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

exports.getFeedbackStatistics = async (req, res) => {
  try {
    const stats = await Feedback.aggregate([
      {
        $group: {
          _id: null,
          avgStarRating: { $avg: '$starRating' },
          avgSatisfactionRating: { $avg: '$satisfactionRating' },
          totalFeedbacks: { $sum: 1 },
          contentClearCount: {
            $sum: { $cond: ['$contentClear', 1, 0] },
          },
          topicsCoveredCount: {
            $sum: { $cond: ['$topicsCovered', 1, 0] },
          },
        },
      },
      {
        $project: {
          _id: 0,
          avgStarRating: { $round: ['$avgStarRating', 1] },
          avgSatisfactionRating: { $round: ['$avgSatisfactionRating', 1] },
          totalFeedbacks: 1,
          contentClearPercentage: {
            $round: [{ $multiply: [{ $divide: ['$contentClearCount', '$totalFeedbacks'] }, 100] }, 1],
          },
          topicsCoveredPercentage: {
            $round: [{ $multiply: [{ $divide: ['$topicsCoveredCount', '$totalFeedbacks'] }, 100] }, 1],
          },
        },
      },
    ]);

    return res.status(200).json({
      success: true,
      data: stats.length > 0 ? stats[0] : {
        avgStarRating: 0,
        avgSatisfactionRating: 0,
        totalFeedbacks: 0,
        contentClearPercentage: 0,
        topicsCoveredPercentage: 0,
      },
    });
  } catch (error) {
    console.error('Error fetching feedback statistics:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};
