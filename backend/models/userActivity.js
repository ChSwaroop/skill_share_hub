// models/UserActivity.js

const mongoose = require('mongoose');

// Create a schema to track user activity metrics
const UserActivitySchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    date: {
        type: Date,
        required: true,
        index: true
    },
    messagesSent: {
        type: Number,
        default: 0
    },
    audioDuration: {
        type: Number, // Duration in seconds
        default: 0
    },
    videoDuration: {
        type: Number, // Duration in seconds
        default: 0
    },
    callCount: { type: Number, default: 0 },
    missedCalls: { type: Number, default: 0 },
    rejectedCalls: { type: Number, default: 0 }
});

// Compound index for efficient queries
UserActivitySchema.index({ userId: 1, date: 1 }, { unique: true });

module.exports = mongoose.model('UserActivity', UserActivitySchema);