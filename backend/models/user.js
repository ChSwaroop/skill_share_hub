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
  dateOfBirth: { type: String, required: true },
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
  skills: [{ type: String }], // Array of skill tags
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

// Chat Schema
const ChatSchema = new mongoose.Schema({
  members: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }], // Members in the chat
  isGroupChat: { type: Boolean, default: false },
  groupName: { type: String }, // Only for group chats
  messages: [{
    sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    content: { type: String },
    timestamp: { type: Date, default: Date.now }
  }]
});

// TODO Schema
const TodoSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  tasks: [{
    task: { type: String },
    isCompleted: { type: Boolean, default: false },
    createdAt: { type: Date, default: Date.now }
  }]
});

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

//connection-schema

const ConnectionSchema = new mongoose.Schema({
  requester: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  recipient: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  skill: { type: mongoose.Schema.Types.ObjectId, ref: 'Skill', required: false },
  status: { type: String, enum: ['pending', 'accepted', 'rejected', 'cancelled'], default: 'pending' },
  message: { type: String },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
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
  Connection: mongoose.model('Connections', ConnectionSchema),
};
