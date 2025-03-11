require('dotenv').config();
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const connectMongoDB = require('./config/db');
const authRoutes = require('./routes/auth');
const messageRoutes = require('./routes/message');
const userRoutes = require('./routes/user');
const User = require('./models/user');
const SkillProgress = require('./models/skillProgress');


const app = express();
const server = http.createServer(app);
const io = socketIo(server);

// Middleware
app.use(express.json());
app.use('/api/auth', authRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/users', userRoutes);

// Simple Route for Testing
app.get('/', (req, res) => {
  res.send('Server is up and running!');
});

// Socket.io for real-time messaging
io.on('connection', (socket) => {
  console.log('New client connected');

  socket.on('sendMessage', (message) => {
    io.emit('receiveMessage', message);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected');
  });
});

// Temporary token for Agora video calls
const AGORA_TEMP_TOKEN = '007eJxTYEhaxH7GTONn0D+Li66Wy24c/SPscIXZP86Et1/8aFWQQaUCg4mFgbmFZYqBUWpaiompZUpiskFScqqJebKRoUlKmnHqR0G19IZARoaITbKsjAwQCOJzMZRlpqTmKyQn5uQwMAAAoHAf4Q==';

app.get('/api/video/token', (req, res) => {
  res.json({ token: AGORA_TEMP_TOKEN });
});

// Temporary token for Agora chat
const AGORA_CHAT_TEMP_TOKEN = '007eJxTYFhe+aOX9dzq7e0M840bWZ/kJ+29GML1Iens2qM73/q/9w5QYDCxMDC3sEwxMEpNSzExtUxJTDZISk41MU82MjRJSTNONTBUS28IZGTYFLKOgZGBFYiZGEB8BgYACpgfHg==';

app.get('/api/message/token', (req, res) => {
  res.json({ token: AGORA_CHAT_TEMP_TOKEN });
});


// Sample Data Insertion Function
const insertSampleData = async () => {
  try {
    await User.deleteMany({});
    await SkillProgress.deleteMany({});

    const users = await User.insertMany([
      { username: 'Alice', email: 'alice@example.com', password: 'hashed_password_1' },
      { username: 'Bob', email: 'bob@example.com', password: 'hashed_password_2' },
    ]);

    await SkillProgress.insertMany([
      { user: users[0]._id, skill: 'JavaScript', level: 'Beginner', progress: 20 },
      { user: users[1]._id, skill: 'Python', level: 'Intermediate', progress: 45 },
    ]);

    console.log('Sample data inserted successfully');
  } catch (error) {
    console.error('Error inserting sample data:', error);
  }
};

// Connect to MongoDB and start server
const startServer = async () => {
  try {
    await connectMongoDB(); // Connect to MongoDB
    // await insertSampleData(); // Insert sample data
    const PORT = process.env.PORT || 3000;
    server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();

