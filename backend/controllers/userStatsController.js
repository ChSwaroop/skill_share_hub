// controllers/userStatsController.js
const { User, Message } = require('../models/user');
// const  = require('../models/Message');
const Call = require('../models/Call');
const mongoose = require('mongoose');

// console.log("models: " + mongoose.models)
/**
 * Get message count by day for the past 7 days
 */
exports.getMessageStats = async (req, res) => {
    try {
        const userId = req.params.userId;

        // Calculate date range (past 7 days)
        const endDate = new Date();
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - 6); // Get 7 days including today

        // Initialize result array with dates and zero counts
        const result = [];
        for (let i = 0; i < 7; i++) {
            const date = new Date(startDate);
            date.setDate(date.getDate() + i);
            result.push({
                date: date.toISOString().split('T')[0],
                count: 0
            });
        }

        // Aggregate message counts by day
        const messages = await Message.aggregate([
            {
                $match: {
                    sender: new mongoose.Types.ObjectId(userId),
                    createdAt: { $gte: startDate, $lte: endDate }
                }
            },
            {
                $group: {
                    _id: {
                        year: { $year: "$createdAt" },
                        month: { $month: "$createdAt" },
                        day: { $dayOfMonth: "$createdAt" }
                    },
                    count: { $sum: 1 }
                }
            },
            {
                $sort: { "_id.year": 1, "_id.month": 1, "_id.day": 1 }
            }
        ]);

        // Update counts in result array
        messages.forEach(msg => {
            const msgDate = new Date(msg._id.year, msg._id.month - 1, msg._id.day);
            const dateStr = msgDate.toISOString().split('T')[0];

            const resultItem = result.find(item => item.date === dateStr);
            if (resultItem) {
                resultItem.count = msg.count;
            }
        });

        return res.status(200).json({
            success: true,
            data: result
        });
    } catch (error) {
        console.error('Error in getMessageStats:', error);
        return res.status(500).json({
            success: false,
            message: 'Failed to retrieve message statistics',
            error: error.message
        });
    }
};

/**
 * Get call duration by day for the past 7 days
 */
exports.getCallStats = async (req, res) => {
    try {
        const userId = req.params.userId;
        const callType = req.query.type || 'all'; // 'audio', 'video', or 'all'

        // Calculate date range (past 7 days)
        const endDate = new Date();
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - 6); // Get 7 days including today

        // Initialize result array with dates and zero durations
        const result = [];
        for (let i = 0; i < 7; i++) {
            const date = new Date(startDate);
            date.setDate(date.getDate() + i);
            result.push({
                date: date.toISOString().split('T')[0],
                audioDuration: 0,
                videoDuration: 0,
                totalDuration: 0
            });
        }

        // Prepare match condition based on call type
        const matchCondition = {
            $or: [
                { caller: new mongoose.Types.ObjectId(userId) },
                { receiver: new mongoose.Types.ObjectId(userId) }
            ],
            status: 'completed',
            startTime: { $gte: startDate, $lte: endDate }
        };

        if (callType !== 'all') {
            matchCondition.callType = callType;
        }

        // Aggregate call durations by day and type
        const calls = await Call.aggregate([
            {
                $match: matchCondition
            },
            {
                $group: {
                    _id: {
                        year: { $year: "$startTime" },
                        month: { $month: "$startTime" },
                        day: { $dayOfMonth: "$startTime" },
                        callType: "$callType"
                    },
                    totalDuration: { $sum: "$duration" }
                }
            },
            {
                $sort: { "_id.year": 1, "_id.month": 1, "_id.day": 1 }
            }
        ]);

        // Update durations in result array
        calls.forEach(call => {
            const callDate = new Date(call._id.year, call._id.month - 1, call._id.day);
            const dateStr = callDate.toISOString().split('T')[0];

            const resultItem = result.find(item => item.date === dateStr);
            if (resultItem) {
                if (call._id.callType === 'audio') {
                    resultItem.audioDuration = call.totalDuration;
                } else if (call._id.callType === 'video') {
                    resultItem.videoDuration = call.totalDuration;
                }
                resultItem.totalDuration = resultItem.audioDuration + resultItem.videoDuration;
            }
        });

        return res.status(200).json({
            success: true,
            data: result
        });
    } catch (error) {
        console.error('Error in getCallStats:', error);
        return res.status(500).json({
            success: false,
            message: 'Failed to retrieve call statistics',
            error: error.message
        });
    }
};

/**
 * Get comprehensive user activity stats (messages and calls) for past 7 days
 */
exports.getUserActivityStats = async (req, res) => {
    try {
        const userId = req.params.userId;

        // Calculate date range (past 7 days)
        const endDate = new Date();
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - 6); // Get 7 days including today

        // Initialize result array with dates and zero counts/durations
        const result = [];
        for (let i = 0; i < 7; i++) {
            const date = new Date(startDate);
            date.setDate(date.getDate() + i);
            result.push({
                date: date.toISOString().split('T')[0],
                messageCount: 0,
                audioDuration: 0,
                videoDuration: 0,
                totalCallDuration: 0
            });
        }

        // 1. Get message counts
        const messages = await Message.aggregate([
            {
                $match: {
                    sender: mongoose.Types.ObjectId(userId),
                    createdAt: { $gte: startDate, $lte: endDate }
                }
            },
            {
                $group: {
                    _id: {
                        year: { $year: "$createdAt" },
                        month: { $month: "$createdAt" },
                        day: { $dayOfMonth: "$createdAt" }
                    },
                    count: { $sum: 1 }
                }
            }
        ]);

        // 2. Get call durations
        const calls = await Call.aggregate([
            {
                $match: {
                    $or: [
                        { caller: mongoose.Types.ObjectId(userId) },
                        { receiver: mongoose.Types.ObjectId(userId) }
                    ],
                    status: 'completed',
                    startTime: { $gte: startDate, $lte: endDate }
                }
            },
            {
                $group: {
                    _id: {
                        year: { $year: "$startTime" },
                        month: { $month: "$startTime" },
                        day: { $dayOfMonth: "$startTime" },
                        callType: "$callType"
                    },
                    totalDuration: { $sum: "$duration" }
                }
            }
        ]);

        // Update message counts in result
        messages.forEach(msg => {
            const msgDate = new Date(msg._id.year, msg._id.month - 1, msg._id.day);
            const dateStr = msgDate.toISOString().split('T')[0];

            const resultItem = result.find(item => item.date === dateStr);
            if (resultItem) {
                resultItem.messageCount = msg.count;
            }
        });

        // Update call durations in result
        calls.forEach(call => {
            const callDate = new Date(call._id.year, call._id.month - 1, call._id.day);
            const dateStr = callDate.toISOString().split('T')[0];

            const resultItem = result.find(item => item.date === dateStr);
            if (resultItem) {
                if (call._id.callType === 'audio') {
                    resultItem.audioDuration = call.totalDuration;
                } else if (call._id.callType === 'video') {
                    resultItem.videoDuration = call.totalDuration;
                }
                resultItem.totalCallDuration = resultItem.audioDuration + resultItem.videoDuration;
            }
        });

        return res.status(200).json({
            success: true,
            data: result
        });
    } catch (error) {
        console.error('Error in getUserActivityStats:', error);
        return res.status(500).json({
            success: false,
            message: 'Failed to retrieve user activity statistics',
            error: error.message
        });
    }
};