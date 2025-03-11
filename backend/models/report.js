const mongoose = require('mongoose');
const { Schema } = mongoose;

// Define the Report schema
const reportSchema = new Schema({
  reporter: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  reportedUser: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  reason: {
    type: String,
    required: true,
    trim: true
  },
  status: {
    type: String,
    enum: ['pending', 'resolved', 'dismissed'],
    default: 'pending'
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Middleware to update the updatedAt field on save
reportSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Create the Report model
const Report = mongoose.model('Report', reportSchema);

module.exports = Report;