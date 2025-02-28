// controllers/connection.controller.js
const BaseController = require('./base.controller');
const logger = require('../utils/logger');

class ConnectionController extends BaseController {
    initHandlers(socket) {
        socket.on('createRoom', () => this.createRoom(socket));
        socket.on('joinRoom', (data) => this.joinRoom(socket, data));
        socket.on('leaveRoom', () => this.leaveRoom(socket));
        socket.on('disconnect', () => this.handleDisconnect(socket));
        socket.on('requestRooms', () => this.sendRoomList(socket));
        socket.on('setPlayerName', (data) => this.setPlayerName(socket, data));
        socket.on('get_room', (data) => this.roomService.getRoom(data.roomId));
    }

    async createRoom(socket) {
        try {
            if (this.roomService.playerConnections.has(socket.id)) {
                throw new Error('ALREADY_IN_ROOM');
            }

            // logger.debug('%s', socket.id);
            const room = this.roomService.createRoom();
            // logger.debug('%s', room.id);
            socket.join(room.id);

            socket.emit('roomCreated', room.id);
            // logger.debug('%s', room.id);

            this.io.emit('roomUpdate', this.roomService.getRooms());
        } catch (error) {
            this.handleError(socket, error);
        }
    }

    async joinRoom(socket, { roomId }) {
        try {
            const room = this.roomService.joinRoom(roomId, socket.id);
            socket.join(roomId);

            const messages = this.messageService.getMessages(roomId);
            socket.emit('messageHistory', messages);

            this.io.to(roomId).emit('playerJoined', room);
            this.io.emit('roomUpdate', this.roomService.getRooms());
        } catch (error) {
            this.handleError(socket, error);
        }
    }

    async leaveRoom(socket) {
        try {
            const room = this.getRoom(socket);
            this.roomService.leaveRoom(socket.id);

            this.io.to(room.id).emit('playerLeft', socket.id);
            this.io.emit('roomUpdate', this.roomService.getRooms());
        } catch (error) {
            this.handleError(socket, error);
        }
    }

    async handleDisconnect(socket) {
        try {
            const room = this.getRoom(socket);
            this.roomService.leaveRoom(socket.id);

            this.io.to(room.id).emit('playerDisconnected', socket.id);
            this.io.emit('roomUpdate', this.roomService.getRooms());
        } catch (error) {
            logger.error(`断开连接处理失败: ${error.message}`);
        }
    }

    async sendRoomList(socket) {
        try {
            socket.emit('roomUpdate', this.roomService.getRooms());
        } catch (error) {
            this.handleError(socket, error);
        }
    }

    async setPlayerName(socket, { name }) {
        try {
            this.roomService._validatePlayerName(name);
            const player = this.getPlayer(socket);
            player.name = name;

            this.io.emit('roomUpdate', this.roomService.getRooms());
        } catch (error) {
            this.handleError(socket, error);
        }
    }
}

module.exports = ConnectionController;