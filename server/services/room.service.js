const PlayerModel = require('../models/PlayerModel');
const RoomModel = require('../models/RoomModel');
const logger = require('../utils/logger');
const { v4: uuidv4 } = require('uuid');

class RoomService {
    constructor() {
        this.roomStore = new Map();
        this.playerConnections = new Map(); // socketId -> { roomId }
    }

    createRoom(socketId) {
        const roomId = uuidv4();
        const player = new PlayerModel(socketId);

        this.playerConnections.set(socketId, { roomId });
        const room = new RoomModel(roomId, [player]);

        this.roomStore.set(roomId, room);
        logger.info(`房间创建: ${roomId} 创建者: ${socketId}`);
        return room;
    }

    joinRoom(roomId, socketId) {
        const room = this.roomStore.get(roomId);
        if (!room) logger.error('房间不存在');
        if (room.players.length >= 3) logger.error('房间已满');

        // 名称冲突检查改为检查socketId是否已存在
        if (room.players.some(p => p.id === socketId)) {
            logger.error('玩家已在此房间');
        }

        const player = new PlayerModel(socketId);
        this.playerConnections.set(socketId, { roomId });
        room.players.push(player);

        logger.info(`玩家加入: ${socketId} 进入房间: ${roomId}`);
        return room;
    }

    // 玩家名验证
    _validatePlayerName(name) {
        if (!name || name.trim().length === 0) {
            logger.error('玩家名不能为空');
        }
        if (name.length > 12) {
            logger.error('玩家名最长12个字符');
        }
        if (/[^a-zA-Z0-9\u4e00-\u9fa5]/.test(name)) {
            logger.error('玩家名包含非法字符');
        }
    }

    getPlayer(socketId) {
        const conn = this.playerConnections.get(socketId);
        if (!conn) return null;
        const room = this.getRoom(conn.roomId);
        return room?.players.find(p => p.id === socketId);
    }

    deleteRoomIfEmpty(roomId) {
        const room = this.getRoom(roomId);
        if (room && room.players.length === 0) {
            this.roomStore.delete(roomId);
            return true;
        }
        return false;
    }

    getRoom(roomId) {
        return this.roomStore.get(roomId);
    }

    getRooms() {
        return Array.from(this.roomStore.values());
    }
}

module.exports = RoomService;