const logger = require('../utils/logger');

class MessageController {
    constructor(io, messageService, roomService) {
        this.io = io;
        this.messageService = messageService;
        this.roomService = roomService;
    }

    initHandlers(socket) {
        socket.on('sendMessage', (data) => this.handleSendMessage(socket, data));
    }

    handleSendMessage(socket, { roomId, content }) {
        try {
            const room = this.roomService.getRoom(roomId);
            if (!room) throw new Error('房间不存在');

            const player = this.roomService.getPlayer(socket.id);
            if (!player) throw new Error('未加入房间');

            const msg = this.messageService.addMessage(
                roomId,
                player.id,
                player.name,
                content
            );

            // 统一推送完整消息列表
            const messages = this.messageService.getMessages(roomId);
            this.io.to(roomId).emit('messageUpdate', messages.map(m => m.toJSON()));
        } catch (error) {
            logger.error('消息发送失败:', error);
            socket.emit('messageError', error.message);
        }
    }
}

module.exports = MessageController;