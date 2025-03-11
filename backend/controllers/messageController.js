const dotenv = require('dotenv');
const Message = require('../models/Message');
const User = require('../models/user');
const { RtcTokenBuilder, RtcRole } = require('agora-access-token');

dotenv.config(); // Load environment variables

// Temporary chat token for Agora
const AGORA_TEMP_CHAT_TOKEN = '007eJxTYFhe+aOX9dzq7e0M840bWZ/kJ+29GML1Iens2qM73/q/9w5QYDCxMDC3sEwxMEpNSzExtUxJTDZISk41MU82MjRJSTNONTBUS28IZGTYFLKOgZGBFYiZGEB8BgYACpgfHg==';

// Function to generate an Agora token
const generateAgoraToken = (channelName, uid) => {
  const appID = process.env.AGORA_APP_ID; // Ensure this is in your .env file
  const appCertificate = process.env.AGORA_APP_CERTIFICATE;
  const expirationTimeInSeconds = 3600; // Token valid for 1 hour
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

  return RtcTokenBuilder.buildTokenWithUid(
    appID,
    appCertificate,
    channelName,
    uid,
    RtcRole.PUBLISHER,
    privilegeExpiredTs
  );
};

// Send a Message
exports.sendMessage = async (req, res) => {
  try {
    const { receiver, content } = req.body;
    const sender = req.user.userId;

    // Check if the receiver exists
    const receiverUser = await User.findById(receiver);
    if (!receiverUser) return res.status(404).json({ message: 'Receiver not found' });

    // Create and save the message
    const message = new Message({ sender, receiver, content });
    await message.save();

    // Optionally generate an Agora token for this chat session
    const channelName = `chat_${sender}_${receiver}`;
    const token = generateAgoraToken(channelName, sender);

    res.status(201).json({ 
      message: 'Message sent successfully', 
      message, 
      agoraToken: token,
      chatToken: AGORA_TEMP_CHAT_TOKEN // Return the temporary chat token
    });
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get Conversation History
exports.getConversation = async (req, res) => {
  try {
    const { userId } = req.params; // ID of the other user in the conversation
    const currentUserId = req.user.userId;

    // Find messages between the current user and the specified user
    const messages = await Message.find({
      $or: [
        { sender: currentUserId, receiver: userId },
        { sender: userId, receiver: currentUserId }
      ]
    }).sort({ createdAt: 1 });

    res.json(messages);
  } catch (error) {
    console.error('Error getting conversation:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get Recent Messages for User's Inbox
exports.getRecentMessages = async (req, res) => {
  try {
    const userId = req.user.userId;

    // Find the latest message in each conversation
    const messages = await Message.aggregate([
      {
        $match: {
          $or: [
            { sender: userId },
            { receiver: userId }
          ]
        }
      },
      {
        $sort: { createdAt: -1 }
      },
      {
        $group: {
          _id: {
            otherUser: {
              $cond: {
                if: { $eq: ['$sender', userId] },
                then: '$receiver',
                else: '$sender'
              }
            }
          },
          latestMessage: { $first: '$$ROOT' }
        }
      },
      { $replaceRoot: { newRoot: '$latestMessage' } },
      { $sort: { createdAt: -1 } }
    ]);

    res.json(messages);
  } catch (error) {
    console.error('Error getting recent messages:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getMessages = async (req, res) => {
  try {
      const messages = await Message.find(); // Adjust logic to fetch messages
      res.status(200).json(messages);
  } catch (error) {
      res.status(500).json({ message: 'Error fetching messages' });
  }
};
