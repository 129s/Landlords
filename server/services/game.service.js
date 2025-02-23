const logger = require('../utils/logger');
const { validateRoomState } = require('../utils/room.utils');
const CardUtils = require('./card.utils');

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
                cardCount: 17
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
        if (state.currentPlayer === 0 && !state.landlord) {
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
        if (state.currentPlay.length > 0 && !CardUtils.isBigger(cards, state.currentPlay)) return false;

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

        // 更新游戏状态
        state.lastPlay = state.currentPlay;
        state.currentPlay = cards;
        state.currentPlayer = (playerIndex + 1) % 3;

        // 检查游戏结束
        if (state.players[playerIndex].cards.length === 0) {
            this._endGame(roomId, playerIndex);
        }

        return true;
    }

    // 私有方法
    _createShuffledDeck() {
        const deck = [];
        // 生成54张牌（含大小王）
        // ...（实现逻辑与Flutter端PokerModel一致）
        return CardUtils.shuffle(deck);
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
}

module.exports = GameService;