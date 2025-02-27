import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { RoomService } from './services/RoomService';

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
    cors: {
        origin: "*", // 生产环境需限制为前端域名
        methods: ["GET", "POST"]
    }
});

const roomService = new RoomService();

io.on('connection', (socket) => {
    console.log(`客户端连接: ${socket.id}`);

    // 玩家加入
    socket.on('joinRoom', ({ roomId, playerName }) => {
        const room = roomService.joinRoom(roomId, socket.id, playerName);
        socket.join(roomId);
        io.to(roomId).emit('roomUpdate', room);
    });

    // 创建房间
    socket.on('createRoom', (callback) => {
        const newRoom = roomService.createRoom();
        callback({ roomId: newRoom.id });
    });

    // 更多事件监听...
});

httpServer.listen(3000, () => {
    console.log('服务器运行在 3000 端口');
});