const { v4: uuidv4 } = require('uuid');
const PlayerModel = require('../models/PlayerModel');
const RoomModel = require('../models/RoomModel');
const logger = require('../utils/logger');

class RoomService {
    constructor() {
        this.roomStore = new Map();
        this.playerConnections = new Map(); // socketId -> { roomId, playerId }
    }

    createRoom(socketId) {
        const roomId = uuidv4();
        const player = new PlayerModel(socketId, socketId); // Use socketId as player ID and name
        const room = new RoomModel(roomId, [player]);

        this.playerConnections.set(socketId, {
            roomId,
            playerId: player.id
        });

        this.roomStore.set(roomId, room);
        return room;
    }

    joinRoom(roomId, socketId) {
        const room = this.getRoom(roomId);
        if (!room) {
            logger.error('房间不存在');
            return null;
        }
        if (room.players.length >= 3) {
            logger.error('房间已满');
            return null;
        }

        const player = new PlayerModel(socketId, socketId); // Use socketId as player ID and name
        this.playerConnections.set(socketId, { roomId, playerId: player.id });
        room.players.push(player);
        return room;
    }

    getRoom(roomId) {
        return this.roomStore.get(roomId);
    }

    getPlayer(socketId) {
        const conn = this.playerConnections.get(socketId);
        if (!conn) return null;
        const room = this.getRoom(conn.roomId);
        return room?.players.find(p => p.id === conn.playerId);
    }

    deleteRoomIfEmpty(roomId) {
        const room = this.getRoom(roomId);
        if (room && room.players.length === 0) {
            this.roomStore.delete(roomId);
            return true;
        }
        return false;
    }

    getRooms() {
        return Array.from(this.roomStore.values());
    }
}

module.exports = RoomService;

