const { Server } = require('socket.io');
const shortid = require('shortid');
const _ = require('lodash');

// ================== 数据模型 ==================
class Poker {
    constructor(suit, value) {
        this.suit = suit;
        this.value = value;
    }
}

class Player {
    constructor(socketId, name) {
        this.id = socketId;
        this.name = name;
        this.cards = [];
        this.seat = -1;
        this.isLandlord = false;
    }
}

class Room {
    constructor(id) {
        this.id = id;
        this.players = [];
        this.deck = [];
        this.landlordCards = [];
        this.gameState = {
            phase: 'preparing',
            currentPlayer: -1,
            lastPlayedCards: [],
            currentBid: 0
        };
        this.createdAt = Date.now();
    }
}

class GameServer {
    constructor(io) {
        this.io = io;
        this.rooms = new Map();
        this.messageHistory = new Map();

        this.initializeSocket();
        this.startGameLoop();
    }

    initializeSocket() {
        this.io.on('connection', (socket) => {
            console.log(`Client connected: ${socket.id}`);

            // 房间操作
            socket.on('create_room', () => this.handleCreateRoom(socket));
            socket.on('join_room', (data) => this.handleJoinRoom(socket, data));
            socket.on('leave_room', () => this.handleLeaveRoom(socket));
            socket.on('request_rooms', () => this.broadcastRoomList());

            // 游戏操作
            socket.on('play_cards', (data) => this.handlePlayCards(socket, data));
            socket.on('place_bid', (data) => this.handleBid(socket, data));
            socket.on('pass_turn', () => this.handlePassTurn(socket));

            // 聊天功能
            socket.on('send_message', (data) => this.handleMessage(socket, data));

            socket.on('disconnect', () => this.handleDisconnect(socket));
        });
    }

    // =============== 房间管理 ===============
    handleCreateRoom(socket) {
        const roomId = shortid.generate({
            length: 6,
            charset: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
        });
        const room = new Room(roomId);
        this.rooms.set(roomId, room);
        socket.emit('room_created', roomId);
        this.broadcastRoomList();
    }

    handleJoinRoom(socket, { roomId, playerName }) {
        const room = this.rooms.get(roomId);
        if (!room) return socket.emit('error', '房间不存在');
        if (room.players.length >= 3) return socket.emit('error', '房间已满');

        const player = new Player(socket.id, playerName);
        player.seat = room.players.length;
        room.players.push(player);

        socket.join(roomId);
        this.syncGameState(room);
        this.broadcastRoomList();
    }

    handleLeaveRoom(socket) {
        const room = this.findPlayerRoom(socket.id);
        if (!room) return;

        room.players = room.players.filter(p => p.id !== socket.id);
        if (room.players.length === 0) this.rooms.delete(room.id);
        this.broadcastRoomList();
    }
    // =============== 游戏逻辑 ===============
    startGame(roomId) {
        const room = this.rooms.get(roomId);
        if (!room || room.players.length !== 3) return;

        // 初始化牌堆
        room.deck = this.generateDeck();
        this.shuffleDeck(room.deck);

        // 发牌逻辑
        room.players.forEach((player, index) => {
            player.cards = room.deck.slice(index * 17, (index + 1) * 17).sort(this.sortCards);
        });

        room.landlordCards = room.deck.slice(51, 54);
        room.gameState.phase = 'bidding';
        room.gameState.currentPlayer = 0;

        this.syncGameState(room);
    }

    handlePlayCards(socket, { cards }) {
        const room = this.findPlayerRoom(socket.id);
        const player = room.players.find(p => p.id === socket.id);

        if (!this.validatePlay(room, player, cards)) {
            return socket.emit('error', '无效的牌型或不符合规则');
        }

        // 更新游戏状态
        player.cards = player.cards.filter(c => !cards.some(cc => this.isSameCard(c, cc)));
        room.gameState.lastPlayedCards = cards;
        this.nextPlayer(room);

        this.syncGameState(room);
    }

    handleBid(socket, { bidValue }) {
        const room = this.findPlayerRoom(socket.id);
        const player = room.players.find(p => p.id === socket.id);

        if (bidValue > room.gameState.currentBid) {
            room.gameState.currentBid = bidValue;
            room.gameState.bidWinner = player.seat;
        }

        this.nextPlayer(room);
        if (room.gameState.currentPlayer === room.gameState.bidWinner) {
            this.assignLandlord(room);
        }

        this.syncGameState(room);
    }

    // =============== 牌型校验 ===============
    validatePlay(room, player, cards) {
        // 前端与后端保持一致的校验逻辑
        const sortedCards = [...cards].sort(this.sortCards);
        const lastPlayed = room.gameState.lastPlayedCards;

        // 火箭特殊处理
        if (this.isRocket(sortedCards)) return true;

        // 牌型校验
        const cardType = this.getCardType(sortedCards);
        if (cardType === 'invalid') return false;

        // 比较牌型大小
        if (lastPlayed.length > 0) {
            const lastType = this.getCardType(lastPlayed);
            if (cardType !== lastType) return false;
            return this.compareCards(sortedCards, lastPlayed);
        }

        return true;
    }

    getCardType(cards) {
        if (cards.length === 0) return 'invalid';
        const sortedCards = this.sortCards(cards);
        const length = sortedCards.length;

        // 火箭（大小王）
        if (length === 2 &&
            sortedCards[0].value === 'jokerBig' &&
            sortedCards[1].value === 'jokerSmall') {
            return 'rocket';
        }

        // 统计牌值出现次数
        const counts = {};
        for (const card of sortedCards) {
            counts[card.value] = (counts[card.value] || 0) + 1;
        }

        // 炸弹（四张相同）
        if (Object.keys(counts).length === 1 && Object.values(counts)[0] === 4) {
            return 'bomb';
        }

        // 单张
        if (length === 1) return 'single';

        // 对子
        if (length === 2 && Object.values(counts)[0] === 2) return 'pair';

        // 三张
        if (length === 3 && Object.values(counts)[0] === 3) return 'three';

        // 顺子
        if (this.isStraight(sortedCards)) return 'straight';

        // 连对
        if (this.isStraightPair(sortedCards)) return 'straightPair';

        // 飞机（纯三张）
        if (this.isPlane(sortedCards)) return 'plane';

        // 三带一
        if (length === 4 &&
            Object.values(counts).sort().join(',') === '1,3') {
            return 'threeWithOne';
        }

        // 三带二
        if (length === 5 &&
            Object.values(counts).sort().join(',') === '2,3') {
            return 'threeWithTwo';
        }

        // 飞机带翅膀
        if (this.isPlaneWithWings(sortedCards, counts)) {
            return 'planeWithWings';
        }

        // 四带二
        if (length === 6 &&
            Object.values(counts).includes(4) &&
            Object.keys(counts).length === 3) {
            return 'fourWithTwo';
        }

        // 四带两对
        if (length === 8 &&
            Object.values(counts).includes(4) &&
            Object.values(counts).filter(v => v === 2).length === 2) {
            return 'fourWithTwoPair';
        }

        return 'invalid';
    }

    isStraight(cards) {
        if (cards.length < 5 || cards.length > 12) return false;
        const values = cards.map(c => this.getCardWeight(c));

        // 检查连续且不包含2和王
        for (let i = 0; i < cards.length; i++) {
            const current = cards[i];
            if (['two', 'jokerSmall', 'jokerBig'].includes(current.value)) return false;
            if (i > 0 && values[i - 1] - values[i] !== 1) return false;
        }
        return true;
    }

    isStraightPair(cards) {
        if (cards.length < 6 || cards.length % 2 !== 0) return false;
        const pairs = [];

        // 拆分为对子检查
        for (let i = 0; i < cards.length; i += 2) {
            if (cards[i].value !== cards[i + 1].value) return false;
            pairs.push(cards[i].value);
        }
        return this.checkConsecutive(pairs);
    }

    isPlane(cards) {
        if (cards.length < 6 || cards.length % 3 !== 0) return false;
        const triplets = [];

        // 拆分为三张检查
        for (let i = 0; i < cards.length; i += 3) {
            if (cards[i].value !== cards[i + 1].value ||
                cards[i].value !== cards[i + 2].value) return false;
            triplets.push(cards[i].value);
        }
        return this.checkConsecutive(triplets);
    }

    isPlaneWithWings(cards, counts) {
        if (cards.length < 8) return false;

        // 分离三张和翅膀
        const triples = Object.entries(counts)
            .filter(([_, count]) => count === 3)
            .map(([value]) => value);

        const wings = Object.entries(counts)
            .filter(([_, count]) => count !== 3)
            .flatMap(([value, count]) => Array(count).fill(value));

        // 检查三张连续性
        if (!this.checkConsecutive(triples)) return false;

        // 翅膀数量必须匹配
        const requiredWings = triples.length;
        return wings.length === requiredWings ||
            wings.length === requiredWings * 2;
    }

    // 辅助方法
    checkConsecutive(values) {
        const sorted = [...new Set(values)]
            .sort((a, b) => this.getCardWeightByValue(b) - this.getCardWeightByValue(a));

        for (let i = 0; i < sorted.length - 1; i++) {
            if (this.getCardWeightByValue(sorted[i]) -
                this.getCardWeightByValue(sorted[i + 1]) !== 1) {
                return false;
            }
        }
        return true;
    }

    getCardWeight(card) {
        const weights = {
            'jokerBig': 16,
            'jokerSmall': 15,
            'two': 14,
            'ace': 13,
            'king': 12,
            'queen': 11,
            'jack': 10,
            'ten': 9,
            'nine': 8,
            'eight': 7,
            'seven': 6,
            'six': 5,
            'five': 4,
            'four': 3,
            'three': 2
        };
        return weights[card.value] || 0;
    }

    getCardWeightByValue(value) {
        return this.getCardWeight({ value });
    }

    sortCards(cards) {
        return [...cards].sort((a, b) =>
            this.getCardWeight(b) - this.getCardWeight(a));
    }

    // =============== 工具方法 ===============
    generateDeck() {
        const suits = ['hearts', 'diamonds', 'clubs', 'spades'];
        const values = ['3', '4', '5', '6', '7', '8', '9', '10', 'jack', 'queen', 'king', 'ace', '2'];

        const deck = [];
        suits.forEach(suit => {
            values.forEach(value => deck.push(new Poker(suit, value)));
        });
        deck.push(new Poker('joker', 'small'), new Poker('joker', 'big'));
        return deck;
    }

    sortCards(a, b) {
        // 与前端CardUtils一致的排序逻辑
        const weights = { '3': 2, '4': 3, '5': 4, '6': 5, '7': 6, '8': 7, '9': 8, '10': 9, 'jack': 10, 'queen': 11, 'king': 12, 'ace': 13, '2': 14, 'small': 15, 'big': 16 };
        return weights[b.value] - weights[a.value];
    }

    syncGameState(room) {
        this.io.to(room.id).emit('game_state_updated', {
            players: room.players.map(p => ({
                id: p.id,
                name: p.name,
                seat: p.seat,
                cardsCount: p.cards.length,
                isLandlord: p.isLandlord
            })),
            ...room.gameState,
            landlordCards: room.landlordCards
        });
    }

    broadcastRoomList() {
        const roomList = Array.from(this.rooms.values()).map(room => ({
            id: room.id,
            players: room.players.length,
            phase: room.gameState.phase
        }));
        this.io.emit('room_update', roomList);
    }

    // =============== 定时器循环 ===============
    startGameLoop() {
        setInterval(() => {
            this.rooms.forEach(room => {
                if (room.gameState.phase === 'playing' &&
                    Date.now() - room.lastActionTime > 30000) {
                    this.nextPlayer(room);
                    this.syncGameState(room);
                }
            });
        }, 5000);
    }
}

// =============== 启动服务 ===============
const io = new Server(3000, {
    cors: {
        origin: "http://localhost:8080", // 根据前端实际地址调整
        methods: ["GET", "POST"]
    }
});

new GameServer(io);
console.log('Game server running on port 3000');