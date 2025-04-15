// const mongoose = require('mongoose');
// const { Schema } = mongoose;

// // Define the Feedback schema
// const feedbackSchema = new Schema({
//   user: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'User',
//     required: true
//   },
//   skill: {
//     type: String,
//     required: true,
//     trim: true
//   },
//   rating: {
//     type: Number,
//     required: true,
//     min: 1,
//     max: 5
//   },
//   comments: {
//     type: String,
//     trim: true
//   },
//   createdAt: {
//     type: Date,
//     default: Date.now
//   },
//   updatedAt: {
//     type: Date,
//     default: Date.now
//   }
// });

// // Middleware to update the updatedAt field on save
// feedbackSchema.pre('save', function(next) {
//   this.updatedAt = Date.now();
//   next();
// });

// // Create the Feedback model
// const Feedback = mongoose.model('Feedback', feedbackSchema);

// module.exports = Feedback;

// models/feedback.js
const mongoose = require('mongoose');

const feedbackSchema = new mongoose.Schema(
  {
    starRating: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    satisfactionRating: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    contentClear: {
      type: Boolean,
      required: true,
    },
    topicsCovered: {
      type: Boolean,
      required: true,
    },
    comments: {
      type: String,
      required: false,
      trim: true,
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: false, // Optional if you want to allow anonymous feedback
    },
  },
  {
    timestamps: true,
  }
);

const Feedback = mongoose.model('Feedback', feedbackSchema);
module.exports = Feedback;