const mongoose = require('mongoose');
require('dotenv').config(); // Ensure dotenv is loaded

const connectMongoDB = async () => {
  try {
    console.log('MongoDB URI:', process.env.MONGODB_URI); // Log to check the value
    await mongoose.connect(process.env.MONGODB_URI); // No options needed in latest driver version
    console.log('MongoDB connected');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
};

module.exports = connectMongoDB; // Export the connectMongoDB function
