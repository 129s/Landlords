// controllers/base.controller.js
const logger = require('../utils/logger');

class BaseController {
    constructor(io, roomService, messageService, gameService) {
        this.io = io;
        this.roomService = roomService;
        this.messageService = messageService;
        this.gameService = gameService;
    }

    getPlayer(socket) {
        const player = this.roomService.getPlayer(socket.id);
        if (!player) throw new Error('PLAYER_NOT_FOUND');
        return player;
    }

    getRoom(socket) {
        const roomId = this.roomService.playerConnections.get(socket.id);
        if (!roomId) throw new Error('NOT_IN_ROOM');
        return this.roomService.getRoom(roomId);
    }

    handleError(socket, error) {
        logger.error(`操作失败: ${error.message}`);
        socket.emit('operation_failed', {
            code: error.code || 'UNKNOWN_ERROR',
            message: error.message
        });
    }
}

module.exports = BaseController;