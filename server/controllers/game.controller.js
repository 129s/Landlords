// controllers/game.controller.js
const BaseController = require('./base.controller');
const logger = require('../utils/logger');

class GameController extends BaseController {
    initHandlers(socket) {
        socket.on('start_game', () => this.startGame(socket));
        socket.on('place_bid', (data) => this.handleBid(socket, data));
        socket.on('play_cards', (data) => this.playCards(socket, data));
        socket.on('pass_turn', () => this.passTurn(socket));
    }

    async startGame(socket) {
        try {
            const room = this.getRoom(socket);
            if (room.players.length !== 3) throw new Error('INSUFFICIENT_PLAYERS');

            const gameState = this.gameService.startGame(room.id);
            this.io.to(room.id).emit('game_started', gameState);
        } catch (error) {
            this.handleError(socket, error);
        }
    }

    async handleBid(socket, { bidValue }) {
        try {
            const room = this.getRoom(socket);
            const player = this.getPlayer(socket);

            this.gameService.bidLandlord(room.id, player.id, bidValue);
            this.io.to(room.id).emit('bid_updated', this.gameService.gameStates.get(room.id));
        } catch (error) {
            this.handleError(socket, error);
        }
    }

    async playCards(socket, { cards }) {
        try {
            const room = this.getRoom(socket);
            const player = this.getPlayer(socket);

            const state = this.gameService.playCards(room.id, player.id, cards);
            this.io.to(room.id).emit('game_state_updated', state);
        } catch (error) {
            this.handleError(socket, error);
        }
    }

    async passTurn(socket) {
        try {
            const room = this.getRoom(socket);
            const state = this.gameService.passTurn(room.id);
            this.io.to(room.id).emit('turn_passed', state);
        } catch (error) {
            this.handleError(socket, error);
        }
    }
}

module.exports = GameController;