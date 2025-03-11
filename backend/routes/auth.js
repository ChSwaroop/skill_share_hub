// routes/auth.js
const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController'); // Ensure this path is correct
const { authMiddleware } = require('../utils/authMiddleware'); // Import the auth middleware

// User registration route
router.post('/register', authController.registerUser); // This route can be public

// User login route
router.post('/login', authController.loginUser); // This route can be public

// Protected route example: Get user profile
router.get('/profile', authMiddleware, authController.getUserProfile); // Example of a protected route

// Optionally, you could add more protected routes here
// router.get('/some-other-protected-route', authMiddleware, authController.someOtherMethod);

module.exports = router;
