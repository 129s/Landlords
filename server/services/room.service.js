// services\room.service.js
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
        // 检查玩家是否已经在房间中
        if (this.playerConnections.has(socketId)) {
            logger.warn(`玩家 %s 尝试创建房间，但已在房间 %s 中`, socketId, this.playerConnections.get(socketId).roomId);
            throw new Error('Player already in a room');
        }

        const roomId = uuidv4();
        const player = new PlayerModel(socketId);

        this.playerConnections.set(socketId, { roomId });
        const room = new RoomModel(roomId, [player]);

        this.roomStore.set(roomId, room);
        logger.info(`房间创建: %s 创建者: %s`, roomId, socketId);
        return room;
    }

    joinRoom(roomId, socketId) {
        const room = this.roomStore.get(roomId);
        if (!room) {
            logger.error(`房间 %s 不存在`, roomId);
            throw new Error('Room not found');
        }
        if (room.players.length >= 3) {
            logger.error(`房间 %s 已满`, roomId);
            throw new Error('Room is full');
        }

        // 检查玩家是否已经在房间中
        if (this.playerConnections.has(socketId)) {
            logger.warn(`玩家 %s 尝试加入房间 %s，但已在房间 %s 中`, socketId, roomId, this.playerConnections.get(socketId).roomId);
            throw new Error('Player already in a room');
        }

        // 名称冲突检查改为检查socketId是否已存在
        if (room.players.some(p => p.id === socketId)) {
            logger.error(`玩家 %s 已在此房间`, socketId);
            throw new Error('Player already in this room');
        }

        const player = new PlayerModel(socketId);
        this.playerConnections.set(socketId, { roomId });
        room.players.push(player);

        logger.info(`玩家加入: %s 进入房间: %s`, socketId, roomId);
        return room;
    }

    leaveRoom(roomId, socketId) {
        const room = this.getRoom(roomId);
        if (!room) {
            logger.error(`房间 %s 不存在`, roomId);
            throw new Error('Room not found');
        }

        room.players = room.players.filter(p => p.id !== socketId);
        this.playerConnections.delete(socketId);

        logger.info(`玩家 %s 离开房间 %s`, socketId, roomId);
    }

    // 玩家名验证
    _validatePlayerName(name) {
        if (!name || name.trim().length === 0) {
            logger.error('玩家名不能为空');
            throw new Error('Player name cannot be empty');
        }
        if (name.length > 12) {
            logger.error('玩家名最长12个字符');
            throw new Error('Player name is too long');
        }
        if (/[^a-zA-Z0-9\u4e00-\u9fa5]/.test(name)) {
            logger.error('玩家名包含非法字符');
            throw new Error('Player name contains invalid characters');
        }
    }

    getPlayer(socketId) {
        const conn = this.playerConnections.get(socketId);
        if (!conn) {
            logger.warn(`找不到玩家 %s 的连接信息`, socketId);
            return null;
        }
        const room = this.getRoom(conn.roomId);
        return room?.players.find(p => p.id === socketId);
    }

    deleteRoomIfEmpty(roomId) {
        const room = this.getRoom(roomId);
        if (room && room.players.length === 0) {
            this.roomStore.delete(roomId);
            logger.info(`房间 %s 已删除，因为它是空的`, roomId);
            return true;
        }
        return false;
    }

    getRoom(roomId) {
        const room = this.roomStore.get(roomId);
        if (!room) {
            logger.warn(`房间 %s 不存在`, roomId);
        }
        return room;
    }

    getRooms() {
        const rooms = Array.from(this.roomStore.values());
        logger.debug(`获取房间列表，数量: %s`, rooms.length);
        return rooms;
    }
}

module.exports = RoomService;
