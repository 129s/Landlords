const BaseService = require('./base.service');
const { v4: uuidv4 } = require('uuid');
const RoomModel = require('../models/RoomModel');
const PlayerModel = require('../models/PlayerModel'); // 引入 PlayerModel
const logger = require('../utils/logger');
class RoomService extends BaseService {
    constructor(stateStore, gameService) {
        super(stateStore);
        this.gameService = gameService; // 保存引用
        this.playerConnections = new Map(); // socketId -> roomId  记录玩家和房间的对应关系
    }

    createRoom() {
        const roomId = uuidv4();
        const newRoom = new RoomModel(roomId, []);
        newRoom.status = 'PREPARING'; // 新增状态字段

        this.stateStore.rooms.set(roomId, newRoom);
        logger.info(`创建房间: ${roomId}`);
        return newRoom;
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
        if (room.players.length === 3) {
            room.status = 'STARTING'; // 满员时变更状态
            await this.gameService.startGame(roomId);
        } else {
            room.status = 'PREPARING'; // 未满员保持准备状态
        }
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
            return;
        }
        if (room.players.length < 3) {
            room.status = 'PREPARING'; // 玩家退出后检查人数
            this.io.emit('room_update', this.getRooms());
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
