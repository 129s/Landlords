const express = require('express');
const { createServer } = require('node:http');
const { Server } = require('socket.io');

const RoomService = require('./services/room.service');
const MessageService = require('./services/message.service');
const GameService = require('./services/game.service');
const logger = require('./utils/logger');

const app = express();
const server = createServer(app);
const io = new Server(server, {
    cors: {
        origin: '*',
        methods: ['GET', 'POST']
    }
});

const roomService = new RoomService();
const messageService = new MessageService();
const gameService = new GameService();

io.on('connection', (socket) => {
    logger.info(`User connected: ${socket.id}`);

    socket.on('createRoom', async () => {
        const room = roomService.createRoom(socket.id);
        socket.join(room.id);
        socket.emit('roomCreated', room.id);
        io.emit('roomUpdate', roomService.getRooms());
        logger.info(`Room created by ${socket.id}: ${room.id}`);
    });

    socket.on('joinRoom', async ({ roomId }) => {
        const room = roomService.joinRoom(roomId, socket.id);
        if (!room) {
            socket.emit('roomError', 'Failed to join room.');
            return;
        }
        socket.join(roomId);
        io.to(roomId).emit('roomUpdate', room);
        io.emit('roomUpdate', roomService.getRooms());
        logger.info(`User ${socket.id} joined room: ${roomId}`);
    });

    socket.on('leaveRoom', (roomId) => {
        socket.leave(roomId);
        // 从房间服务中移除玩家
        const room = roomService.getRoom(roomId);
        if (room) {
            room.players = room.players.filter(player => player.id !== socket.id);
        }
        // 通知房间内的其他玩家
        io.to(roomId).emit('roomUpdate', room);
        // 如果房间为空，则删除房间
        if (room && room.players.length === 0) {
            roomService.roomStore.delete(roomId);
        }
        // 更新房间列表
        io.emit('roomUpdate', roomService.getRooms());
        logger.info(`User ${socket.id} left room: ${roomId}`);
    });

    socket.on('sendMessage', ({ roomId, content }) => {
        const sender = roomService.getPlayer(socket.id);
        if (!sender) return;
        const message = messageService.addMessage(roomId, socket.id, sender.name, content);
        io.to(roomId).emit('messageUpdate', messageService.getMessages(roomId));
        logger.info(`User ${socket.id} sent message to room ${roomId}: ${content}`);
    });

    socket.on('requestRooms', () => {
        socket.emit('roomUpdate', roomService.getRooms());
    });

    socket.on('disconnect', () => {
        logger.info(`User disconnected: ${socket.id}`);
        // 清理玩家连接信息
        const conn = roomService.playerConnections.get(socket.id);
        if (conn) {
            const { roomId } = conn;
            roomService.playerConnections.delete(socket.id);
            // 从房间中移除玩家
            const room = roomService.getRoom(roomId);
            if (room) {
                room.players = room.players.filter(player => player.id !== socket.id);
                io.to(roomId).emit('roomUpdate', room);
                // 如果房间为空，则删除房间
                if (room && room.players.length === 0) {
                    roomService.roomStore.delete(roomId);
                }
                // 更新房间列表
                io.emit('roomUpdate', roomService.getRooms());
            }
        }
    });

    // 游戏逻辑相关
    socket.on('startGame', (roomId) => {
        gameService.startGame(roomId);
        io.to(roomId).emit('gameStarted', roomId);
    });

    socket.on('bidLandlord', ({ roomId, playerId, bid }) => {
        gameService.bidLandlord(roomId, playerId, bid);
        io.to(roomId).emit('landlordBidUpdate', gameService.gameStates.get(roomId));
    });

    socket.on('playCards', ({ roomId, playerId, cards }) => {
        gameService.playCards(roomId, playerId, cards);
        io.to(roomId).emit('cardsPlayed', gameService.gameStates.get(roomId));
    });
});

const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
    logger.info(`Server running on port ${PORT}`);
});