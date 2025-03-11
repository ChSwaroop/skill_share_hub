const express = require('express');
const router = express.Router();

// Example token for Agora (this should ideally be generated dynamically)
const tempToken = '007eJxTYEhaxH7GTONn0D+Li66Wy24c/SPscIXZP86Et1/8aFWQQaUCg4mFgbmFZYqBUWpaiompZUpiskFScqqJebKRoUlKmnHqR0G19IZARoaITbKsjAwQCOJzMZRlpqTmKyQn5uQwMAAAoHAf4Q==';

// Route to get the video token
router.get('/token', (req, res) => {
  res.json({ token: tempToken });
});

module.exports = router;
