const { v4: uuidv4 } = require('uuid');
const PlayerModel = require('../models/PlayerModel');
const RoomModel = require('../models/RoomModel');
const logger = require('../utils/logger');

class RoomService {
    constructor() {
        this.rooms = new Map();
        this.playerConnections = new Map(); // 跟踪玩家连接
    }

    // 修改 room.service.js 的 createRoom 方法
    createRoom(playerName, socketId) { // 添加socketId参数
        const roomId = uuidv4();
        const player = new PlayerModel(playerName, socketId); // 传入socketId
        const room = new RoomModel(roomId, [player]);

        // 建立双向关联
        this.playerConnections.set(socketId, {
            roomId,
            playerId: player.id
        });

        this.rooms.set(roomId, room);
        return room;
    }


    joinRoom(roomId, playerName, socketId) {
        const room = this.rooms.get(roomId);
        if (!room) {
            logger.warn('Attempted to join non-existent room: %s', roomId);
            throw new Error('房间不存在');
        }
        if (room.players.length >= 3) {
            logger.warn('Attempted to join full room: %s', roomId);
            throw new Error('房间已满');
        }
        const player = new PlayerModel(playerName, socketId);
        this.playerConnections.set(socketId, { roomId, player });
        room.players.push(player);
        return room;
    }

    getRooms() {
        return Array.from(this.rooms.values());
    }

    addMessage(roomId, message) {
        const room = this.rooms.get(roomId);
        if (!room) throw new Error('房间不存在');

        const newMessage = {
            id: uuidv4(),
            content: message.content,
            senderId: message.senderId,
            senderName: this._getPlayerName(message.senderId),
            timestamp: new Date().toISOString(),
            type: 'text'
        };

        room.messages = [...room.messages, newMessage].slice(-50); // 保留最近50条
        return newMessage;
    }

    _getPlayerName(socketId) {
        const connection = this.playerConnections.get(socketId);
        if (!connection) return '未知用户';
        const room = this.rooms.get(connection.roomId);
        return room.players.find(p => p.socketId === socketId)?.name;
    }
}

module.exports = RoomService;
