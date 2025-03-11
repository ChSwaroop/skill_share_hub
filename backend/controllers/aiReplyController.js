const AIService = require('../utils/aiReplyService');

// Get AI Instant Reply
exports.getAIReply = async (req, res) => {
  try {
    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ message: 'Message is required' });
    }

    // Call the AI service to generate a reply
    const reply = await AIService.generateReply(message);

    res.json({ reply });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};