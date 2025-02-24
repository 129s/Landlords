// services/base.service.js
const logger = require('../utils/logger');

class BaseService {
    constructor(stateStore) {
        this.stateStore = stateStore;
    }

    validateRoomExists(roomId) {
        if (!this.stateStore.rooms.has(roomId)) {
            logger.error(`房间不存在: ${roomId}`);
            throw new Error('ROOM_NOT_FOUND');
        }
    }

    validatePlayerInRoom(socketId, roomId) {
        const playerRoom = this.stateStore.connections.get(socketId);
        if (playerRoom !== roomId) {
            logger.warn(`玩家不在指定房间: ${socketId} -> ${roomId}`);
            throw new Error('PLAYER_NOT_IN_ROOM');
        }
    }

    withTransaction(callback) {
        return async (...args) => {
            try {
                return await callback(...args);
            } catch (error) {
                logger.error(`事务操作失败: ${error.message}`);
                throw error;
            }
        };
    }
}

module.exports = BaseService;