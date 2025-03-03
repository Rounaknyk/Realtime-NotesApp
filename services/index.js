require('dotenv').config();
const express = require("express");
const authRouter = require("./routers/auth_router");
const nRouter = require("./routers/auth_router");
const mongoose = require("mongoose");
const bodyParser = require('body-parser');
const userRouter = require('./routers/user_router');
const http = require('http');
const { Server } = require('socket.io');
const cors = require("cors");

// MongoDB configuration
const PORT = process.env.PORT || 3000;
const IP = process.env.IP || "0.0.0.0";
const dbUrl = process.env.MONGODB_URI;

// Initialize Express app
const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Add CORS middleware BEFORE your routes
app.use(cors());

// Other middleware
app.use(express.json());
app.use(bodyParser.json());

// WebSocket setup
io.on('connection', (socket) => {
  console.log('New client connected:', socket.id);

  socket.on('join-notes-room', (userId) => {
    socket.join(`user-${userId}`);
    console.log(`User ${userId} joined their notes room`);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

// Routes
app.use(authRouter);
app.use(userRouter);
//app.use(nRouter);

// Note router needs access to io
const noteRouterWithIo = require('./routers/note_router')(io);
app.use(noteRouterWithIo);

// Start server
server.listen(PORT, IP, () => {
  console.log(`Listening to PORT: ${PORT} at IP: ${IP}`);
});

// Connect to MongoDB
mongoose.connect(dbUrl).then(() => {
  console.log("Connected to MongoDB");
}).catch((e) => {
  console.log(`MongoDB connection error: ${e}`);
});