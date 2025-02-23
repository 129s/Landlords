const CardUtils = require('../utils/card.utils');
const logger = require('../utils/logger');

class GameService {
    constructor() {
        this.gameStates = new Map(); // roomId -> gameState
        this.timers = new Map(); // roomId -> timer
    }

    startGame(roomId) {
        const deck = this._createShuffledDeck();
        const hands = this._dealCards(deck);

        const gameState = {
            roomId: roomId,
            players: [
                { id: 0, cards: hands[0], cardCount: hands[0].length },
                { id: 1, cards: hands[1], cardCount: hands[1].length },
                { id: 2, cards: hands[2], cardCount: hands[2].length }
            ],
            baseCards: hands[3],
            currentPlayer: 0,
            phase: 'BIDDING', // BIDDING, PLAYING, ENDED
            landlord: null,
            landlordCandidate: null,
            currentPlay: null,
            lastPlay: null,
        };

        this.gameStates.set(roomId, gameState);
        this._startBiddingTimer(roomId);
        logger.info(`Game started in room: ${roomId}`);
    }

    bidLandlord(roomId, playerId, bid) {
        const state = this.gameStates.get(roomId);
        if (!state || state.phase !== 'BIDDING') return;

        if (bid) {
            state.landlordCandidate = playerId;
        }

        state.currentPlayer = (state.currentPlayer + 1) % 3;

        if (state.currentPlayer === 0) {
            clearTimeout(this.timers[roomId]);
            this._finalizeLandlord(roomId);
        }
    }

    playCards(roomId, playerId, cards) {
        const state = this.gameStates.get(roomId);
        if (!state || state.phase !== 'PLAYING' || state.currentPlayer !== playerId) return false;

        const playerCards = state.players[playerId].cards;
        if (!this._hasCards(playerCards, cards)) return false;

        const cardType = CardUtils.getCardType(cards);
        if (cardType === 'INVALID') return false;

        if (state.lastPlay && !CardUtils.isBigger(cards, state.lastPlay)) return false;

        state.players[playerId].cards = playerCards.filter(card => !cards.some(c => c.suit === card.suit && c.value === card.value));
        state.players[playerId].cardCount = state.players[playerId].cards.length;
        state.lastPlay = cards;
        state.currentPlayer = (state.currentPlayer + 1) % 3;

        if (state.players[playerId].cardCount === 0) {
            this._endGame(roomId, playerId);
        }

        return true;
    }

    _createShuffledDeck() {
        const deck = [];
        const suits = ['hearts', 'diamonds', 'clubs', 'spades'];
        const values = ['3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', '2'];

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
    }

    _startBiddingTimer(roomId) {
        this.timers[roomId] = setTimeout(() => {
            this._finalizeLandlord(roomId);
        }, 30000);
    }

    _startTurnTimer(roomId) {
        this.timers[roomId] = setTimeout(() => {
            this._handleTimeout(roomId);
        }, 45000);
    }

    _endGame(roomId, winnerIndex) {
        const state = this.gameStates.get(roomId);
        // 计算得分等逻辑
        this.gameStates.delete(roomId);
        this.timers.delete(roomId);
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
        logger.info(`Room ${roomId}: Player turn timed out, skipping to next player.`);
    }
}

module.exports = GameService;
