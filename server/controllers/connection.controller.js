// controllers/connection.controller.js
const BaseController = require('./base.controller');
const logger = require('../utils/logger');

class ConnectionController extends BaseController {
    initHandlers(socket) {
        socket.on('create_room', () => this.createRoom(socket));
        socket.on('join_room', (data) => this.joinRoom(socket, data));
        socket.on('leave_room', () => this.leaveRoom(socket));
        socket.on('disconnect', () => this.handleDisconnect(socket));
        socket.on('request_rooms', () => this.sendRoomList(socket));
        socket.on('set_player_name', (data) => this.setPlayerName(socket, data));
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

            socket.emit('room_created', room.id);
            // logger.debug('%s', room.id);

            this.io.emit('room_update', this.roomService.getRooms());
        } catch (error) {
            this.handleError(socket, error);
        }
    }

    async joinRoom(socket, { roomId }) {
        try {
            const room = this.roomService.joinRoom(roomId, socket.id);
            socket.join(roomId);

            const messages = this.messageService.getMessages(roomId);
            socket.emit('message_history', messages);

            this.io.to(roomId).emit('player_joined', room);
            this.io.emit('room_update', this.roomService.getRooms());
        } catch (error) {
            this.handleError(socket, error);
        }
    }

    async leaveRoom(socket) {
        try {
            const room = this.getRoom(socket);
            this.roomService.leaveRoom(socket.id);

            this.io.to(room.id).emit('player_left', socket.id);
            this.io.emit('room_update', this.roomService.getRooms());
        } catch (error) {
            this.handleError(socket, error);
        }
    }

    async handleDisconnect(socket) {
        try {
            const room = this.getRoom(socket);
            this.roomService.leaveRoom(socket.id);

            this.io.to(room.id).emit('player_disconnected', socket.id);
            this.io.emit('room_update', this.roomService.getRooms());
        } catch (error) {
            logger.error(`断开连接处理失败: ${error.message}`);
        }
    }

    async sendRoomList(socket) {
        try {
            socket.emit('room_update', this.roomService.getRooms());
        } catch (error) {
            this.handleError(socket, error);
        }
    }

    async setPlayerName(socket, { name }) {
        try {
            this.roomService._validatePlayerName(name);
            const player = this.getPlayer(socket);
            player.name = name;

            this.io.emit('room_update', this.roomService.getRooms());
        } catch (error) {
            this.handleError(socket, error);
        }
    }
}

module.exports = ConnectionController;