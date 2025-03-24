// utils/notificationScheduler.js
const cron = require('node-cron');
const { checkUpcomingTodos } = require('../controllers/todoController');

// Initialize cron job to check for upcoming todos every minute
const startNotificationScheduler = () => {
    cron.schedule('* * * * *', async () => {
        await checkUpcomingTodos();
    });

    console.log('Notification scheduler started');
};

module.exports = startNotificationScheduler;