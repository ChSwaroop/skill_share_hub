const mongoose = require('mongoose');
const { Schema } = mongoose;

// Define the Community schema
const communitySchema = new Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    trim: true
  },
  members: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    }
  ],
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
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
communitySchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Create the Community model
const Community = mongoose.model('Community', communitySchema);

module.exports = Community;