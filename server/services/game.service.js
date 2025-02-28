// services/game.service.js
const BaseService = require('./base.service');
const CardUtils = require('../utils/card.utils');
const logger = require('../utils/logger');
GamePhase = {
    PREPARING: 'preparing',
    BIDDING: 'bidding',
    PLAYING: 'playing',
    END: 'end'
};
class GameError extends Error {
    constructor(code, message) {
        super(message);
        this.name = 'GameError';
        this.code = code;
    }
}

class GameService extends BaseService {
    constructor(stateStore) {
        super(stateStore);
        this.TIMEOUTS = {
            BIDDING: 30000,
            TURN: 45000
        };
    }

    // 核心游戏方法
    startGame(roomId) {
        return this.withTransaction(async () => {
            this.validateRoomExists(roomId);
            const room = this.stateStore.rooms.get(roomId);

            if (room.players.length !== 3) {
                throw new GameError('INSUFFICIENT_PLAYERS', '需要3名玩家才能开始游戏');
            }

            const gameState = this._initializeGameState(room);
            this.stateStore.games.set(roomId, gameState);

            this._startPhaseTimer(roomId, GamePhase.BIDDING);
            logger.info(`游戏开始: ${roomId}`);
            return this._getPublicState(gameState);
        });
    }


    handleBid(roomId, playerId, bidValue) {
        return this.withTransaction(async () => {
            const gameState = this._getValidGameState(roomId, GamePhase.BIDDING);
            const playerIndex = this._getPlayerIndex(gameState, playerId);

            this._validatePlayerTurn(gameState, playerIndex);
            this._processBid(gameState, playerIndex, bidValue);

            if (this._shouldEndBidding(gameState)) {
                this._assignLandlord(gameState);
                this._startPlayingPhase(gameState);
            }

            return this._getPublicState(gameState);
        });
    }

    playCards(roomId, playerId, cards) {
        return this.withTransaction(async () => {
            const gameState = this._getValidGameState(roomId, GamePhase.PLAYING);
            const playerIndex = this._getPlayerIndex(gameState, playerId);

            this._validatePlayerTurn(gameState, playerIndex);
            this._validateCardOwnership(gameState.players[playerIndex], cards);
            this._validatePlayValidity(cards, gameState.lastPlayedCards);

            this._updateGameStateAfterPlay(gameState, playerIndex, cards);

            if (this._checkGameEnd(gameState, playerIndex)) {
                this._cleanupAfterGameEnd(roomId);
            }

            return this._getPublicState(gameState);
        });
    }

    // 私有方法实现
    _initializeGameState(room) {
        const [p1, p2, p3, baseCards] = CardUtils.dealCards();

        return {
            phase: GamePhase.BIDDING,
            players: room.players.map((player, index) => ({
                ...player,
                cards: [p1, p2, p3][index],
                isLandlord: false,
                cardCount: 17
            })),
            baseCards,
            currentPlayer: Math.floor(Math.random() * 3),
            landlordCandidate: null,
            currentBid: 0,
            passCount: 0,
            lastPlayedCards: [],
            history: [],
            timer: null
        };
    }

    _processBid(gameState, playerIndex, bidValue) {
        if (bidValue > gameState.currentBid) {
            gameState.currentBid = bidValue;
            gameState.landlordCandidate = playerIndex;
            gameState.passCount = 0;
        } else {
            gameState.passCount++;
        }

        if (!this._shouldEndBidding(gameState)) {
            gameState.currentPlayer = (playerIndex + 1) % 3;
        }
    }

    _assignLandlord(gameState) {
        const landlordIndex = gameState.landlordCandidate ??
            Math.floor(Math.random() * 3);

        gameState.players[landlordIndex].isLandlord = true;
        gameState.players[landlordIndex].cards.push(...gameState.baseCards);
        gameState.players[landlordIndex].cardCount += 3;

        gameState.currentPlayer = landlordIndex;
        gameState.phase = GamePhase.PLAYING;
    }

    _updateGameStateAfterPlay(gameState, playerIndex, cards) {
        // 从玩家手牌中移除
        gameState.players[playerIndex].cards =
            gameState.players[playerIndex].cards.filter(c =>
                !cards.some(pc => CardUtils.isSameCard(c, pc))
            );

        // 记录历史
        gameState.history.push({
            playerId: gameState.players[playerIndex].id,
            action: cards.length > 0 ? 'PLAY' : 'PASS',
            cards: [...cards],
            timestamp: new Date()
        });

        // 更新最后出牌信息
        if (cards.length > 0) {
            gameState.lastPlayedCards = cards;
            gameState.lastPlayer = playerIndex;
            gameState.currentPlayer = (playerIndex + 1) % 3;
        } else {
            gameState.currentPlayer = (gameState.currentPlayer + 1) % 3;
        }
    }

    // 验证方法
    _getValidGameState(roomId, expectedPhase) {
        const gameState = this.stateStore.games.get(roomId);
        if (!gameState) {
            throw new GameError('GAME_NOT_FOUND', '游戏未找到');
        }
        if (gameState.phase !== expectedPhase) {
            throw new GameError('INVALID_PHASE', `当前阶段无法执行此操作`);
        }
        return gameState;
    }

    _validateCardOwnership(player, cards) {
        const missing = cards.filter(c =>
            !player.cards.some(pc => CardUtils.isSameCard(pc, c))
        );
        if (missing.length > 0) {
            throw new GameError('INVALID_CARDS', `不拥有这些卡牌: ${missing.map(c => CardUtils.cardToString(c)).join(',')}`);
        }
    }

    // 定时器管理
    _startPhaseTimer(roomId, phase) {
        const timeout = this.TIMEOUTS[phase];
        this._clearTimer(roomId);

        this.stateStore.games.get(roomId).timer = setTimeout(() => {
            this._handlePhaseTimeout(roomId, phase);
        }, timeout);
    }

    _handlePhaseTimeout(roomId, phase) {
        const gameState = this.stateStore.games.get(roomId);
        switch (phase) {
            case GamePhase.BIDDING:
                this._assignLandlord(gameState);
                this._startPlayingPhase(gameState);
                break;
            case GamePhase.PLAYING:
                this._autoPassTurn(gameState);
                break;
        }
        this.io.to(roomId).emit('game_state_updated', this._getPublicState(gameState));
    }

    _getPublicState(gameState) {
        return {
            phase: gameState.phase,
            players: gameState.players.map(p => ({
                id: p.id,
                name: p.name,
                cardCount: p.cardCount,
                isLandlord: p.isLandlord
            })),
            currentPlayer: gameState.currentPlayer,
            lastPlayedCards: gameState.lastPlayedCards,
            currentBid: gameState.currentBid,
            history: gameState.history,
        };
    }
}

module.exports = GameService;