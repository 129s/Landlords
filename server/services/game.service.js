const CardUtils = require('../utils/card.utils');
const logger = require('../utils/logger');

class GameService {
    constructor() {
        this.gameStates = new Map(); // roomId -> GameState
        this.timers = new Map(); // roomId -> timer
    }

    startGame(roomId) {
        const room = { players: [{ id: '1' }, { id: '2' }, { id: '3' }] }; //roomService.getRoom(roomId);
        if (!room) {
            logger.error(`房间 %s 不存在`, roomId);
            throw new Error('Room not found');
        }

        if (room.players.length !== 3) {
            logger.error(`房间 %s 玩家数量不足`, roomId);
            throw new Error('Not enough players to start the game');
        }

        const deck = this._createDeck();
        const hands = this._dealCards(deck);

        const players = room.players.map((player, index) => ({
            id: player.id,
            cards: hands[index],
            cardCount: hands[index].length,
            name: `Player ${index + 1}`
        }));

        const baseCards = hands[3];

        const gameState = {
            roomId: roomId,
            players: players,
            baseCards: baseCards,
            currentPlayer: Math.floor(Math.random() * 3), // 随机选择一个玩家开始
            landlordCandidate: null,
            landlord: null,
            phase: 'BIDDING', // BIDDING, PLAYING, ENDED
            lastPlayedCards: [],
            lastPlayer: null,
            currentBid: 0,
            passCount: 0,
        };

        this.gameStates.set(roomId, gameState);
        this._startBiddingTimer(roomId);
        logger.info(`房间 %s 游戏状态初始化`, roomId);
    }

    bidLandlord(roomId, socketId, bid) {
        const state = this.gameStates.get(roomId);
        if (!state) {
            logger.error(`房间 %s 游戏状态不存在`, roomId);
            throw new Error('Game state not found');
        }

        if (state.phase !== 'BIDDING') {
            logger.warn(`房间 %s 状态不是叫地主阶段`, roomId);
            throw new Error('Not in bidding phase');
        }

        const playerIndex = state.players.findIndex(p => p.id === socketId);
        if (playerIndex === -1) {
            logger.error(`房间 %s 找不到玩家 %s`, roomId, socketId);
            throw new Error('Player not found in game');
        }

        if (playerIndex !== state.currentPlayer) {
            logger.warn(`房间 %s 轮到玩家 %s 叫地主`, roomId, socketId);
            throw new Error('Not your turn to bid');
        }

        if (bid > state.currentBid) {
            state.currentBid = bid;
            state.landlordCandidate = playerIndex;
            state.passCount = 0;
        } else {
            state.passCount++;
        }

        if (state.passCount === 2 || bid === 3) {
            clearTimeout(this.timers[roomId]);
            this._finalizeLandlord(roomId);
            logger.info(`房间 %s 地主确定，开始游戏`, roomId);
        } else {
            state.currentPlayer = (state.currentPlayer + 1) % 3;
            logger.info(`房间 %s 下一个玩家叫地主`, roomId);
        }
    }

    playCards(roomId, socketId, cards) {
        const state = this.gameStates.get(roomId);
        if (!state) {
            logger.error(`房间 %s 游戏状态不存在`, roomId);
            throw new Error('Game state not found');
        }

        if (state.phase !== 'PLAYING') {
            logger.warn(`房间 %s 状态不是出牌阶段`, roomId);
            throw new Error('Not in playing phase');
        }

        const playerIndex = state.players.findIndex(p => p.id === socketId);
        if (playerIndex === -1) {
            logger.error(`房间 %s 找不到玩家 %s`, roomId, socketId);
            throw new Error('Player not found in game');
        }

        if (playerIndex !== state.currentPlayer) {
            logger.warn(`房间 %s 轮到玩家 %s 出牌`, roomId, socketId);
            throw new Error('Not your turn to play cards');
        }

        const playerCards = state.players[playerIndex].cards;
        if (!this._hasCards(playerCards, cards)) {
            logger.warn(`房间 %s 玩家 %s 没有这些牌`, roomId, socketId);
            throw new Error('You do not have these cards');
        }

        if (state.lastPlayer !== null && state.lastPlayer !== playerIndex) {
            if (!CardUtils.isBigger(cards, state.lastPlayedCards)) {
                logger.warn(`房间 %s 玩家 %s 出的牌不够大`, roomId, socketId);
                throw new Error('Cards are not bigger than last played cards');
            }
        }

        const cardType = CardUtils.getCardType(cards);
        if (cardType === 'INVALID') {
            logger.warn(`房间 %s 玩家 %s 出的牌不符合规则`, roomId, socketId);
            throw new Error('Invalid card combination');
        }

        // 从玩家手中移除已出的牌
        for (const card of cards) {
            const index = playerCards.findIndex(pc => pc.suit === card.suit && pc.value === card.value);
            playerCards.splice(index, 1);
        }
        state.players[playerIndex].cards = playerCards;
        state.players[playerIndex].cardCount = playerCards.length;

        state.lastPlayedCards = cards;
        state.lastPlayer = playerIndex;
        state.currentPlayer = (state.currentPlayer + 1) % 3;

        if (playerCards.length === 0) {
            this._endGame(roomId, playerIndex);
            logger.info(`房间 %s 玩家 %s 赢得了游戏`, roomId, socketId);
        } else {
            this._startTurnTimer(roomId);
            logger.info(`房间 %s 下一个玩家出牌`, roomId);
        }
    }

    _createDeck() {
        const suits = ['hearts', 'diamonds', 'clubs', 'spades'];
        const values = ['3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', '2'];
        const deck = [];

        for (const suit of suits) {
            for (const value of values) {
                deck.push({ suit, value });
            }
        }

        deck.push({ suit: 'joker', value: 'small' });
        deck.push({ suit: 'joker', value: 'big' });

        return this._shuffle(deck);
    }

    _shuffle(array) {
        let currentIndex = array.length, randomIndex;

        while (currentIndex != 0) {
            randomIndex = Math.floor(Math.random() * currentIndex);
            currentIndex--;

            [array[currentIndex], array[randomIndex]] = [
                array[randomIndex], array[currentIndex]];
        }

        return array;
    }

    _dealCards(deck) {
        const hands = [[], [], [], []];
        for (let i = 0; i < 51; i++) {
            hands[i % 3].push(deck[i]);
        }
        hands[3] = deck.slice(51, 54); // 底牌
        return hands;
    }

    _finalizeLandlord(roomId) {
        const state = this.gameStates.get(roomId);
        state.landlord = state.landlordCandidate;
        state.players[state.landlord].cards.push(...state.baseCards);
        state.players[state.landlord].cardCount = state.players[state.landlord].cards.length;
        state.phase = 'PLAYING';
        this._startTurnTimer(roomId);
        logger.info(`房间 %s 确定地主，开始出牌`, roomId);
    }

    _startBiddingTimer(roomId) {
        this.timers[roomId] = setTimeout(() => {
            this._finalizeLandlord(roomId);
            logger.info(`房间 %s 叫地主超时，自动确定地主`, roomId);
        }, 30000);
    }

    _startTurnTimer(roomId) {
        this.timers[roomId] = setTimeout(() => {
            this._handleTimeout(roomId);
            logger.info(`房间 %s 出牌超时，自动跳过`, roomId);
        }, 45000);
    }

    _endGame(roomId, winnerIndex) {
        const state = this.gameStates.get(roomId);
        // 计算得分等逻辑
        this.gameStates.delete(roomId);
        this.timers.delete(roomId);
        logger.info(`房间 %s 游戏结束，赢家是玩家 %s`, roomId, winnerIndex);
    }

    _hasCards(playerCards, playedCards) {
        for (const card of playedCards) {
            const index = playerCards.findIndex(pc => pc.suit === card.suit && pc.value === card.value);
            if (index === -1) {
                return false;
            }
        }
        return true;
    }

    _handleTimeout(roomId) {
        // 处理超时逻辑，例如自动跳过玩家的回合
        const state = this.gameStates.get(roomId);
        if (!state) return;

        // 简单地将当前玩家设置为下一个玩家
        state.currentPlayer = (state.currentPlayer + 1) % 3;
        logger.info(`房间 %s: 玩家回合超时，跳到下一个玩家.`, roomId);
    }
}

module.exports = GameService;
