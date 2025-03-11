const jwt = require('jsonwebtoken');
const { User } = require('../models/user'); // Ensure the case matches your model file

// Middleware to verify the JWT token
const authMiddleware = async (req, res, next) => {
    // Extract the token from the 'Authorization' header
    const token = req.headers.authorization?.split(" ")[1];

    if (!token) {
        return res.status(401).json({ message: "Access denied. No token provided." });
    }

    try {
        // Verify token and decode the payload
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded; // Add the decoded user data to the request object for use in the route
        console.log("user: ", decoded);
        // Check if the user still exists in the database
        const user = await User.findById(decoded.userId); // Ensure 'userId' matches the payload key
        if (!user) {
            return res.status(401).json({ message: "Access denied. User does not exist." });
        }

        // Log success for debugging
        console.log(`User authenticated: ${user.username}`);

        next(); // Proceed to the next middleware/route handler
    } catch (error) {
        console.error("JWT Verification Error:", error);
        return res.status(400).json({ message: "Invalid token." });
    }
};

// Middleware to restrict access to admin users
const adminMiddleware = async (req, res, next) => {
    // Check if user exists and if the role is admin
    if (req.user && req.user.role === 'admin') {
        return next(); // Proceed to the next middleware/route handler
    } else {
        return res.status(403).json({ message: "Access denied. Admins only." });
    }
};

module.exports = { authMiddleware, adminMiddleware };
