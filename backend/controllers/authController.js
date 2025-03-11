// controllers/authController.js
// const bcrypt = require('bcryptjs');
// const jwt = require('jsonwebtoken');
// const User = require('../models/user');
require('dotenv').config();

const { User, Chat, Todo, Feedback, ChatbotHistory, Analytics } = require('../models/user.js');
const bcrypt = require('bcrypt');
const jwt = require("jsonwebtoken");
const dotenv = require('dotenv');
// dotenv.config();

exports.registerUser = async (req, res) => {
    try {
        const { firstName, lastName, dateOfBirth, gender, email, phoneNumber, occupation,
            company, education, workExperience, internshipExperience, skills, certifications, password
        } = req.body;

        // Use these destructured fields to handle registration logic here.

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            res.status(400).json({ message: 'User with this mail id already exists' });
        }
        // const existingUserByUsername = await User.findOne({ username });
        // if (existingUserByUsername) {
        //     return res.status(400).json({ message: 'Username is already taken' });
        // }
        const existingUserByPhoneNumber = await User.findOne({ phoneNumber });
        if (existingUserByPhoneNumber) {
            return res.status(400).json({ message: 'User with this mobile number  already exists' });
        }
        const hashedPassword = await bcrypt.hash(password, 10);
        // Create and save the user
        const newUser = new User({
            firstName, lastName, dateOfBirth, gender, email, phoneNumber, occupation,
            company, education, workExperience, internshipExperience, skills, certifications, password: hashedPassword,
            profilePicture: '', bio: '',
            connections: {
                active: [], // Active connections array
                pending: [], // Pending connections array
            },
            blockedUsers: []  // Empty array for new users
        });

        await newUser.save();

        res.status(201).json({ message: "User registered successfully", loggedin: true });
    } catch (error) {
        console.error("Error registering user:", error);

        // Send a consistent response to the client
        res.status(500).json({
            error: error.message || "Internal Server Error",
            loggedin: false,
        });
    }
};
exports.loginUser = async (req, res) => {
    try {
        const { username, password } = req.body;
        const email = username; // Assuming username can also be an email
        console.log(username, password);

        // Find user by username or email
        const validUser = await User.findOne({
            $or: [
                { username: username }, // Check for username
                { email: email },       // Check for email
            ],
        });

        // If user not found, return error
        if (!validUser) {
            return res.status(401).json({ message: "User credentials are wrong" }); // Return early
        }

        // Validate the password
        const isPasswordValid = await bcrypt.compare(password, validUser.password);
        if (!isPasswordValid) {
            return res.status(401).json({ message: "Invalid username or password" }); // Return early
        }

        console.log("valid user: " + validUser);

        // Generate JWT token
        const token = jwt.sign(
            { userId: validUser._id, username: validUser.username },
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN || '30d' }
        );

        // Send success response
        console.log(validUser.email);
        return res.status(200).json({
            message: "Login successful",
            token,
        });
    } catch (error) {
        console.error("Error during login:", error);

        // Send a consistent error response
        return res.status(500).json({
            error: error.message || "Internal Server Error",
            loggedin: false,
        });
    }
};
// module.exports = { Register, Login }

// Register a new user
// exports.registerUser = async (req, res) => {
//     const { username, email, password } = req.body;
//     try {
//         // Check if email already exists
//         const existingUser = await User.findOne({ email });
//         if (existingUser) {
//             return res.status(400).json({ message: 'Email is already registered.' });
//         }

//         // Hash the password and create a new user
//         const hashedPassword = await bcrypt.hash(password, 10);
//         const user = new User({ username, email, password: hashedPassword });
//         await user.save();

//         // Log to verify this line is reached
//         console.log("User registered successfully");

//         // Send a response with the success message
//         return res.status(201).json({ message: 'User registered successfully' });
//     } catch (err) {
//         console.error('Error registering user:', err);
//         res.status(500).json({ message: 'Server error' });
//     }
// };


// Login a user
// exports.loginUser = async (req, res) => {
//     const { email, password } = req.body;
//     try {
//         console.log('Login attempt:', email, password); // Log email and password input
//         const user = await User.findOne({ email });
//         console.log('User found:', user); // Check if user is found in the database

//         if (user && await bcrypt.compare(password, user.password)) {
//             const token = jwt.sign(
//                 { userId: user._id },
//                 process.env.JWT_SECRET,
//                 { expiresIn: process.env.JWT_EXPIRES_IN || '30d' }
//             );
//             res.json({ token });
//         } else {
//             console.log('Invalid credentials');
//             res.status(400).json({ message: 'Invalid credentials' });
//         }
//     } catch (err) {
//         console.error('Error during login:', err);
//         res.status(500).json({ message: 'Server error' });
//     }
// };

// Optional: Get user profile
exports.getUserProfile = async (req, res) => {
    console.log("entered profile")
    try {
        const user = await User.findById(req.user.userId).select('-password');
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.json(user);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error' });
    }
};


