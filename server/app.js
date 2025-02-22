const express = require('express');
const http = require('http');
const { Server } = require("socket.io");
const cors = require('cors');

const socketController = require('./controllers/socket.controller');
const roomService = require('./services/room.service');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
    cors: {
        origin: "http://localhost:5173", // 允许前端访问的地址
        methods: ["GET", "POST"]
    }
});

app.use(cors());
app.use(express.json());

// 初始化 RoomService
global.roomService = new roomService();

// 注册 Socket 事件
socketController.handleSocketEvents(io);

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
});
