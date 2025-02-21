const express = require('express');
const { createServer } = require('node:http');
const { Server } = require('socket.io');
const cors = require('cors');

// 初始化服务器
const app = express();
app.use(cors());
const server = createServer(app);
const io = new Server(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

// 临时存储游戏数据
const rooms = new Map();

// 房间管理类
class RoomManager {
    static createRoom(player) {
        const roomId = Math.random().toString(36).substr(2, 6).toUpperCase();
        rooms.set(roomId, {
            players: [player],
            landlord: null,
            currentPlayer: null,
            lastPlayedCards: [],
            deck: []
        });
        return roomId;
    }

    static joinRoom(roomId, player) {
        const room = rooms.get(roomId);
        if (room && room.players.length < 3) {
            room.players.push(player);
            return true;
        }
        return false;
    }
}

// Socket事件处理
io.on('connection', (socket) => {
    console.log(`用户连接: ${socket.id}`);

    // 创建房间
    socket.on('createRoom', (playerName) => {
        const player = { id: socket.id, name: playerName, cards: [] };
        const roomId = RoomManager.createRoom(player);
        socket.join(roomId);
        socket.emit('roomCreated', roomId);
    });

    // 加入房间
    socket.on('joinRoom', ({ roomId, playerName }) => {
        const success = RoomManager.joinRoom(roomId, {
            id: socket.id,
            name: playerName,
            cards: []
        });

        if (success) {
            socket.join(roomId);
            io.to(roomId).emit('roomUpdate', rooms.get(roomId));
        } else {
            socket.emit('error', '加入房间失败');
        }
    });
});

// 启动服务器
server.listen(3000, () => {
    console.log('服务器运行在 http://localhost:3000');
});