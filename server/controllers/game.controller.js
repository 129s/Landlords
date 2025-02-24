// controllers/game.controller.js
const BaseController = require('./base.controller');
const logger = require('../utils/logger');

class GameController extends BaseController {
    initHandlers(socket) {
        socket.on('place_bid', (data) => this.handleBid(socket, data));
        socket.on('play_cards', (data, callback) => {
            try {
                const result = this.gameService.playCards(socket, data);
                callback({ success: true, data: result });
            } catch (error) {
                callback({ success: false, error: error.message });
            }
        });
        socket.on('pass_turn', () => this.passTurn(socket));
    }

    async startGame(socket) {
        try {
            const room = this.getRoom(socket);
            if (room.players.length !== 3) throw new Error('INSUFFICIENT_PLAYERS', '需要3名玩家才能开始游戏');

            const gameState = this.gameService.startGame(room.id);
            // 统一触发game_state_updated事件
            this.io.to(room.id).emit('game_state_updated',
                this.gameService._getPublicState(gameState));
        } catch (error) {
            this.handleError(socket, error);
        }
    }

    async handleBid(socket, { bidValue }) {
        try {
            const room = this.getRoom(socket);
            const player = this.getPlayer(socket);

            const updatedState = this.gameService.bidLandlord(
                room.id, player.id, bidValue
            );
            this.io.to(room.id).emit('game_state_updated',
                this.gameService._getPublicState(updatedState));
        } catch (error) {
            this.handleError(socket, error);
        }
    }

    async playCards(socket, { cards }) {
        try {
            const room = this.getRoom(socket);
            const player = this.getPlayer(socket);

            const state = this.gameService.playCards(room.id, player.id, cards);
            this.io.to(room.id).emit('game_state_updated',
                this.gameService._getPublicState(updatedState));
        } catch (error) {
            this.handleError(socket, error);
        }
    }

    async passTurn(socket) {
        try {
            const room = this.getRoom(socket);
            const state = this.gameService.passTurn(room.id);
            this.io.to(room.id).emit('game_state_updated',
                this.gameService._getPublicState(updatedState));
        } catch (error) {
            this.handleError(socket, error);
        }
    }
}

module.exports = GameController;