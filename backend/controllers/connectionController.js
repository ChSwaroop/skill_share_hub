const Connection = require('../models/connection');
const { User, Skill } = require('../models/user.js');
const mongoose = require('mongoose');

// Get all connections for the current user
exports.getMyConnections = async (req, res) => {
    try {
        const userId = req.user.userId;
        const { status, page = 1, limit = 20 } = req.query;

        let filter = { $or: [{ requesterId: userId }, { recipientId: userId }] };

        if (status) {
            filter.status = status;
        }

        const skip = (parseInt(page) - 1) * parseInt(limit);

        const connections = await Connection.find(filter)
            .sort({ updatedAt: -1 })
            .skip(skip)
            .limit(parseInt(limit))
            .populate('recipientId', 'username profilePicture')
            .populate('requesterId', 'username profilePicture')

        const total = await Connection.countDocuments(filter);

        res.status(200).json({
            success: true,
            count: connections.length,
            total,
            totalPages: Math.ceil(total / parseInt(limit)),
            currentPage: parseInt(page),
            userId: req.user.userId,
            data: connections
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

// Get the count of connections for a user
exports.getConnectionCount = async (req, res) => {
    try {
        const userId = req.user.userId;
        console.log("userId: " + userId);

        const count = await Connection.countDocuments({
            $or: [
                { requesterId: userId },
                { recipientId: userId }
            ]
        });

        res.status(200).json({ success: true, count });
    } catch (error) {
        console.log("Error in connections count: " + error);
        res.status(500).json({ success: false, error: error.message });
    }
};


// Get a single connection by ID
exports.getConnection = async (req, res) => {
    try {
        const { connectionId } = req.params;
        const userId = req.user.userId;

        const connection = await Connection.findById(connectionId)
            .populate('recipientId', 'username profilePicture bio location')
            .populate('requesterId', 'username profilePicture bio location')
            .populate('skillId', 'name category description');

        if (!connection || (connection.requesterId.toString() !== userId && connection.recipientId.toString() !== userId)) {
            return res.status(404).json({ success: false, error: 'Connection not found or unauthorized' });
        }

        res.status(200).json({ success: true, data: connection });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

// Create a new connection request
exports.createConnection = async (req, res) => {
    try {
        const { recipientId, connectionNotes } = req.body;
        const requesterId = req.user.userId;

        console.log("connection request received: ", recipientId);

        if (!recipientId) {
            return res.status(400).json({ success: false, error: 'Please provide recipientId and skillId' });
        }

        const recipient = await User.findById(recipientId).select('skills');
        if (!recipient || recipientId === requesterId) {
            return res.status(400).json({ success: false, error: 'Invalid recipient or skill' });
        }

        const existingConnection = await Connection.findOne({
            $or: [{ requesterId, recipientId }, { requesterId: recipientId, recipientId: requesterId }],
            status: { $in: ['pending', 'accepted'] }
        });

        if (existingConnection) {
            return res.status(400).json({ success: false, error: 'Connection already exists' });
        }

        const connection = await Connection.create({
            requesterId,
            recipientId,
            message: connectionNotes,
            status: 'pending',
            createdAt: Date.now(),
            updatedAt: Date.now()
        });
        console.log("new connection created")

        await User.findByIdAndUpdate(requesterId, { $push: { pendingConnections: recipientId } });
        await User.findByIdAndUpdate(recipientId, { $push: { pendingConnections: requesterId } });


        const populatedConnection = await Connection.findById(connection._id)
            .populate('recipientId', 'username profilePicture')
            .populate('requesterId', 'username profilePicture')

        res.status(201).json({ success: true, data: populatedConnection });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

// Update connection status (accept/reject/cancel)
exports.updateConnectionStatus = async (req, res) => {
    try {
        const { connectionId } = req.params;
        const { status } = req.body;
        const userId = req.user.userId;

        if (!['accepted', 'rejected', 'cancelled'].includes(status)) {
            return res.status(400).json({ success: false, error: 'Invalid status' });
        }

        const connection = await Connection.findById(connectionId);
        if (!connection) {
            return res.status(404).json({ success: false, error: 'Connection not found' });
        }

        if ((status === 'accepted' || status === 'rejected') && connection.recipientId.toString() !== userId) {
            return res.status(403).json({ success: false, error: 'Unauthorized' });
        }

        if (status === 'cancelled' && connection.recipientId.toString() !== userId && connection.requesterId.toString() !== userId) {
            return res.status(403).json({ success: false, error: 'Unauthorized' });
        }

        if ((status === 'accepted' || status === 'rejected') && connection.status !== 'pending') {
            return res.status(400).json({ success: false, error: 'Invalid operation' });
        }

        if (status === 'cancelled' && !['pending', 'accepted'].includes(connection.status)) {
            return res.status(400).json({ success: false, error: 'Invalid operation' });
        }

        connection.status = status;
        connection.updatedAt = Date.now();
        await connection.save();
        console.log("connection accepted");

        if (status === 'accepted') {
            await User.findByIdAndUpdate(connection.requesterId, {
                $pull: { pendingConnections: connection.recipientId },
                $push: { connections: connection.recipientId }
            });

            await User.findByIdAndUpdate(connection.recipientId, {
                $pull: { pendingConnections: connection.requesterId },
                $push: { connections: connection.requesterId }
            });
        }

        if (status === 'rejected' || status === 'cancelled') {
            await User.findByIdAndUpdate(connection.requesterId, { $pull: { pendingConnections: connection.recipientId } });
            await User.findByIdAndUpdate(connection.recipientId, { $pull: { pendingConnections: connection.requesterId } });
        }


        const populatedConnection = await Connection.findById(connection._id)
            .populate('recipientId', 'username profilePicture')
            .populate('requesterId', 'username profilePicture')

        res.status(200).json({ success: true, data: populatedConnection });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

// // Get user connections using connectionIds from User schema
// exports.getUserConnections = async (req, res) => {
//     try {
//         const userId = req.user.userId;
//         const user = await User.findById(userId).populate({
//             path: 'connectionIds',
//             populate: [{ path: 'recipientId', select: 'username profilePicture' }, { path: 'requesterId', select: 'username profilePicture' }, { path: 'skillId


// Delete connection
exports.deleteConnection = async (req, res) => {
    try {
        const { connectionId } = req.params;
        const userId = req.user.userId;

        // Find the connection
        const connection = await Connection.findById(connectionId);

        if (!connection) {
            return res.status(404).json({
                success: false,
                error: 'Connection not found'
            });
        }

        // Check if user is authorized to delete this connection
        if (connection.requesterId.toString() !== userId &&
            connection.recipientId.toString() !== userId) {
            return res.status(403).json({
                success: false,
                error: 'Unauthorized to delete this connection'
            });
        }

        // Get the other user's ID
        const otherUserId = connection.requesterId.toString() === userId
            ? connection.recipientId
            : connection.requesterId;

        // Delete the connection
        await Connection.findByIdAndDelete(connectionId);

        // Remove connection references from both users
        await User.findByIdAndUpdate(userId, {
            $pull: {
                connections: otherUserId,
                pendingConnections: otherUserId
            }
        });

        await User.findByIdAndUpdate(otherUserId, {
            $pull: {
                connections: userId,
                pendingConnections: userId
            }
        });

        res.status(200).json({
            success: true,
            message: 'Connection deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
};