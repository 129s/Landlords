const logger = require('../utils/logger');

class GameController {
    constructor(io, gameService, roomService) {
        this.io = io;
        this.gameService = gameService;
        this.roomService = roomService;
    }

    initHandlers(socket) {
        socket.on('startGame', () => this.handleStartGame(socket));
        socket.on('placeBid', (data) => this.handleBid(socket, data));
        socket.on('playCards', (data) => this.handlePlay(socket, data));
        socket.on('passTurn', () => this.handlePass(socket));
    }

    handleStartGame(socket) {
        const conn = this.roomService.playerConnections.get(socket.id);
        if (!conn) return;

        const room = this.roomService.getRoom(conn.roomId);
        if (room.players.length === 3) {
            const gameState = this.gameService.initGame(room.id, room.players);
            this.io.to(room.id).emit('gameStarted', gameState);
        }
    }

    handleBid(socket, { bidValue }) {
        const conn = this.roomService.playerConnections.get(socket.id);
        if (this.gameService.handleBid(conn.roomId, conn.playerId, bidValue)) {
            this.io.to(conn.roomId).emit('bidUpdate', this.gameService.gameStates.get(conn.roomId));
        }
    }

    handlePlay(socket, { cards }) {
        const conn = this.roomService.playerConnections.get(socket.id);
        if (this.gameService.validatePlay(conn.roomId, conn.playerId, cards)) {
            this.gameService.applyPlay(conn.roomId, conn.playerId, cards);
            this.io.to(conn.roomId).emit('playUpdate', this.gameService.gameStates.get(conn.roomId));
        }
    }

    handlePass(socket) {
        const conn = this.roomService.playerConnections.get(socket.id);
        const state = this.gameService.gameStates.get(conn.roomId);
        state.currentPlayer = (state.currentPlayer + 1) % 3;
        this.io.to(conn.roomId).emit('turnUpdate', state);
    }
}

module.exports = GameController;