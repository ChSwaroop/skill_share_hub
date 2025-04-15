require('dotenv').config();
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const connectMongoDB = require('./config/db');
const authRoutes = require('./routes/auth');
const messageRoutes = require('./routes/messageRoutes');
const userRoutes = require('./routes/user');
const { User, Chat, Message } = require('./models/user');
const SkillProgress = require('./models/skillProgress');
const skillRoutes = require('./routes/skillRoutes')
const connectionRoutes = require('./routes/connection');
const admin = require('firebase-admin');
const mongoose = require('mongoose')
const Call = require('./models/Call')
const UserActivity = require('./models/userActivity');

const startNotificationScheduler = require('./utils/notificationScheduler');
const { RtcTokenBuilder, RtcRole } = require('agora-access-token');
const chatRoutes = require('./routes/chatRoutes');
const userStatsRoutes = require('./routes/userStatsRoutes');
const skillRecommendationRoutes = require('./routes/recommendationRoutes');

const feedbackRoutes = require('./routes/feedbackRoutes');

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

// Middleware
app.use(express.json());
app.use('/api/auth', authRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/users', userRoutes);
app.use('/api/skills', skillRoutes);
app.use('/api/connections', connectionRoutes);
app.use('/api/chats', chatRoutes);// Mount routers
app.use('/api/todos', require('./routes/todoRoutes'));
app.use('/api/stats', userStatsRoutes); // New stats routes
app.use('/api/recommendations', skillRecommendationRoutes);
app.use('/api/feedback', feedbackRoutes);
// Add your other routes here (users, auth, etc.)

// Start notification scheduler
// startNotificationScheduler();

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert({
    projectId: process.env.FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
  }),
  databaseURL: process.env.FIREBASE_DATABASE_URL
});

// Simple Route for Testing
app.get('/', (req, res) => {
  res.send('Server is up and running!');
});

// Socket.io for real-time messaging
// io.on('connection', (socket) => {
//   console.log('New client connected');

//   socket.on('sendMessage', (message) => {
//     io.emit('receiveMessage', message);
//   });

//   socket.on('disconnect', () => {
//     console.log('Client disconnected');
//   });
// });

//-----------------------------------------------Messaging-----------------------------------------//
// Socket.IO connection handler
const connectedUsers = new Map(); // Store socket.id -> userId mapping

io.on('connection', (socket) => {
  console.log('New client connected:', socket.id);

  // User authentication and online status
  socket.on('authenticate', async (userId) => {

    // console.log("connected users while auth: " + JSON.stringify(Object.fromEntries(connectedUsers)));
    try {
      const user = await User.findById(userId);
      if (!user) return;

      // Update user status to online
      await User.findByIdAndUpdate(userId, { isOnline: true, lastSeen: new Date() });

      console.log('connected users: ');
      // If user already has a connection, remove old socket
      for (const [existingSocketId, existingUserId] of connectedUsers.entries()) {
        console.log(`Existing socket: ${existingSocketId}, User ID: ${existingUserId}`);
        if (existingUserId.toString() === userId.toString()) {
          console.log(`Disconnecting previous session for user: ${userId}`);
          // io.sockets.sockets.get(existingSocketId)?.disconnect(true);
          // connectedUsers.delete(existingSocketId);
          const socketToDisconnect = io.sockets.sockets.get(existingSocketId);
          if (socketToDisconnect) {
            socketToDisconnect.disconnect(true);
          }
          return;
        }
      }
      console.log("Entered bro...");
      // const userIdStr = userId.toString(); // Use string representation for consistency

      // Prevent duplicate processing for the same user concurrently
      if (connectedUsers.has(userId)) {
        console.log(`Authentication already in progress for user ${userIdStr}. Ignoring duplicate request from socket ${socket.id}.`);
        return;
      }

      // Add user to connected users map
      connectedUsers.set(socket.id, userId);

      // Join all user's chat rooms
      const chats = await Chat.find({ participants: userId });
      // console.log("chats: " + chats);
      chats.forEach(chat => {

        socket.join(chat._id.toString());
      });

      // Broadcast user online status to connections
      const connections = user.connections;
      connections.forEach(async (connectionId) => {
        // Find sockets of connected users who are online
        for (const [socketId, connectedUserId] of connectedUsers.entries()) {
          if (connectedUserId.toString() === connectionId.toString()) {
            io.to(socketId).emit('user_status_changed', {
              userId: userId,
              status: 'online'
            });
          }
        }
      });

      console.log(`User ${userId} authenticated and set to online ${socket.id}`);
    } catch (error) {
      console.error('Authentication error:', error);
    }
  });

  // Handle new message
  socket.on('send_message', async (messageData) => {
    try {
      const { chatId, content, contentType, fileUrl } = messageData;
      const senderId = connectedUsers.get(socket.id);

      if (!senderId) return;

      // Create new message
      const newMessage = new Message({
        _id: new mongoose.Types.ObjectId(),
        chatId,
        sender: senderId,
        content,
        contentType: contentType || 'text',
        fileUrl,
        status: 'sent',
        readBy: []
      });

      await newMessage.save();

      // Update chat's last message
      await Chat.findByIdAndUpdate(chatId, {
        lastMessage: newMessage._id,
        updatedAt: new Date()
      });

      // Populate sender info
      const populatedMessage = await Message.findById(newMessage._id)
        .populate('sender', 'username profilePicture');

      // Emit message to all participants in the chat
      io.to(chatId).emit('new_message', populatedMessage);

      // Mark as delivered for online users
      const chat = await Chat.findById(chatId);
      chat.participants.forEach(async (participantId) => {
        if (participantId.toString() !== senderId.toString()) {
          // Check if participant is online
          let isRecipientOnline = false;
          for (const [_, connectedUserId] of connectedUsers.entries()) {
            if (connectedUserId.toString() === participantId.toString()) {
              isRecipientOnline = true;
              break;
            }
          }

          if (isRecipientOnline) {
            // Update message status to delivered
            await Message.findByIdAndUpdate(newMessage._id, {
              status: 'delivered'
            });

            // Emit delivery status update
            io.to(chatId).emit('message_status_updated', {
              messageId: newMessage._id,
              status: 'delivered'
            });
          }
        }
      });
    } catch (error) {
      console.error('Send message error:', error);
    }
  });

  // Handle read receipts
  socket.on('mark_as_read', async (data) => {
    try {
      const { messageId } = data;
      const userId = connectedUsers.get(socket.id);

      if (!userId) return;

      const message = await Message.findById(messageId);
      if (!message) return;

      // Check if user has already read the message
      const alreadyRead = message.readBy.some(read => read.user.toString() === userId.toString());

      if (!alreadyRead) {
        // Add user to readBy array
        await Message.findByIdAndUpdate(messageId, {
          status: 'read',
          $push: {
            readBy: {
              user: userId,
              readAt: new Date()
            }
          }
        });

        // Notify chat participants about read status
        io.to(message.chatId.toString()).emit('message_status_updated', {
          messageId: message._id,
          status: 'read',
          readBy: userId
        });
      }
    } catch (error) {
      console.error('Mark as read error:', error);
    }
  });

  // Connection management endpoints
  socket.on('request_connection', async (data) => {
    try {
      const { targetUserId } = data;
      const userId = connectedUsers.get(socket.id);

      if (!userId) return;

      await User.findByIdAndUpdate(targetUserId, {
        $addToSet: { pendingConnections: userId }
      });

      // Notify target user if online
      for (const [socketId, connectedUserId] of connectedUsers.entries()) {
        if (connectedUserId.toString() === targetUserId.toString()) {
          io.to(socketId).emit('connection_request', {
            userId
          });
        }
      }
    } catch (error) {
      console.error('Request connection error:', error);
    }
  });

  socket.on('accept_connection', async (data) => {
    try {
      const { targetUserId } = data;
      const userId = connectedUsers.get(socket.id);

      if (!userId) return;

      // Update both users' connections
      await User.findByIdAndUpdate(userId, {
        $addToSet: { connections: targetUserId },
        $pull: { pendingConnections: targetUserId }
      });

      await User.findByIdAndUpdate(targetUserId, {
        $addToSet: { connections: userId }
      });

      // Create a direct chat between the users if it doesn't exist
      const existingChat = await Chat.findOne({
        chatType: 'direct',
        participants: { $all: [userId, targetUserId], $size: 2 }
      });

      if (!existingChat) {
        const newChat = new Chat({
          _id: new mongoose.Types.ObjectId(),
          chatType: 'direct',
          participants: [userId, targetUserId],
          createdBy: userId,
          createdAt: new Date(),
          updatedAt: new Date()
        });

        await newChat.save();

        // Join both users to the chat room
        socket.join(newChat._id.toString());

        // Find target user's socket and join them to chat
        for (const [socketId, connectedUserId] of connectedUsers.entries()) {
          if (connectedUserId.toString() === targetUserId.toString()) {
            io.sockets.sockets.get(socketId)?.join(newChat._id.toString());
          }
        }
      }

      // Notify both users
      socket.emit('connection_accepted', { userId: targetUserId });

      for (const [socketId, connectedUserId] of connectedUsers.entries()) {
        if (connectedUserId.toString() === targetUserId.toString()) {
          io.to(socketId).emit('connection_accepted', { userId });
        }
      }
    } catch (error) {
      console.error('Accept connection error:', error);
    }
  });

  // Group chat operations
  socket.on('create_group_chat', async (data) => {
    try {
      const { name, participants } = data;
      const creatorId = connectedUsers.get(socket.id);

      if (!creatorId) return;

      // Ensure creator is included in participants
      const allParticipants = [...new Set([...participants, creatorId])];

      const newGroupChat = new Chat({
        _id: new mongoose.Types.ObjectId(),
        chatType: 'group',
        name,
        participants: allParticipants,
        createdBy: creatorId,
        admins: [creatorId],
        createdAt: new Date(),
        updatedAt: new Date()
      });

      await newGroupChat.save();

      // Join creator to group chat room
      socket.join(newGroupChat._id.toString());

      // Join all online participants to the group chat room
      allParticipants.forEach(participantId => {
        for (const [socketId, connectedUserId] of connectedUsers.entries()) {
          if (connectedUserId.toString() === participantId.toString()) {
            io.sockets.sockets.get(socketId)?.join(newGroupChat._id.toString());
            io.to(socketId).emit('added_to_group', {
              chatId: newGroupChat._id,
              chatName: name
            });
          }
        }
      });

      socket.emit('group_created', newGroupChat);
    } catch (error) {
      console.error('Create group chat error:', error);
    }
  });

  // Disconnect handler
  socket.on('disconnect', async () => {
    console.log("disconnection called");
    const userId = connectedUsers.get(socket.id);
    if (userId) {
      // Update user status to offline
      await User.findByIdAndUpdate(userId, {
        isOnline: false,
        lastSeen: new Date()
      });

      // Notify connections about user going offline
      const user = await User.findById(userId);
      if (user) {
        const connections = user.connections;
        connections.forEach(async (connectionId) => {
          // Find sockets of connected users who are online
          for (const [socketId, connectedUserId] of connectedUsers.entries()) {
            if (connectedUserId.toString() === connectionId.toString()) {
              io.to(socketId).emit('user_status_changed', {
                userId: userId,
                status: 'offline',
                lastSeen: new Date()
              });
            }
          }
        });
      }

      // Remove from connected users map
      connectedUsers.delete(socket.id);
      console.log("connected users while disconnect: " + JSON.stringify(Object.fromEntries(connectedUsers)));

      console.log(`User ${userId} disconnected and set to offline`);
    }

    console.log('Client disconnected:', socket.id);
  });
});

//-----------------------------------------------Messaging-----------------------------------------//


// Temporary token for Agora video calls
const AGORA_TEMP_TOKEN = '007eJxTYEhaxH7GTONn0D+Li66Wy24c/SPscIXZP86Et1/8aFWQQaUCg4mFgbmFZYqBUWpaiompZUpiskFScqqJebKRoUlKmnHqR0G19IZARoaITbKsjAwQCOJzMZRlpqTmKyQn5uQwMAAAoHAf4Q==';

app.get('/api/video/token', (req, res) => {
  res.json({ token: AGORA_TEMP_TOKEN });
});

// Temporary token for Agora chat
const AGORA_CHAT_TEMP_TOKEN = '007eJxTYFhe+aOX9dzq7e0M840bWZ/kJ+29GML1Iens2qM73/q/9w5QYDCxMDC3sEwxMEpNSzExtUxJTDZISk41MU82MjRJSTNONTBUS28IZGTYFLKOgZGBFYiZGEB8BgYACpgfHg==';

app.get('/api/message/token', (req, res) => {
  res.json({ token: AGORA_CHAT_TEMP_TOKEN });
});


// Sample Data Insertion Function
const insertSampleData = async () => {
  try {
    await User.deleteMany({});
    await SkillProgress.deleteMany({});

    const users = await User.insertMany([
      { username: 'Alice', email: 'alice@example.com', password: 'hashed_password_1' },
      { username: 'Bob', email: 'bob@example.com', password: 'hashed_password_2' },
    ]);

    await SkillProgress.insertMany([
      { user: users[0]._id, skill: 'JavaScript', level: 'Beginner', progress: 20 },
      { user: users[1]._id, skill: 'Python', level: 'Intermediate', progress: 45 },
    ]);

    console.log('Sample data inserted successfully');
  } catch (error) {
    console.error('Error inserting sample data:', error);
  }
};

// Connect to MongoDB and start server
const startServer = async () => {
  try {
    await connectMongoDB(); // Connect to MongoDB
    // await insertSampleData(); // Insert sample data
    const PORT = process.env.PORT || 3000;
    server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();


// // REST API endpoints for chat history, user management, etc.
// app.get('/api/chats/:userId', async (req, res) => {
//   console.log("get chat list called");
//   try {
//     const { userId } = req.params;
//     const chats = await Chat.find({ participants: userId })
//       .populate('participants', 'username profilePicture isOnline lastSeen')
//       .populate('lastMessage')
//       .sort({ updatedAt: -1 });

//     res.status(200).json(chats);
//   } catch (error) {
//     res.status(500).json({ error: error.message });
//   }
// });

// app.get('/api/messages/:chatId', async (req, res) => {
//   try {
//     const { chatId } = req.params;
//     const { page = 1, limit = 50 } = req.query;

//     const messages = await Message.find({ chatId })
//       .populate('sender', 'username profilePicture')
//       .sort({ createdAt: -1 })
//       .limit(parseInt(limit))
//       .skip((parseInt(page) - 1) * parseInt(limit));

//     res.status(200).json(messages.reverse()); // Return in chronological order
//   } catch (error) {
//     res.status(500).json({ error: error.message });
//   }
// });

// app.get('/api/users/:userId/connections', async (req, res) => {
//   try {
//     const { userId } = req.params;
//     const user = await User.findById(userId).populate('connections', 'username profilePicture isOnline lastSeen skills');

//     if (!user) {
//       return res.status(404).json({ message: 'User not found' });
//     }

//     res.status(200).json(user.connections);
//   } catch (error) {
//     res.status(500).json({ error: error.message });
//   }
// });

// app.get('/api/users/:userId/pending-connections', async (req, res) => {
//   try {
//     const { userId } = req.params;
//     const user = await User.findById(userId).populate('pendingConnections', 'username profilePicture skills');

//     if (!user) {
//       return res.status(404).json({ message: 'User not found' });
//     }

//     res.status(200).json(user.pendingConnections);
//   } catch (error) {
//     res.status(500).json({ error: error.message });
//   }
// });

// app.get('/api/users/search', async (req, res) => {
//   try {
//     const { query, skills } = req.query;
//     let searchQuery = {};

//     if (query) {
//       searchQuery.$or = [
//         { username: { $regex: query, $options: 'i' } },
//         { email: { $regex: query, $options: 'i' } }
//       ];
//     }

//     if (skills) {
//       const skillsArray = skills.split(',');
//       searchQuery.skills = { $in: skillsArray };
//     }

//     const users = await User.find(searchQuery)
//       .select('username profilePicture isOnline lastSeen skills');

//     res.status(200).json(users);
//   } catch (error) {
//     res.status(500).json({ error: error.message });
//   }
// });
/////////////callss----------

// Call Schema to track active calls
// const callSchema = new mongoose.Schema({
//   channelName: { type: String, required: true, unique: true },
//   callType: { type: String, required: true }, // 'audio' or 'video'
//   initiator: { type: String, required: true }, // userId of the caller
//   participants: [{ type: String }], // array of userIds
//   startTime: { type: Date, default: Date.now },
//   active: { type: Boolean, default: true }
// });

// const Call = mongoose.model('Call', callSchema);

// // Agora configuration
// const APP_ID = process.env.AGORA_APP_ID;
// const APP_CERTIFICATE = process.env.AGORA_APP_CERTIFICATE;

// // API endpoint to register or update a user's FCM token
// app.post('/api/register-device', async (req, res) => {
//   try {
//     const { userId, username, fcmToken } = req.body;

//     if (!userId || !fcmToken) {
//       return res.status(400).json({ error: 'User ID and FCM token are required' });
//     }

//     // Update user info in the database, or create if not exists
//     await User.findByIdAndUpdate(
//       userId,
//       { fcmToken, lastUpdated: Date.now() },
//       { upsert: true, new: true }
//     );

//     return res.json({ success: true });
//   } catch (error) {
//     console.error('Error registering device:', error);
//     return res.status(500).json({ error: 'Failed to register device' });
//   }
// });

// // Generate an RTC token
// app.post('/api/rtc-token', (req, res) => {
//   console.log("Request for token received");
//   try {
//     const { channelName, uid, role, expirationTimeInSeconds = 3600 } = req.body;

//     if (!channelName) {
//       return res.status(400).json({ error: 'Channel name is required' });
//     }

//     // Role can be either 'publisher' or 'subscriber'
//     const selectedRole = role === 'subscriber' ? RtcRole.SUBSCRIBER : RtcRole.PUBLISHER;

//     // Set expiration time
//     const currentTimestamp = Math.floor(Date.now() / 1000);
//     const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

//     // Build token
//     const token = RtcTokenBuilder.buildTokenWithUid(
//       APP_ID,
//       APP_CERTIFICATE,
//       channelName,
//       uid || 0, // 0 means use the Agora assigned uid
//       selectedRole,
//       privilegeExpiredTs
//     );

//     console.log("Token generated: " + token.substring(0, 10) + "...");

//     return res.json({ token, uid: uid || 0, channelName });
//   } catch (error) {
//     console.error('Error generating token:', error);
//     return res.status(500).json({ error: 'Failed to generate token' });
//   }
// });

// // Get active calls for a user
// app.get('/api/active-calls', async (req, res) => {
//   try {
//     const { userId } = req.query;

//     if (!userId) {
//       return res.status(400).json({ error: 'User ID is required' });
//     }

//     // Find all active calls where the user is a participant
//     const activeCalls = await Call.find({
//       participants: userId,
//       active: true
//     });

//     return res.json({ activeCalls });
//   } catch (error) {
//     console.error('Error fetching active calls:', error);
//     return res.status(500).json({ error: 'Failed to fetch active calls' });
//   }
// });

// // Send FCM notification
// async function sendCallNotification(recipientUserId, callData) {
//   try {
//     // Find the recipient's FCM token
//     const recipient = await User.findById(recipientUserId);
//     console.log("receipient: " + recipient);

//     if (!recipient || !recipient.fcmToken) {
//       console.error(`No FCM token found for user: ${recipientUserId}`);
//       return false;
//     }

//     // Get caller information
//     const caller = await User.findById(callData.callerId);
//     const callerName = caller ? caller.username : 'Unknown Caller';

//     // Prepare notification message
//     const message = {
//       data: {
//         type: 'call',
//         channelName: callData.channelName,
//         isVideo: (callData.callType === 'video').toString(),
//         callerName: callerName
//       },
//       android: {
//         priority: 'high',
//         notification: {
//           channelId: 'call_channel'
//         }
//       },
//       apns: {
//         payload: {
//           aps: {
//             contentAvailable: true,
//             sound: 'incoming_call.aiff',
//             category: 'call'
//           }
//         }
//       },
//       token: recipient.fcmToken
//     };

//     // Send the notification
//     const response = await admin.messaging().send(message);
//     console.log(`Notification sent to ${recipientUserId}, response:`, response);
//     return true;
//   } catch (error) {
//     console.error('Error sending notification:', error);
//     return false;
//   }
// }

// // Start a new call
// app.post('/api/start-call', async (req, res) => {
//   try {
//     const { callerId, callType, participants } = req.body;
//     console.log("callerId: " + callerId);
//     console.log("callType: " + callType);
//     console.log("participants: " + participants);

//     if (!callerId || !callType || !participants || !Array.isArray(participants)) {
//       return res.status(400).json({ error: 'Caller ID, call type, and participants array are required' });
//     }

//     if (!['audio', 'video'].includes(callType)) {
//       return res.status(400).json({ error: 'Call type must be either "audio" or "video"' });
//     }

//     // Generate a unique channel name
//     const channelName = `call_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
//     // const channelName = `call`;

//     // Create call record in database
//     const call = new Call({
//       channelName,
//       callType,
//       initiator: callerId,
//       participants: [callerId, ...participants], // Include caller in participants
//       startTime: Date.now(),
//       active: true
//     });

//     await call.save();

//     // Send notifications to all participants except the caller
//     const notificationPromises = participants.map(participantId => {
//       if (participantId !== callerId) {
//         console.log("notification sent.. " + participantId);
//         return sendCallNotification(participantId, {
//           channelName,
//           callType,
//           callerId
//         });
//       }
//       return Promise.resolve(true);
//     });

//     // Wait for all notifications to be sent
//     await Promise.all(notificationPromises);

//     return res.json({
//       success: true,
//       channelName,
//       callType,
//       participants
//     });
//   } catch (error) {
//     console.error('Error starting call:', error);
//     return res.status(500).json({ error: 'Failed to start call' });
//   }
// });

// // End a call
// app.post('/api/end-call', async (req, res) => {
//   try {
//     const { channelName, userId } = req.body;

//     if (!channelName) {
//       return res.status(400).json({ error: 'Channel name is required' });
//     }

//     // Find and update the call
//     const call = await Call.findOne({ channelName });

//     if (!call) {
//       return res.status(404).json({ error: 'Call not found' });
//     }

//     // Update call status
//     call.active = false;
//     await call.save();

//     return res.json({ success: true });
//   } catch (error) {
//     console.error('Error ending call:', error);
//     return res.status(500).json({ error: 'Failed to end call' });
//   }
// });

// Agora configuration
const APP_ID = process.env.AGORA_APP_ID;
const APP_CERTIFICATE = process.env.AGORA_APP_CERTIFICATE;

// API endpoint to register or update a user's FCM token
app.post('/api/register-device', async (req, res) => {
  try {
    const { userId, username, fcmToken } = req.body;

    if (!userId || !fcmToken) {
      return res.status(400).json({ error: 'User ID and FCM token are required' });
    }

    // Update user info in the database, or create if not exists
    await User.findByIdAndUpdate(
      userId,
      { fcmToken, lastUpdated: Date.now() },
      { upsert: true, new: true }
    );

    return res.json({ success: true });
  } catch (error) {
    console.error('Error registering device:', error);
    return res.status(500).json({ error: 'Failed to register device' });
  }
});

// Generate an RTC token
app.post('/api/rtc-token', (req, res) => {
  console.log("Request for token received");
  try {
    const { channelName, uid, role, expirationTimeInSeconds = 3600 } = req.body;

    if (!channelName) {
      return res.status(400).json({ error: 'Channel name is required' });
    }

    // Role can be either 'publisher' or 'subscriber'
    const selectedRole = role === 'subscriber' ? RtcRole.SUBSCRIBER : RtcRole.PUBLISHER;

    // Set expiration time
    const currentTimestamp = Math.floor(Date.now() / 1000);
    const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

    // Build token
    const token = RtcTokenBuilder.buildTokenWithUid(
      APP_ID,
      APP_CERTIFICATE,
      channelName,
      uid || 0, // 0 means use the Agora assigned uid
      selectedRole,
      privilegeExpiredTs
    );

    console.log("Token generated: " + token.substring(0, 10) + "...");

    return res.json({ token, uid: uid || 0, channelName });
  } catch (error) {
    console.error('Error generating token:', error);
    return res.status(500).json({ error: 'Failed to generate token' });
  }
});

// Get active calls for a user
app.get('/api/active-calls', async (req, res) => {
  try {
    const { userId } = req.query;

    if (!userId) {
      return res.status(400).json({ error: 'User ID is required' });
    }

    // Find all active calls where the user is a participant
    const activeCalls = await Call.find({
      participants: userId,
      active: true,
    });

    return res.json({ activeCalls });
  } catch (error) {
    console.error('Error fetching active calls:', error);
    return res.status(500).json({ error: 'Failed to fetch active calls' });
  }
});

// Send FCM notification
async function sendCallNotification(recipientUserId, callData) {
  try {
    // Find the recipient's FCM token
    const recipient = await User.findById(recipientUserId);
    console.log("receipient: " + recipient);

    if (!recipient || !recipient.fcmToken) {
      console.error(`No FCM token found for user: ${recipientUserId}`);
      return false;
    }

    // Get caller information
    const caller = await User.findById(callData.callerId);
    const callerName = caller ? caller.username : 'Unknown Caller';

    // Prepare notification message
    const message = {
      data: {
        type: 'call',
        channelName: callData.channelName,
        isVideo: (callData.callType === 'video').toString(),
        callerName: callerName
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'call_channel'
        }
      },
      apns: {
        payload: {
          aps: {
            contentAvailable: true,
            sound: 'incoming_call.aiff',
            category: 'call'
          }
        }
      },
      token: recipient.fcmToken
    };

    // Send the notification
    const response = await admin.messaging().send(message);
    console.log(`Notification sent to ${recipientUserId}, response:`, response);
    return true;
  } catch (error) {
    console.error('Error sending notification:', error);
    return false;
  }
}

// Start a new call
app.post('/api/start-call', async (req, res) => {
  try {
    const { callerId, callType, participants } = req.body;
    console.log("callerId: " + callerId);
    console.log("callType: " + callType);
    console.log("participants: " + participants);

    if (!callerId || !callType || !participants || !Array.isArray(participants)) {
      return res.status(400).json({ error: 'Caller ID, call type, and participants array are required' });
    }

    if (!['audio', 'video'].includes(callType)) {
      return res.status(400).json({ error: 'Call type must be either "audio" or "video"' });
    }

    // Generate a unique channel name
    const channelName = `call_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
    // const channelName = `call`;

    // Create call record in database
    const call = new Call({
      channelName,
      callType,
      initiator: callerId,
      participants: [callerId, ...participants], // Include caller in participants
      startTime: Date.now(),
      active: true,
      status: 'initiated'
      // endTime and duration will be set when the call ends
    });

    await call.save();

    // Send notifications to all participants except the caller
    const notificationPromises = participants.map(participantId => {
      if (participantId !== callerId) {
        console.log("notification sent.. " + participantId);
        return sendCallNotification(participantId, {
          channelName,
          callType,
          callerId
        });
      }
      return Promise.resolve(true);
    });

    // Wait for all notifications to be sent
    await Promise.all(notificationPromises);

    return res.json({
      success: true,
      channelName,
      callType,
      participants
    });
  } catch (error) {
    console.error('Error starting call:', error);
    return res.status(500).json({ error: 'Failed to start call' });
  }
});

// End a call
app.post('/api/end-call', async (req, res) => {
  try {
    const { channelName, userId } = req.body;

    if (!channelName) {
      return res.status(400).json({ error: 'Channel name is required' });
    }

    // Find and update the call
    const call = await Call.findOne({ channelName, active: true });

    if (!call) {
      return res.status(404).json({ error: 'Active call not found' });
    }

    // Update call status and set end time and duration
    const endTime = new Date();
    const durationInSeconds = Math.round((endTime - call.startTime) / 1000);

    call.active = false;
    call.endTime = endTime;
    call.duration = durationInSeconds;
    call.status = 'ended';

    await call.save();

    // Update user activity records
    await updateUserActivityForCall(call);

    return res.json({
      success: true,
      duration: durationInSeconds
    });
  } catch (error) {
    console.error('Error ending call:', error);
    return res.status(500).json({ error: 'Failed to end call' });
  }
});

// Helper function to update user activity records when a call ends
async function updateUserActivityForCall(call) {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const durationField = call.callType === 'audio' ? 'audioDuration' : 'videoDuration';

    // Update or create activity records for each participant
    const updatePromises = call.participants.map(async (participantId) => {
      // Find today's activity record for this user
      const existingActivity = await UserActivity.findOne({
        userId: participantId,
        date: today
      });

      if (existingActivity) {
        // Update existing record
        existingActivity[durationField] = (existingActivity[durationField] || 0) + call.duration;
        existingActivity.callCount += 1;
        return existingActivity.save();
      } else {
        // Create new record
        const newActivity = new UserActivity({
          userId: participantId,
          date: today,
          [durationField]: call.duration,
          callCount: 1
        });
        return newActivity.save();
      }
    });

    await Promise.all(updatePromises);
    return true;
  } catch (error) {
    console.error('Error updating user activity for call:', error);
    return false;
  }
}

// Get call statistics for a user
app.get('/api/call-stats/:userId', async (req, res) => {
  try {
    console.log("call-stats called");
    const { userId } = req.params;
    const { days = 7 } = req.query;
    console.log("userId: " + userId);

    // Calculate date range
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - (parseInt(days) - 1));
    startDate.setHours(0, 0, 0, 0);

    // Create array of dates for the past N days
    const dateArray = [];
    for (let i = 0; i < parseInt(days); i++) {
      const date = new Date(startDate);
      date.setDate(date.getDate() + i);
      dateArray.push({
        date: new Date(date),
        formattedDate: date.toISOString().split('T')[0]
      });
    }

    // Aggregate call statistics
    const callStats = await Call.aggregate([
      {
        $match: {
          participants: userId,
          startTime: { $gte: startDate, $lte: endDate },
          endTime: { $exists: true }
        }
      },
      {
        $project: {
          dateString: { $dateToString: { format: "%Y-%m-%d", date: "$startTime" } },
          callType: 1,
          duration: 1
        }
      },
      {
        $group: {
          _id: {
            date: "$dateString",
            type: "$callType"
          },
          totalDuration: { $sum: "$duration" },
          callCount: { $sum: 1 }
        }
      },
      {
        $sort: { "_id.date": 1 }
      }
    ]);
    console.log("call-stats: " + callStats);

    // Map results to include all days in the range
    const result = dateArray.map(day => {
      const audioCalls = callStats.find(
        stat => stat._id.date === day.formattedDate && stat._id.type === 'audio'
      );

      const videoCalls = callStats.find(
        stat => stat._id.date === day.formattedDate && stat._id.type === 'video'
      );

      return {
        date: day.formattedDate,
        audio: {
          duration: audioCalls ? audioCalls.totalDuration : 0,
          count: audioCalls ? audioCalls.callCount : 0
        },
        video: {
          duration: videoCalls ? videoCalls.totalDuration : 0,
          count: videoCalls ? videoCalls.callCount : 0
        }
      };
    });

    // Calculate totals
    const totals = result.reduce((acc, day) => {
      return {
        audioDuration: acc.audioDuration + day.audio.duration,
        audioCount: acc.audioCount + day.audio.count,
        videoDuration: acc.videoDuration + day.video.duration,
        videoCount: acc.videoCount + day.video.count
      };
    }, { audioDuration: 0, audioCount: 0, videoDuration: 0, videoCount: 0 });

    res.json({
      success: true,
      dailyStats: result,
      totals
    });
  } catch (error) {
    console.error('Error fetching call stats:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch call statistics',
      error: error.message
    });
  }
});

// Get message statistics for a user
app.get('/api/message-stats/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { days = 7 } = req.query;

    // Calculate date range
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - (parseInt(days) - 1));
    startDate.setHours(0, 0, 0, 0);

    // Create array of dates
    const dateArray = [];
    for (let i = 0; i < parseInt(days); i++) {
      const date = new Date(startDate);
      date.setDate(date.getDate() + i);
      dateArray.push({
        date: new Date(date),
        formattedDate: date.toISOString().split('T')[0] // Extracts 'YYYY-MM-DD'
      });
    }

    // Get message counts from Message collection
    const messageCounts = await Message.aggregate([
      {
        $match: {
          sender: new mongoose.Types.ObjectId(userId),
          createdAt: { $gte: startDate, $lte: endDate }
        }
      },
      {
        $group: {
          _id: {
            $dateToString: { format: "%Y-%m-%d", date: "$createdAt" }
          },
          // _id: "$createdAt",
          count: { $sum: 1 }
        }
      }
    ]);
    console.log("message counts: " + messageCounts[0]._id);
    console.log("date: " + dateArray[0].date + "---- " + dateArray[0].formattedDate);


    // Map results to include all days
    const result = dateArray.map(day => {
      const dayData = messageCounts.find(item => item._id === day.formattedDate);
      console.log("in message-stats: " + dayData);
      return {
        date: day.formattedDate,
        messageCount: dayData ? dayData.count : 0
      };
    });

    // Calculate total
    const totalMessages = result.reduce((sum, day) => sum + day.messageCount, 0);

    res.json({
      success: true,
      dailyStats: result,
      total: totalMessages
    });
  } catch (error) {
    console.error('Error fetching message stats:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch message statistics',
      error: error.message
    });
  }
});

// Get combined activity stats for a user
app.get('/api/activity-stats/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { days = 7 } = req.query;

    // Calculate date range
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - (parseInt(days) - 1));
    startDate.setHours(0, 0, 0, 0);

    // Create array of dates
    const dateArray = [];
    for (let i = 0; i < parseInt(days); i++) {
      const date = new Date(startDate);
      date.setDate(date.getDate() + i);
      dateArray.push({
        date: new Date(date),
        formattedDate: date.toISOString().split('T')[0]
      });
    }

    // Get activity data from UserActivity collection
    const activityData = await UserActivity.find({
      userId: userId,
      date: { $gte: startDate, $lte: endDate }
    }).lean();

    // Map results to include all days
    const result = dateArray.map(day => {
      const dayData = activityData.find(
        activity => activity.date.toISOString().split('T')[0] === day.formattedDate
      ) || { messagesSent: 0, audioDuration: 0, videoDuration: 0 };

      return {
        date: day.formattedDate,
        messagesSent: dayData.messagesSent || 0,
        audioDuration: dayData.audioDuration || 0,
        videoDuration: dayData.videoDuration || 0
      };
    });

    // Calculate totals
    const totals = result.reduce((acc, day) => {
      return {
        messagesSent: acc.messagesSent + day.messagesSent,
        audioDuration: acc.audioDuration + day.audioDuration,
        videoDuration: acc.videoDuration + day.videoDuration
      };
    }, { messagesSent: 0, audioDuration: 0, videoDuration: 0 });

    res.json({
      success: true,
      dailyStats: result,
      totals
    });
  } catch (error) {
    console.error('Error fetching activity stats:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch activity statistics',
      error: error.message
    });
  }
});