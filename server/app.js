const { Server } = require("socket.io");
const RoomService = require('./services/room.service');
const MessageService = require('./services/message.service');
const GameService = require('./services/game.service');
const logger = require('./utils/logger');

const roomService = new RoomService();
const messageService = new MessageService();
const gameService = new GameService();

const io = new Server(3000, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

io.on('connection', (socket) => {
    logger.info(`用户连接: %s`, socket.id);

    socket.on('createRoom', (data) => {
        try {
            const room = roomService.createRoom(socket.id);
            socket.join(room.id);
            socket.emit('roomCreated', room.id);
            io.emit('roomUpdate', roomService.getRooms());
            logger.info(`房间 %s 创建成功，创建者 %s`, room.id, socket.id);
        } catch (error) {
            logger.error(`创建房间失败: %s`, error.message);
            socket.emit('roomCreateFailed', { error: error.message });
        }
    });

    socket.on('joinRoom', (data) => {
        const { roomId, socketId } = data;
        try {
            const room = roomService.joinRoom(roomId, socketId);
            socket.join(roomId);
            io.to(roomId).emit('roomUpdate', room);
            io.emit('roomUpdate', roomService.getRooms());
            logger.info(`玩家 %s 加入房间 %s`, socketId, roomId);
        } catch (error) {
            logger.error(`加入房间 %s 失败: %s`, roomId, error.message);
            socket.emit('roomJoinFailed', { error: error.message });
        }
    });

    socket.on('leaveRoom', (roomId) => {
        try {
            socket.leave(roomId);
            const player = roomService.getPlayer(socket.id);
            if (player) {
                const room = roomService.getRoom(roomId);
                room.players = room.players.filter(p => p.id !== socket.id);
                logger.info(`玩家 %s 离开房间 %s`, socket.id, roomId);

                if (roomService.deleteRoomIfEmpty(roomId)) {
                    messageService.purgeRoomMessages(roomId);
                    logger.info(`房间 %s 已删除，因为它是空的`, roomId);
                } else {
                    io.to(roomId).emit('roomUpdate', room);
                }
                io.emit('roomUpdate', roomService.getRooms());
            }
        } catch (error) {
            logger.error(`离开房间 %s 失败: %s`, roomId, error.message);
            socket.emit('roomLeaveFailed', { error: error.message });
        }
    });

    socket.on('requestRooms', () => {
        socket.emit('roomUpdate', roomService.getRooms());
    });

    socket.on('sendMessage', (data) => {
        const { roomId, content, socketId } = data;
        try {
            const player = roomService.getPlayer(socketId);
            if (!player) {
                logger.error(`找不到玩家 %s 在房间 %s`, socketId, roomId);
                return;
            }
            const message = messageService.addMessage(roomId, socketId, player.name, content);
            io.to(roomId).emit('messageUpdate', messageService.getMessages(roomId));
            logger.info(`房间 %s 收到消息: %s 来自 %s`, roomId, content, socketId);
        } catch (error) {
            logger.error(`发送消息到房间 %s 失败: %s`, roomId, error.message);
            socket.emit('messageSendFailed', { error: error.message });
        }
    });

    socket.on('disconnect', () => {
        logger.info(`用户断开连接: %s`, socket.id);
        try {
            const conn = roomService.playerConnections.get(socket.id);
            if (conn) {
                const { roomId } = conn;
                const room = roomService.getRoom(roomId);
                if (room) {
                    room.players = room.players.filter(p => p.id !== socket.id);
                    if (roomService.deleteRoomIfEmpty(roomId)) {
                        messageService.purgeRoomMessages(roomId);
                        logger.info(`房间 %s 已删除，因为它是空的`, roomId);
                    } else {
                        io.to(roomId).emit('roomUpdate', room);
                    }
                    io.emit('roomUpdate', roomService.getRooms());
                }
                roomService.playerConnections.delete(socket.id);
            }
        } catch (error) {
            logger.error(`断开连接处理失败: %s`, error.message);
        }
    });

    socket.on('startGame', (roomId) => {
        try {
            gameService.startGame(roomId);
            const state = gameService.gameStates.get(roomId);
            io.to(roomId).emit('gameStarted', state);
            logger.info(`房间 %s 游戏开始`, roomId);
        } catch (error) {
            logger.error(`房间 %s 游戏开始失败: %s`, roomId, error.message);
            socket.emit('gameStartFailed', { error: error.message });
        }
    });

    socket.on('bidLandlord', (data) => {
        const { roomId, socketId, bid } = data;
        try {
            gameService.bidLandlord(roomId, socketId, bid);
            const state = gameService.gameStates.get(roomId);
            io.to(roomId).emit('bidUpdated', state);
            logger.info(`房间 %s 玩家 %s 叫地主，状态: %s`, roomId, socketId, bid);
        } catch (error) {
            logger.error(`房间 %s 玩家 %s 叫地主失败: %s`, roomId, socketId, error.message);
            socket.emit('bidFailed', { error: error.message });
        }
    });

    socket.on('playCards', (data) => {
        const { roomId, socketId, cards } = data;
        try {
            gameService.playCards(roomId, socketId, cards);
            const state = gameService.gameStates.get(roomId);
            io.to(roomId).emit('cardsPlayed', state);
            logger.info(`房间 %s 玩家 %s 出牌`, roomId, socketId);
        } catch (error) {
            logger.error(`房间 %s 玩家 %s 出牌失败: %s`, roomId, socketId, error.message);
            socket.emit('playCardsFailed', { error: error.message });
        }
    });
});

logger.info('Socket.IO 服务器启动');
