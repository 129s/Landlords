const express = require('express');
const http = require('http');
const { Server } = require("socket.io");
const cors = require('cors');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
    cors: { origin: "http://localhost:5173", methods: ["GET", "POST"] }
});

// 初始化服务
const RoomService = require('./services/room.service');
const MessageService = require('./services/message.service');
global.roomService = new RoomService();
global.messageService = new MessageService();
const GameService = require('./services/game.service');
const GameController = require('./controllers/game.controller');
global.gameService = new GameService();
const gameController = new GameController(io, global.gameService, global.roomService);
io.on('connection', socket => gameController.initHandlers(socket));

// 初始化控制器
const { handleSocketEvents } = require('./controllers/socket.controller');
const MessageController = require('./controllers/message.controller');
const messageController = new MessageController(io, global.messageService, global.roomService);

// 设置事件处理
handleSocketEvents(io, global.roomService, global.messageService);
io.on('connection', socket => messageController.initHandlers(socket));

// 启动服务器
server.listen(3000, () => console.log('Server running on port 3000'));