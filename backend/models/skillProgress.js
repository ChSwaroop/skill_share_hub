const mongoose = require('mongoose');
const { Schema } = mongoose;

// Define the Skill Progress schema
const skillProgressSchema = new Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  skill: {
    type: String,
    required: true,
    trim: true
  },
  level: {
    type: String,
    enum: ['Beginner', 'Intermediate', 'Advanced'], // Define skill levels
    required: true
  },
  progress: {
    type: Number,
    required: true,
    min: 0,
    max: 100 // Progress should be between 0 and 100
  },
  lastUpdated: {
    type: Date,
    default: Date.now
  },
  notes: {
    type: String,
    trim: true // Optional notes about skill progress
  }
});

// Create the SkillProgress model
const SkillProgress = mongoose.model('SkillProgress', skillProgressSchema);

module.exports = SkillProgress;
