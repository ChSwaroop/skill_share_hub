require('dotenv').config();

const bcrypt = require('bcrypt');
const jwt = require("jsonwebtoken");
const dotenv = require('dotenv');

// Import the models (including the Skill model, which is exported as Skill)
const { User, Chat, Todo, ChatbotHistory, Analytics, Skill } = require('../models/user.js');

exports.registerUser = async (req, res) => {
    try {
        const {
            username,
            firstName,
            lastName,
            dateOfBirth,
            gender,
            email,
            phoneNumber,
            education,
            workExperience,
            internshipExperience,
            skills, // Expecting an array of skill names (e.g., ["JavaScript", "Node.js"])
            certifications,
            password
        } = req.body;
        console.log("register request received with user name: " + username);

        // Destructure fields from the request body according to the new schema
        if (!dateOfBirth || isNaN(Date.parse(dateOfBirth))) {
            return res.status(400).json({ error: "Invalid date format" });
        }


        // Validate for unique email, username, and phone number
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: 'User with this email already exists' });
        }

        const existingUserByUsername = await User.findOne({ username });
        if (existingUserByUsername) {
            return res.status(400).json({ message: 'Username is already taken' });
        }

        const existingUserByPhoneNumber = await User.findOne({ phoneNumber });
        if (existingUserByPhoneNumber) {
            return res.status(400).json({ message: 'User with this mobile number already exists' });
        }

        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Process skills: convert each provided skill name into its corresponding ObjectId
        let skillIds = [];
        if (skills && Array.isArray(skills)) {
            skillIds = await Promise.all(skills.map(async (skillName) => {
                // Look for an existing skill document
                let skill = await Skill.findOne({ name: skillName });
                if (!skill) {
                    // If the skill doesn't exist, create a new skill document
                    skill = new Skill({ name: skillName });
                    await skill.save();
                }
                return skill._id;
            }));
        }

        // Create and save the new user document with fields matching the new schema
        const newUser = new User({
            username,
            firstName,
            lastName,
            dateOfBirth: new Date(dateOfBirth), // Ensures proper conversion to Date
            gender,
            email,
            phoneNumber,
            password: hashedPassword,
            education,
            workExperience,
            internshipExperience,
            skills: skillIds,
            certifications,
            profilePicture: '', // You can update this later with an actual URL if needed
            bio: '',
            // Initialize the new fields
            connections: [],
            pendingConnections: [],
            lastSeen: Date.now(),
            isOnline: false,
            blockedUsers: []
        });

        await newUser.save();

        console.log("user registration success");
        const validUser = await User.findOne({
            $or: [
                { username: username }, // Check for username
                { email: email },       // Check for email
            ],
        });

        // Generate JWT token
        const token = jwt.sign(
            { userId: validUser._id, username: validUser.username },
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN || '30d' }
        );

        // Convert the user object to a plain object so we can modify it
        const userObject = validUser.toObject();

        // Transform the skills array to only contain skill names
        userObject.skills = userObject.skills.map(skill => skill.name);


        // Send success response
        console.log(validUser.email);
        return res.status(201).json({
            message: "Registration successful",
            token,
            user: userObject,
        });
    } catch (error) {
        console.error("Error registering user:", error);
        res.status(500).json({
            error: error.message || "Internal Server Error",
            loggedin: false,
        });
    }
};


// exports.registerUser = async (req, res) => {
//     try {
//         const { firstName, lastName, dateOfBirth, gender, email, phoneNumber, occupation,
//             company, education, workExperience, internshipExperience, skills, certifications, password
//         } = req.body;

//         // Use these destructured fields to handle registration logic here.

//         const existingUser = await User.findOne({ email });
//         if (existingUser) {
//             res.status(400).json({ message: 'User with this mail id already exists' });
//         }
//         // const existingUserByUsername = await User.findOne({ username });
//         // if (existingUserByUsername) {
//         //     return res.status(400).json({ message: 'Username is already taken' });
//         // }
//         const existingUserByPhoneNumber = await User.findOne({ phoneNumber });
//         if (existingUserByPhoneNumber) {
//             return res.status(400).json({ message: 'User with this mobile number  already exists' });
//         }
//         const hashedPassword = await bcrypt.hash(password, 10);
//         // Create and save the user
//         const newUser = new User({
//             firstName, lastName, dateOfBirth, gender, email, phoneNumber, occupation,
//             company, education, workExperience, internshipExperience, skills, certifications, password: hashedPassword,
//             profilePicture: '', bio: '',
//             connections: {
//                 active: [], // Active connections array
//                 pending: [], // Pending connections array
//             },
//             blockedUsers: []  // Empty array for new users
//         });

//         await newUser.save();

//         res.status(201).json({ message: "User registered successfully", loggedin: true });
//     } catch (error) {
//         console.error("Error registering user:", error);

//         // Send a consistent response to the client
//         res.status(500).json({
//             error: error.message || "Internal Server Error",
//             loggedin: false,
//         });
//     }
// };
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
        }).populate('skills'); // Populate skills if needed

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

        // Convert the user object to a plain object so we can modify it
        const userObject = validUser.toObject();

        // Transform the skills array to only contain skill names
        userObject.skills = userObject.skills.map(skill => skill.name);


        // Send success response
        console.log(validUser.email);
        return res.status(200).json({
            message: "Login successful",
            token,
            user: userObject,
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


