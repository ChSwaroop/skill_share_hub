// routes/chatRoutes.js
const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const { authMiddleware } = require('../utils/authMiddleware');

router.get('/:userId', chatController.getChatsByUserId);
router.post("/", authMiddleware, chatController.createChat);

module.exports = router;