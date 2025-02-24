// services/room.service.js

const BaseService = require('./base.service');
const { v4: uuidv4 } = require('uuid');
const RoomModel = require('../models/RoomModel');
const PlayerModel = require('../models/PlayerModel'); // 引入 PlayerModel
const logger = require('../utils/logger');

class RoomService extends BaseService {
    constructor(stateStore) {
        super(stateStore);
        this.playerConnections = new Map(); // socketId -> roomId  记录玩家和房间的对应关系
    }

    createRoom(creatorId) {
        const roomId = uuidv4();
        const newRoom = new RoomModel(roomId, []);

        this.stateStore.rooms.set(roomId, newRoom);
        logger.info(`创建房间: ${roomId}`);
        return this.joinRoom(roomId, creatorId);
    }

    joinRoom = this.withTransaction(async (roomId, socketId) => {
        this.validateRoomExists(roomId);
        const room = this.stateStore.rooms.get(roomId);

        if (room.players.length >= 3) {
            logger.error(`房间已满: ${roomId}`);
            throw new Error('ROOM_FULL');
        }

        const player = new PlayerModel(socketId);
        if (!this.stateStore.atomicAddPlayer(roomId, player)) {
            throw new Error('JOIN_ROOM_FAILED');
        }

        this.playerConnections.set(socketId, roomId); // 记录玩家和房间的对应关系

        logger.info(`玩家加入: ${socketId} -> ${roomId}`);
        return room;
    });

    leaveRoom(socketId) {
        const roomId = this.playerConnections.get(socketId); // 从playerConnections获取roomId
        if (!roomId) return;

        const room = this.stateStore.rooms.get(roomId);
        room.players = room.players.filter(p => p.id !== socketId);
        this.stateStore.connections.delete(socketId);
        this.playerConnections.delete(socketId); // 移除玩家和房间的对应关系

        if (room.players.length === 0) {
            this._cleanupEmptyRoom(roomId);
        }
    }

    _cleanupEmptyRoom(roomId) {
        this.stateStore.rooms.delete(roomId);
        this.stateStore.messages.delete(roomId);
        this.stateStore.games.delete(roomId);
        logger.info(`清理空房间: ${roomId}`);
    }

    getRoom(roomId) {
        this.validateRoomExists(roomId);
        return this.stateStore.rooms.get(roomId);
    }

    getRooms() {
        return Array.from(this.stateStore.rooms.values());
    }

    getPlayer(socketId) {
        for (const room of this.stateStore.rooms.values()) {
            const player = room.players.find(p => p.id === socketId);
            if (player) {
                return player;
            }
        }
        return null;
    }

    _validatePlayerName(name) {
        if (!name || name.length < 2 || name.length > 10) {
            throw new Error('INVALID_PLAYER_NAME');
        }
    }
}

module.exports = RoomService;
