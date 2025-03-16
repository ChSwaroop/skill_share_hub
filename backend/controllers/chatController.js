
// controllers/chatController.js
const { Chat } = require('../models/user');
const mongoose = require('mongoose');

exports.getChatsByUserId = async (req, res) => {
    console.log("get chat list called");
    try {
        const { userId } = req.params;

        const chats = await Chat.find({ participants: userId })
            .populate({
                path: 'participants',
                select: 'username profilePicture isOnline lastSeen',
            })
            .populate({
                path: 'lastMessage',
                populate: {
                    path: 'sender',
                },
            })
            .populate({
                path: 'lastMessage.readBy',
                select: 'user readAt',
            })
            .sort({ updatedAt: -1 });

        res.status(200).json(chats);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};



// POST /api/chats - Create a new chat
exports.createChat = async (req, res) => {
    try {
        const { chatType, participants, name, admins } = req.body;
        const createdBy = req.user.id; // Assuming authMiddleware adds user info to req

        // Validate chatType
        if (!['direct', 'group'].includes(chatType)) {
            return res.status(400).json({ message: 'Invalid chat type' });
        }

        // Validate participants
        if (!participants || !Array.isArray(participants) || participants.length === 0) {
            return res.status(400).json({ message: 'Participants are required' });
        }

        // Validate participant IDs
        for (const participantId of participants) {
            if (!mongoose.Types.ObjectId.isValid(participantId)) {
                return res.status(400).json({ message: 'Invalid participant ID' });
            }
        }

        if (chatType === 'direct') {
            if (participants.length !== 2) {
                return res.status(400).json({ message: 'Direct chat must have exactly two participants' });
            }

            // Check if a direct chat already exists between these two users
            const existingChat = await Chat.findOne({
                chatType: 'direct',
                participants: { $all: participants },
            });

            if (existingChat) {
                return res.status(200).json({ message: 'Direct chat already exists', data: existingChat });
            }

            const newChat = new Chat({
                _id: new mongoose.Types.ObjectId(),
                chatType: 'direct',
                participants: participants,
            });

            const savedChat = await newChat.save();
            return res.status(201).json({ message: 'Direct chat created successfully', data: savedChat });
        } else if (chatType === 'group') {
            if (!name) {
                return res.status(400).json({ message: 'Group name is required' });
            }
            if (participants.length < 2) {
                return res.status(400).json({ message: 'Group chat must have at least two participants' });
            }

            const newChat = new Chat({
                _id: new mongoose.Types.ObjectId(),
                chatType: 'group',
                name: name,
                participants: participants,
                createdBy: createdBy,
                admins: admins && Array.isArray(admins) ? admins.filter(id => mongoose.Types.ObjectId.isValid(id)) : null,
            });

            const savedChat = await newChat.save();
            return res.status(201).json({ message: 'Group chat created successfully', data: savedChat });
        }
    } catch (error) {
        console.error('Error creating chat:', error);
        return res.status(500).json({ message: 'Failed to create chat', error: error.message });
    }
}