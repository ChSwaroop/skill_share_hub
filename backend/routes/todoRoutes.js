// routes/todoRoutes.js
const express = require('express');
const router = express.Router();
const {
    getTodos,
    getTodo,
    createTodo,
    updateTodo,
    deleteTodo,
    completeTodo,
    getTodoCount
} = require('../controllers/todoController');
const { authMiddleware } = require('../utils/authMiddleware');

// Apply authentication middleware to all routes
router.use(authMiddleware);

router
    .route('/')
    .get(getTodos)
    .post(createTodo);

router
    .route('/count')
    .get(getTodoCount)

router
    .route('/:id')
    .get(getTodo)
    .put(updateTodo)
    .delete(deleteTodo);

router
    .route('/:id/complete')
    .put(completeTodo);

module.exports = router;