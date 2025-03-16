const express = require('express');
const router = express.Router();
const connectionController = require('../controllers/connectionController');
const { authMiddleware } = require('../utils/authMiddleware');

// Get all connections for the logged-in user
router.get('/', authMiddleware, connectionController.getMyConnections);

// Get a single connection by ID
router.get('/:connectionId', authMiddleware, connectionController.getConnection);

// Create a new connection request
router.post('/', authMiddleware, connectionController.createConnection);

// Update connection status (Accept, Reject, Cancel)
router.put('/:connectionId/status', authMiddleware, connectionController.updateConnectionStatus);

module.exports = router;
