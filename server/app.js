// index.js
const { Server } = require("socket.io");
const RoomService = require('./services/room.service');
const MessageService = require('./services/message.service');
const GameService = require('./services/game.service');
const logger = require('./utils/logger');
const CardUtils = require('./utils/card.utils');

const io = new Server({
    cors: {
        origin: "http://localhost:5173", // 允许前端的地址
        methods: ["GET", "POST"]
    }
});

const roomService = new RoomService();
const messageService = new MessageService();
const gameService = new GameService();

io.on("connection", (socket) => {
    logger.info(`用户连接: %s`, socket.id);

    socket.on('disconnect', () => {
        logger.info(`用户断开: %s`, socket.id);
        // 获取玩家所在的房间
        const room = roomService.playerConnections.get(socket.id)?.roomId;
        if (room) {
            // 移除玩家
            roomService.leaveRoom(room, socket.id);
            // 如果房间为空，则删除房间
            roomService.deleteRoomIfEmpty(room);
            // 通知房间更新
            io.emit('roomUpdate', roomService.getRooms());
        }
    });

    socket.on('createRoom', (data) => {
        try {
            // 检查玩家是否已经在房间中
            if (roomService.playerConnections.has(socket.id)) {
                logger.warn(`玩家 %s 尝试创建房间，但已在房间 %s 中`, socket.id, roomService.playerConnections.get(socket.id).roomId);
                return; // 阻止创建
            }

            const room = roomService.createRoom(socket.id);
            socket.emit('roomCreated', room.id);
            io.emit('roomUpdate', roomService.getRooms());
            logger.info(`房间 %s 创建成功，通知房间ID给 %s`, room.id, socket.id);
        } catch (e) {
            logger.error(`房间创建失败: %s`, e.message);
            socket.emit('roomCreateFailed', { message: e.message });
        }
    });

    socket.on('joinRoom', (data) => {
        const { roomId } = data;
        try {
            // 检查玩家是否已经在房间中
            if (roomService.playerConnections.has(socket.id)) {
                logger.warn(`玩家 %s 尝试加入房间 %s，但已在房间 %s 中`, socket.id, roomId, roomService.playerConnections.get(socket.id).roomId);
                return; // 阻止加入
            }

            const room = roomService.joinRoom(roomId, socket.id);
            io.emit('roomUpdate', roomService.getRooms());
            logger.info(`玩家 %s 加入房间 %s 成功`, socket.id, roomId);
        } catch (e) {
            logger.error(`玩家 %s 加入房间 %s 失败: %s`, socket.id, roomId, e.message);
            socket.emit('roomJoinFailed', { message: e.message });
        }
    });

    socket.on('leaveRoom', (roomId) => {
        try {
            roomService.leaveRoom(roomId, socket.id);
            roomService.deleteRoomIfEmpty(roomId);
            io.emit('roomUpdate', roomService.getRooms());
            logger.info(`玩家 %s 离开房间 %s 成功`, socket.id, roomId);
        } catch (e) {
            logger.error(`玩家 %s 离开房间 %s 失败: %s`, socket.id, roomId, e.message);
            socket.emit('roomLeaveFailed', { message: e.message });
        }
    });

    socket.on('requestRooms', () => {
        socket.emit('roomUpdate', roomService.getRooms());
        logger.debug(`玩家 %s 请求房间列表`, socket.id);
    });

    socket.on('setPlayerName', (data) => {
        const { name } = data;
        try {
            roomService._validatePlayerName(name);
            const player = roomService.getPlayer(socket.id);
            if (!player) {
                logger.error(`玩家 %s 不存在`, socket.id);
                return;
            }
            player.name = name;
            io.emit('roomUpdate', roomService.getRooms());
            logger.info(`玩家 %s 设置名称为 %s`, socket.id, name);
        } catch (e) {
            logger.error(`玩家 %s 设置名称失败: %s`, socket.id, e.message);
            socket.emit('playerNameSetFailed', { message: e.message });
        }
    });

    socket.on('sendMessage', (data) => {
        const { roomId, content } = data;
        try {
            const player = roomService.getPlayer(socket.id);
            if (!player) {
                logger.error(`玩家 %s 不存在`, socket.id);
                return;
            }
            const msg = messageService.addMessage(roomId, socket.id, player.name, content);
            io.emit('messageUpdate', messageService.getMessages(roomId));
            logger.info(`房间 %s 收到消息: %s 来自 %s`, roomId, content, socket.id);
        } catch (e) {
            logger.error(`房间 %s 发送消息失败: %s`, roomId, e.message);
            socket.emit('messageSendFailed', { message: e.message });
        }
    });

    socket.on('requestMessages', (data) => {
        const { roomId } = data;
        try {
            const messages = messageService.getMessages(roomId);
            socket.emit('messageUpdate', messages);
            logger.debug(`房间 %s 请求消息列表`, roomId);
        } catch (e) {
            logger.error(`房间 %s 请求消息列表失败: %s`, roomId, e.message);
            socket.emit('messageRequestFailed', { message: e.message });
        }
    });

    socket.on('startGame', (roomId) => {
        try {
            const room = roomService.getRoom(roomId);
            if (!room) {
                logger.error(`房间 %s 不存在`, roomId);
                return;
            }
            if (room.players.length !== 3) {
                logger.error(`房间 %s 人数不足，无法开始游戏`, roomId);
                return;
            }
            gameService.startGame(roomId, room.players.map(p => p.id));
            const gameState = gameService.gameStates.get(roomId);
            io.emit('gameStarted', gameState);
            logger.info(`房间 %s 游戏开始`, roomId);
        } catch (e) {
            logger.error(`房间 %s 游戏开始失败: %s`, roomId, e.message);
            socket.emit('gameStartFailed', { message: e.message });
        }
    });

    socket.on('playCards', (data) => {
        const { roomId, cards } = data;
        try {
            const state = gameService.playCards(roomId, socket.id, cards);
            io.emit('gameStateUpdate', state);
            logger.info(`房间 %s 玩家 %s 出牌`, roomId, socket.id);
        } catch (e) {
            logger.error(`房间 %s 玩家 %s 出牌失败: %s`, roomId, socket.id, e.message);
            socket.emit('playCardsFailed', { message: e.message });
        }
    });

    socket.on('passTurn', (roomId) => {
        try {
            const state = gameService.passTurn(roomId, socket.id);
            io.emit('gameStateUpdate', state);
            logger.info(`房间 %s 玩家 %s 选择不出牌`, roomId, socket.id);
        } catch (e) {
            logger.error(`房间 %s 玩家 %s 选择不出牌失败: %s`, roomId, socket.id, e.message);
            socket.emit('passTurnFailed', { message: e.message });
        }
    });
});

io.listen(3000);

logger.info('socket.io server listening on port 3000');
