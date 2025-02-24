const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const logger = require('./utils/logger');
const StateStore = require('./services/state.store');
const RoomService = require('./services/room.service');
const MessageService = require('./services/message.service');
const GameService = require('./services/game.service');
const ConnectionController = require('./controllers/connection.controller');
const GameController = require('./controllers/game.controller');
const MessageController = require('./controllers/message.controller');

// 初始化Express应用
const app = express();
const server = http.createServer(app);
const PORT = process.env.PORT || 3000;

// 配置Socket.io
const io = new Server(server, {
    cors: {
        origin: "*", // 根据实际需要配置允许的域名
        methods: ["GET", "POST"]
    },
    connectionStateRecovery: {
        maxDisconnectionDuration: 2 * 60 * 1000 // 2分钟断线恢复
    }
});

// 初始化核心服务
const stateStore = new StateStore();
const roomService = new RoomService(stateStore);
const messageService = new MessageService(stateStore);
const gameService = new GameService(stateStore);

// 初始化控制器
const controllers = {
    connection: new ConnectionController(io, roomService, messageService, gameService),
    game: new GameController(io, roomService, messageService, gameService),
    message: new MessageController(io, roomService, messageService, gameService)
};

// Socket.io连接处理
io.on('connection', (socket) => {
    logger.info(`新的客户端连接: ${socket.id}`);

    // 初始化所有控制器的事件监听
    Object.values(controllers).forEach(controller => {
        if (controller.initHandlers) {
            controller.initHandlers(socket);
        }
    });

    // 连接断开处理
    socket.on('disconnect', (reason) => {
        logger.warn(`客户端断开连接: ${socket.id}，原因: ${reason}`);
    });
});

// 启动服务器
server.listen(PORT, () => {
    logger.info(`服务器运行在 http://localhost:${PORT}`);
    logger.info(`Socket.io 端点: ws://localhost:${PORT}/socket.io/`);
});

