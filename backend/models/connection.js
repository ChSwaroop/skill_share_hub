const mongoose = require('mongoose');

const ConnectionSchema = new mongoose.Schema({
    requesterId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    recipientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    status: { type: String, enum: ['pending', 'accepted', 'rejected', 'cancelled'], default: 'pending' },
    message: { type: String },
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now },
    lastActive: { type: Date },
    totalMessageCount: { type: Number, default: 0 },
    totalAudioCallDuration: { type: Number, default: 0 },
    totalVideoCallDuration: { type: Number, default: 0 }
});

ConnectionSchema.index({ requesterId: 1, status: 1 });
ConnectionSchema.index({ recipientId: 1, status: 1 });
ConnectionSchema.index({ createdAt: -1 });

module.exports = mongoose.model('Connection', ConnectionSchema);