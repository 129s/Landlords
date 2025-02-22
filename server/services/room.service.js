// server/services/room.service.js
const { v4: uuidv4 } = require('uuid');
const PlayerModel = require('../models/PlayerModel');
const RoomModel = require('../models/RoomModel');
const logger = require('../utils/logger'); // 引入 logger

class RoomService {
    constructor() {
        this.rooms = new Map(); // 使用内存存储活跃房间
    }

    createRoom(roomName, creator) {
        const roomId = uuidv4();
        const player = new PlayerModel(creator); // creator is UserModel now
        const room = new RoomModel(roomId, [player], roomName);
        this.rooms.set(roomId, room);
        logger.debug('Created room with ID: %s', roomId);
        return room;
    }

    joinRoom(roomId, user) { // user is UserModel now
        const room = this.rooms.get(roomId);
        if (!room) {
            logger.warn('Attempted to join non-existent room: %s', roomId);
            throw new Error('房间不存在');
        }
        if (room.players.length >= 3) {
            logger.warn('Attempted to join full room: %s', roomId);
            throw new Error('房间已满');
        }
        const player = new PlayerModel(user);
        room.players.push(player);
        logger.debug('Player %s joined room %s', user.username, roomId);
        return room;
    }

    getRooms() {
        return Array.from(this.rooms.values());
    }
}

module.exports = RoomService;
