// const mongoose = require('mongoose');
// const { Schema } = mongoose;

// Define the User schema
// const userSchema = new Schema({
//   username: {
//     type: String,
//     required: true,
//     unique: true,
//     trim: true
//   },
//   email: {
//     type: String,
//     required: true,
//     unique: true,
//     trim: true,
//     lowercase: true
//   },
//   password: {
//     type: String,
//     required: true
//   },
//   skills: [{
//     type: String,
//     trim: true
//   }],
//   blockedUsers: [{
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'User'
//   }],
//   profilePicture: {
//     type: String,
//     default: 'default-profile.png' // Provide a default profile picture
//   },
//   createdAt: {
//     type: Date,
//     default: Date.now
//   }
// });

// // Create the User model
// const User = mongoose.model('User', userSchema);

// module.exports = User;

const mongoose = require('mongoose');

// User Schema

const UserSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  dateOfBirth: { type: Date, required: true },
  gender: { type: String, enum: ['Male', 'Female', 'Other'], required: true },
  email: { type: String, required: true, unique: true },
  phoneNumber: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  // occupation: { type: String },
  // company: { type: String },
  education: [{
    level: String,
    startDate: String,
    endDate: String,
  }], // List of educational qualifications
  workExperience: [{
    role: String,
    // company: String,
    // startDate: Date,
    // endDate: Date
  }],
  internshipExperience: [{
    role: String,
    // company: String,
    // startDate: Date,
    // endDate: Date
  }],
  skills: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Skill' }], // Array of skill tags
  certifications: [{
    title: String,
  }],
  // connections: {
  //   active: [
  //     {
  //       userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  //       connectedAt: { type: Date, default: Date.now },
  //     },
  //   ],
  //   pending: [
  //     {
  //       userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  //       requestedAt: { type: Date, default: Date.now },
  //     },
  //   ],
  // },
  connections: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  pendingConnections: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  fcmToken: { type: String },
  lastSeen: { type: Date, default: Date.now },
  isOnline: { type: Boolean, default: false },
  blockedUsers: [
    {
      userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
      blockedAt: { type: Date, default: Date.now },
    },
  ],
  profilePicture: { type: String }, // URL for profile picture
  bio: { type: String },
  createdAt: { type: Date, default: Date.now }
});

const SkillSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true },
  category: { type: String }, // Optional: You can categorize skills (e.g., "Technical", "Soft Skills")
  description: { type: String }, // Optional: Brief description of the skill
  createdAt: { type: Date, default: Date.now }
});


// Chat Schema
// const ChatSchema = new mongoose.Schema({
//   members: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }], // Members in the chat
//   isGroupChat: { type: Boolean, default: false },
//   groupName: { type: String }, // Only for group chats
//   messages: [{
//     sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
//     content: { type: String },
//     timestamp: { type: Date, default: Date.now }
//   }]
// });

const ChatSchema = new mongoose.Schema({
  _id: mongoose.Schema.Types.ObjectId,
  chatType: { type: String, enum: ['direct', 'group'], required: true },
  participants: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  name: { type: String }, // Only required for group chats
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  admins: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }], // Only for group chats
  lastMessage: { type: mongoose.Schema.Types.ObjectId, ref: 'Message' },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// MESSAGE SCHEMA
const MessageSchema = new mongoose.Schema({
  _id: mongoose.Schema.Types.ObjectId,
  chatId: { type: mongoose.Schema.Types.ObjectId, ref: 'Chat', required: true },
  sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  content: { type: String, required: true },
  contentType: { type: String, enum: ['text', 'image', 'file'], default: 'text' },
  fileUrl: { type: String }, // Optional, for image/file sharing
  status: {
    type: String,
    enum: ['sent', 'delivered', 'read'],
    default: 'sent'
  },
  readBy: [{
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    readAt: { type: Date }
  }],
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// TODO Schema
// const TodoSchema = new mongoose.Schema({
//   userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
//   tasks: [{
//     task: { type: String },
//     isCompleted: { type: Boolean, default: false },
//     createdAt: { type: Date, default: Date.now }
//   }]
// });
// models/Todo.js

const TodoSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  title: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    trim: true
  },
  completed: {
    type: Boolean,
    default: false
  },
  dueDate: {
    type: Date
  },
  notificationSent: {
    fifteenMin: {
      type: Boolean,
      default: false
    },
    fiveMin: {
      type: Boolean,
      default: false
    }
  }
}, { timestamps: true });


// Feedback Schema
const FeedbackSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  feedbackText: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

// Chatbot History Schema
const ChatbotHistorySchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  interactions: [{
    query: { type: String },
    response: { type: String },
    timestamp: { type: Date, default: Date.now }
  }]
});

// Analytics Schema
const AnalyticsSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  progressTracking: {
    skillName: String,
    hoursSpent: Number,
    progressPercentage: Number
  },
  engagementMetrics: {
    chatsInitiated: { type: Number, default: 0 },
    connectionsMade: { type: Number, default: 0 },
    tasksCompleted: { type: Number, default: 0 }
  }
});

module.exports = {
  User: mongoose.model('User', UserSchema),
  Chat: mongoose.model('Chat', ChatSchema),
  Todo: mongoose.model('Todo', TodoSchema),
  Feedback: mongoose.model('Feedback', FeedbackSchema),
  ChatbotHistory: mongoose.model('ChatbotHistory', ChatbotHistorySchema),
  Analytics: mongoose.model('Analytics', AnalyticsSchema),
  Skill: mongoose.model('Skill', SkillSchema),
  Message: mongoose.model('Message', MessageSchema),
};
