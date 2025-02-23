const logger = require('../utils/logger');
const { validateRoomState } = require('../utils/room.utils');
const CardUtils = require('../utils/card.utils');

class GameService {
    constructor() {
        this.gameStates = new Map(); // roomId -> GameState
        this.timers = new Map();     // 游戏定时器管理
    }

    // 初始化游戏状态
    initGame(roomId, players) {
        const deck = this._createShuffledDeck();
        const hands = this._dealCards(deck);

        const state = {
            phase: 'BIDDING',
            currentPlayer: 0,
            landlord: null,
            players: players.map((p, i) => ({
                ...p,
                cards: hands[i],
                cardCount: 17,
                id: p.id,
                name: p.name,
                seat: p.seat,
                isLandlord: p.isLandlord,
                socketId: p.socketId
            })),
            lastPlay: [],
            currentPlay: [],
            baseCards: hands[3],
            multiplier: 1
        };

        this.gameStates.set(roomId, state);
        this._startBiddingTimer(roomId);
        return state;
    }

    // 叫地主逻辑
    handleBid(roomId, playerId, bidValue) {
        const state = this.gameStates.get(roomId);
        if (state.phase !== 'BIDDING') return false;

        const playerIndex = state.players.findIndex(p => p.id === playerId);
        if (playerIndex !== state.currentPlayer) return false;

        if (bidValue > state.multiplier) {
            state.multiplier = bidValue;
            state.landlordCandidate = playerIndex;
        }

        state.currentPlayer = (playerIndex + 1) % 3;
        if (state.currentPlayer === playerIndex) {
            this._finalizeLandlord(roomId);
        }
        return true;
    }

    // 出牌验证
    validatePlay(roomId, playerId, cards) {
        const state = this.gameStates.get(roomId);
        const player = state.players.find(p => p.id === playerId);

        // 基础验证
        if (!this._hasCards(player.cards, cards)) return false;
        if (state.lastPlay.length > 0 && !CardUtils.isBigger(cards, state.lastPlay)) return false;

        return CardUtils.getCardType(cards) !== 'INVALID';
    }

    // 执行出牌
    applyPlay(roomId, playerId, cards) {
        const state = this.gameStates.get(roomId);
        const playerIndex = state.players.findIndex(p => p.id === playerId);

        // 更新玩家手牌
        state.players[playerIndex].cards = state.players[playerIndex].cards.filter(c =>
            !cards.some(played => c.suit === played.suit && c.value === played.value)
        );

        state.players[playerIndex].cardCount = state.players[playerIndex].cards.length;

        // 更新游戏状态
        state.lastPlay = cards;
        state.currentPlay = cards;
        state.currentPlayer = (playerIndex + 1) % 3;

        // 检查游戏结束
        if (state.players[playerIndex].cards.length === 0) {
            this._endGame(roomId, playerIndex);
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

        // While there remain elements to shuffle.
        while (currentIndex != 0) {

            // Pick a remaining element.
            randomIndex = Math.floor(Math.random() * currentIndex);
            currentIndex--;

            // And swap it with the current element.
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
