// controllers/todoController.js
const { Todo } = require('../models/user');
const admin = require('firebase-admin');

// Get all todos for a user
exports.getTodos = async (req, res) => {
    try {
        const todos = await Todo.find({ user: req.user.userId }).sort({ createdAt: -1 });

        res.status(200).json({ success: true, count: todos.length, data: todos });
    } catch (error) {
        console.error('Error fetching todos:', error);
        res.status(500).json({ success: false, error: 'Server Error' });
    }
};

// Get a single todo
exports.getTodo = async (req, res) => {
    try {
        const todo = await Todo.findById(req.params.id);

        if (!todo) {
            return res.status(404).json({ success: false, error: 'Todo not found' });
        }

        // Check if the user is authorized to view this todo
        if (todo.user.toString() !== req.user.userId) {
            return res.status(403).json({ success: false, error: 'Not authorized to access this todo' });
        }

        res.status(200).json({ success: true, data: todo });
    } catch (error) {
        console.error('Error fetching todo:', error);
        res.status(500).json({ success: false, error: 'Server Error' });
    }
};

// Create a new todo
exports.createTodo = async (req, res) => {
    try {
        // Add user to req.body
        req.body.user = req.user.userId;

        const todo = await Todo.create(req.body);

        // Schedule reminder checks for the due date
        // if (todo.dueDate) {
        //     scheduleReminderChecks(todo, req.user.fcmToken);
        // }

        res.status(201).json({ success: true, data: todo });
    } catch (error) {
        console.error('Error creating todo:', error);
        if (error.name === 'ValidationError') {
            const messages = Object.values(error.errors).map(val => val.message);
            return res.status(400).json({ success: false, error: messages });
        }
        res.status(500).json({ success: false, error: 'Server Error' });
    }
};

// Update a todo
exports.updateTodo = async (req, res) => {
    try {
        let todo = await Todo.findById(req.params.id);

        if (!todo) {
            return res.status(404).json({ success: false, error: 'Todo not found' });
        }

        // Check if user is owner
        if (todo.user.toString() !== req.user.userId) {
            return res.status(403).json({ success: false, error: 'Not authorized to update this todo' });
        }

        const oldDueDate = todo.dueDate ? new Date(todo.dueDate).getTime() : null;
        const newDueDate = req.body.dueDate ? new Date(req.body.dueDate).getTime() : null;

        // Reset notification flags if due date changes
        if (newDueDate && (!oldDueDate || oldDueDate !== newDueDate)) {
            req.body.notificationSent = {
                fifteenMin: false,
                fiveMin: false
            };
        }

        todo = await Todo.findByIdAndUpdate(req.params.id, req.body, {
            new: true,
            runValidators: true
        });

        // If due date changed or is new, schedule reminders
        if (newDueDate && (!oldDueDate || oldDueDate !== newDueDate)) {
            scheduleReminderChecks(todo, req.user.fcmToken);
        }

        res.status(200).json({ success: true, data: todo });
    } catch (error) {
        console.error('Error updating todo:', error);
        if (error.name === 'ValidationError') {
            const messages = Object.values(error.errors).map(val => val.message);
            return res.status(400).json({ success: false, error: messages });
        }
        res.status(500).json({ success: false, error: 'Server Error' });
    }
};

// Get the count of todos for a user
exports.getTodoCount = async (req, res) => {
    try {
        const userId = req.user.userId;

        const count = await Todo.countDocuments({ user: userId });

        res.status(200).json({ success: true, count });
    } catch (error) {
        console.error('Error counting todos:', error);
        res.status(500).json({ success: false, error: 'Server Error' });
    }
};


// Delete a todo
exports.deleteTodo = async (req, res) => {
    try {
        const todo = await Todo.findById(req.params.id);

        if (!todo) {
            return res.status(404).json({ success: false, error: 'Todo not found' });
        }

        // Check if user is owner
        if (todo.user.toString() !== req.user.userId) {
            return res.status(403).json({ success: false, error: 'Not authorized to delete this todo' });
        }

        await todo.deleteOne();

        res.status(200).json({ success: true, data: {} });
    } catch (error) {
        console.error('Error deleting todo:', error);
        res.status(500).json({ success: false, error: 'Server Error' });
    }
};

// Mark a todo as completed
exports.completeTodo = async (req, res) => {
    console.log("completion TODO: " + req.params.id);
    try {
        let todo = await Todo.findById(req.params.id);

        if (!todo) {
            return res.status(404).json({ success: false, error: 'Todo not found' });
        }

        // Check if user is owner
        if (todo.user.toString() !== req.user.userId) {
            return res.status(403).json({ success: false, error: 'Not authorized to update this todo' });
        }

        todo = await Todo.findByIdAndUpdate(
            req.params.id,
            { completed: true },
            { new: true }
        );
        console.log("TODO updated");

        res.status(200).json({ success: true, data: todo });
    } catch (error) {
        console.error('Error completing todo:', error);
        res.status(500).json({ success: false, error: 'Server Error' });
    }
};

// Helper functions for Firebase notifications
const scheduleReminderChecks = (todo, fcmToken) => {
    const dueDate = new Date(todo.dueDate).getTime();
    const now = Date.now();

    // If due date is in the past, don't schedule reminders
    if (dueDate <= now) {
        return;
    }

    // Schedule 15-minute reminder check
    const fifteenMinBefore = dueDate - (15 * 60 * 1000);
    const timeUntilFifteenMin = fifteenMinBefore - now;

    if (timeUntilFifteenMin > 0) {
        setTimeout(() => {
            sendReminderNotification(todo, fcmToken, 15);
        }, timeUntilFifteenMin);
    }

    // Schedule 5-minute reminder check
    const fiveMinBefore = dueDate - (5 * 60 * 1000);
    const timeUntilFiveMin = fiveMinBefore - now;

    if (timeUntilFiveMin > 0) {
        setTimeout(() => {
            sendReminderNotification(todo, fcmToken, 5);
        }, timeUntilFiveMin);
    }
};

const sendReminderNotification = async (todo, fcmToken, minutes) => {
    try {
        // Check if todo still exists and is not completed
        const currentTodo = await Todo.findById(todo._id);

        if (!currentTodo || currentTodo.completed) {
            return; // Todo was deleted or already completed
        }

        // Check if this notification was already sent
        const notificationField = minutes === 15 ? 'fifteenMin' : 'fiveMin';

        if (currentTodo.notificationSent[notificationField]) {
            return; // Notification already sent
        }

        // Send Firebase notification
        const message = {
            notification: {
                title: `Task Due Soon: ${currentTodo.title}`,
                body: `Your task is due in ${minutes} minutes!`
            },
            token: fcmToken
        };

        await admin.messaging().send(message);

        // Update the notification sent flag
        const update = {
            [`notificationSent.${notificationField}`]: true
        };

        await Todo.findByIdAndUpdate(currentTodo._id, update);

        console.log(`${minutes}-minute reminder sent for todo: ${currentTodo._id}`);
    } catch (error) {
        console.error(`Error sending ${minutes}-minute reminder:`, error);
    }
};

// Check for upcoming todos and send notifications
exports.checkUpcomingTodos = async () => {
    try {
        const now = new Date();
        const fifteenMinLater = new Date(now.getTime() + 15 * 60 * 1000);
        const fiveMinLater = new Date(now.getTime() + 5 * 60 * 1000);

        // Find todos due in the next 15 minutes that haven't had 15-min notification
        const fifteenMinTodos = await Todo.find({
            completed: false,
            dueDate: { $lte: fifteenMinLater },
            'notificationSent.fifteenMin': false
        }).populate('user', 'fcmToken');

        // Send 15-minute notifications
        for (const todo of fifteenMinTodos) {
            if (todo.user && todo.user.fcmToken) {
                await sendReminderNotification(todo, todo.user.fcmToken, 15);
            }
        }

        // Find todos due in the next 5 minutes that haven't had 5-min notification
        const fiveMinTodos = await Todo.find({
            completed: false,
            dueDate: { $lte: fiveMinLater },
            'notificationSent.fiveMin': false
        }).populate('user', 'fcmToken');

        // Send 5-minute notifications
        for (const todo of fiveMinTodos) {
            if (todo.user && todo.user.fcmToken) {
                await sendReminderNotification(todo, todo.user.fcmToken, 5);
            }
        }

    } catch (error) {
        console.error('Error checking upcoming todos:', error);
    }
};