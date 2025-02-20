const express = require('express');
const { createServer } = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const app = express();
app.use(cors()); // 允许跨域

const httpServer = createServer(app);
const io = new Server(httpServer, {
    cors: {
        origin: "*", // 允许所有前端连接
        methods: ["GET", "POST"]
    }
});

// 房间存储
const rooms = new Map();

io.on('connection', (socket) => {
    console.log(`客户端连接: ${socket.id}`);

    // 创建房间
    socket.on('createRoom', (playerName) => {
        const roomId = Math.random().toString(36).substr(2, 6);
        rooms.set(roomId, {
            players: [{ id: socket.id, name: playerName }],
            gameState: null
        });

        socket.join(roomId);
        socket.emit('roomCreated', roomId);
        console.log(`房间 ${roomId} 已创建`);
    });

    // 加入房间
    socket.on('joinRoom', ({ roomId, playerName }) => {
        const room = rooms.get(roomId);
        if (!room) return socket.emit('error', '房间不存在');

        room.players.push({ id: socket.id, name: playerName });
        socket.join(roomId);
        io.to(roomId).emit('playerJoined', room.players);
        console.log(`${playerName} 加入房间 ${roomId}`);
    });

    // 转发游戏操作
    socket.on('gameAction', (action) => {
        const room = [...socket.rooms].find(room => room !== socket.id);
        if (room) {
            socket.to(room).emit('gameUpdate', action);
        }
    });
});

httpServer.listen(3000, () => {
    console.log('服务器运行在 http://localhost:3000');
});