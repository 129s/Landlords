import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { RoomController } from './controllers/RoomController';
import { GamePhase } from './constants/constants';

const app = express();
const server = createServer(app);
const io = new Server(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

// 初始化房间控制器
const roomController = new RoomController(io);

// 启动服务器
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`服务已启动在端口 ${PORT}
  当前时间: ${new Date().toLocaleString()}
  `);
});