// controllers/message.controller.js
const BaseController = require('./base.controller');

class MessageController extends BaseController {
    initHandlers(socket) {
        socket.on('sendMessage', (data) => this.sendMessage(socket, data));
        socket.on('requestMessages', () => this.sendMessageHistory(socket));
    }

    async sendMessage(socket, { content }) {
        try {
            const player = this.getPlayer(socket);
            const room = this.getRoom(socket);

            const message = this.messageService.addMessage(
                room.id,
                player.id,
                player.name,
                content
            );

            this.io.to(room.id).emit('newMessage', message);
        } catch (error) {
            this.handleError(socket, error);
        }
    }

    async sendMessageHistory(socket) {
        try {
            const room = this.getRoom(socket);
            const messages = this.messageService.getMessages(room.id);
            socket.emit('messageHistory', messages);
        } catch (error) {
            this.handleError(socket, error);
        }
    }
}

module.exports = MessageController;