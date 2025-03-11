const express = require('express');
const router = express.Router();
const callController = require('../controllers/callController');
const authMiddleware = require('../utils/authMiddleware');

// Route to initiate a new call
router.post('/initiate', authMiddleware, callController.initiateCall);

// Route to join an existing call
router.post('/join/:callId', authMiddleware, callController.joinCall);

// Route to end an existing call
router.post('/end/:callId', authMiddleware, callController.endCall);

// Route to get call history for a user
router.get('/history', authMiddleware, callController.getCallHistory);

module.exports = router;