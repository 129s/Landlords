const express = require('express'); // 引入 express 框架，用于创建 web 服务器
const { createServer } = require('http'); // 引入 http 模块，用于创建 http 服务器
const { Server } = require('socket.io'); // 引入 socket.io 模块，用于实现实时通信
const cors = require('cors'); // 引入 cors 模块，用于处理跨域请求

// 游戏阶段枚举，定义了游戏的不同状态
const GamePhase = {
    WAITING: "waiting", // 等待玩家加入
    DEALING: "dealing", // 发牌中
    BIDDING: "bidding", // 叫分中
    PLAYING: "playing", // 游戏中
    ENDED: "ended" // 游戏结束
};

// GameRoom 类，用于表示一个游戏房间
class GameRoom {
    constructor(roomId) {
        this.id = roomId; // 房间 ID
        this.players = []; // 玩家列表，存储玩家对象
        this.deck = []; // 牌堆，存储卡牌 ID
        this.phase = GamePhase.WAITING; // 游戏阶段，初始为等待阶段
        this.currentPlayer = 0; // 当前玩家的座位号 (0, 1, 2)
        this.landlord = -1; // 地主的座位号，-1 表示尚未确定地主
        this.baseCards = []; // 底牌，三张牌
        this.lastPlay = []; // 上一次出的牌，存储卡牌 ID 列表
        this.currentBid = 0; // 当前最高叫分
        this.bidCount = 0; // 叫分次数，用于判断是否结束叫分
    }

    // dealCards 方法，用于发牌
    dealCards() {
        // 生成54张牌（0-53对应前端卡牌ID）
        this.deck = [...Array(54).keys()].sort(() => Math.random() - 0.5); // 创建一个包含 0-53 的数组，然后随机排序，生成牌堆

        // 发牌逻辑
        this.players.forEach((p, i) => {
            p.cards = this.deck.slice(i * 17, (i + 1) * 17).sort((a, b) => b - a); // 从牌堆中取出 17 张牌，分配给玩家，并降序排序
            p.cardCount = 17; // 设置玩家的牌的数量
        });

        this.baseCards = this.deck.slice(51, 54); // 从牌堆中取出最后 3 张牌，作为底牌
        this.phase = GamePhase.BIDDING; // 设置游戏阶段为叫分阶段
    }

    // getStateForPlayer 方法，用于获取指定玩家的游戏状态
    getStateForPlayer(playerId) {
        const currentPlayer = this.players.find(p => p.id === playerId); // 查找指定 ID 的玩家
        return {
            players: this.players.map(p => ({ // 映射玩家列表，只返回部分信息
                id: p.id, // 玩家 ID
                name: p.name, // 玩家姓名
                cardCount: p.cardCount, // 玩家手牌数量
                isLandlord: this.landlord === p.seat // 是否是地主
            })),
            currentPlayer: this.currentPlayer, // 当前玩家的座位号
            lastPlay: this.lastPlay, // 上一次出的牌
            baseCards: this.phase === GamePhase.PLAYING ? this.baseCards : [], // 底牌，只有在游戏阶段为 playing 时才返回
            phase: this.phase, // 游戏阶段
            currentBid: this.currentBid // 当前最高叫分
        };
    }
}

const app = express(); // 创建 express 应用
app.use(cors()); // 使用 cors 中间件，允许跨域请求
const httpServer = createServer(app); // 创建 http 服务器
const io = new Server(httpServer, { // 创建 socket.io 服务器
    cors: { origin: "*", methods: ["GET", "POST"] } // 配置 cors，允许所有来源的 GET 和 POST 请求
});

// 房间存储，使用 Map 数据结构存储房间信息，key 为房间 ID，value 为 GameRoom 对象
const rooms = new Map();

// 获取玩家所在房间
const getPlayerRoom = (socket) => {
    return [...socket.rooms].slice(1).map(r => rooms.get(r))[0]; // 从 socket 的 rooms 属性中获取房间 ID，然后从 rooms Map 中获取 GameRoom 对象
};

// socket.io 连接事件
io.on('connection', (socket) => {
    console.log(`客户端连接: ${socket.id}`); // 打印客户端连接信息

    // 心跳检测，客户端定时发送 ping 事件，服务器回复 pong 事件，用于检测连接是否断开
    socket.on('ping', () => socket.emit('pong'));

    // 创建房间事件
    socket.on('createRoom', (playerName) => {
        const roomId = Math.random().toString(36).substr(2, 6); // 生成随机房间 ID
        const room = new GameRoom(roomId); // 创建 GameRoom 对象

        room.players.push({ // 创建玩家对象，并添加到房间的玩家列表中
            id: socket.id, // 玩家 ID，使用 socket ID
            name: playerName, // 玩家姓名
            seat: 0, // 座位号，初始为 0
            cards: [], // 手牌，初始为空数组
            cardCount: 0 // 手牌数量，初始为 0
        });

        rooms.set(roomId, room); // 将房间添加到 rooms Map 中
        socket.join(roomId); // 将 socket 加入房间
        socket.emit('roomCreated', roomId); // 向客户端发送 roomCreated 事件，携带房间 ID
        console.log(`房间 ${roomId} 已创建`); // 打印房间创建信息
    });

    // 加入房间事件
    socket.on('joinRoom', ({ roomId, playerName }) => {
        const room = rooms.get(roomId); // 从 rooms Map 中获取 GameRoom 对象
        if (!room) return socket.emit('error', '房间不存在'); // 如果房间不存在，向客户端发送 error 事件
        if (room.players.length >= 3) return socket.emit('error', '房间已满'); // 如果房间已满，向客户端发送 error 事件

        const newPlayer = { // 创建新的玩家对象
            id: socket.id, // 玩家 ID，使用 socket ID
            name: playerName, // 玩家姓名
            seat: room.players.length, // 座位号，为当前房间玩家数量
            cards: [], // 手牌，初始为空数组
            cardCount: 0 // 手牌数量，初始为 0
        };

        room.players.push(newPlayer); // 将新的玩家对象添加到房间的玩家列表中
        socket.join(roomId); // 将 socket 加入房间

        // 通知所有玩家更新
        io.to(roomId).emit('roomUpdate', { // 向房间内所有客户端发送 roomUpdate 事件，携带玩家列表
            players: room.players.map(p => ({ id: p.id, name: p.name })) // 映射玩家列表，只返回 ID 和姓名
        });

        // 自动开始游戏
        if (room.players.length === 3) { // 如果房间玩家数量达到 3 人，自动开始游戏
            room.dealCards(); // 发牌
            io.to(roomId).emit('gameStart', room.getStateForPlayer(socket.id)); // 向房间内所有客户端发送 gameStart 事件，携带游戏状态
        }
    });

    // 游戏动作处理事件
    socket.on('gameAction', (action) => {
        const room = getPlayerRoom(socket); // 获取玩家所在房间
        if (!room) return; // 如果房间不存在，直接返回

        switch (action.type) { // 根据 action 的类型，执行不同的操作
            case 'BID': // 叫分
                handleBid(room, socket, action.value); // 调用 handleBid 函数处理叫分
                break;
            case 'PLAY': // 出牌
                handlePlay(room, socket, action.cards); // 调用 handlePlay 函数处理出牌
                break;
            case 'PASS': // 跳过
                handlePass(room, socket); // 调用 handlePass 函数处理跳过
                break;
        }
    });

    // 断线处理事件
    socket.on('disconnect', () => {
        const room = getPlayerRoom(socket); // 获取玩家所在房间
        if (room) { // 如果房间存在
            room.players = room.players.filter(p => p.id !== socket.id); // 从房间的玩家列表中移除断线的玩家
            io.to(room.id).emit('playerLeft', socket.id); // 向房间内所有客户端发送 playerLeft 事件，携带断线玩家的 ID

            if (room.players.length === 0) { // 如果房间内没有玩家，删除房间
                rooms.delete(room.id);
            }
        }
    });
});

// 叫分处理函数
function handleBid(room, socket, score) {
    if (room.phase !== GamePhase.BIDDING) return; // 如果游戏阶段不是叫分阶段，直接返回
    if (score <= room.currentBid) return; // 如果叫分小于等于当前最高叫分，直接返回

    room.currentBid = score; // 更新当前最高叫分
    room.bidder = socket.id; // 记录叫分玩家的 ID
    room.bidCount++; // 叫分次数加 1

    // 轮转叫分
    room.currentPlayer = (room.currentPlayer + 1) % 3; // 更新当前玩家，轮到下一个玩家叫分

    // 叫分结束
    if (room.bidCount === 3 || score === 3) { // 如果叫分次数达到 3 次，或者叫分等于 3，叫分结束
        assignLandlord(room); // 指定地主
        room.phase = GamePhase.PLAYING; // 设置游戏阶段为 playing
    }

    broadcastRoomState(room); // 广播房间状态
}

// 指定地主函数
function assignLandlord(room) {
    const landlord = room.players.find(p => p.id === room.bidder); // 查找叫分玩家
    landlord.cards = [...landlord.cards, ...room.baseCards]; // 将底牌添加到地主的手牌中
    landlord.cardCount += 3; // 更新地主的手牌数量
    room.landlord = landlord.seat; // 设置地主的座位号
    room.currentPlayer = landlord.seat; // 设置当前玩家为地主
}

// 出牌处理函数
function handlePlay(room, socket, cards) {
    const player = room.players.find(p => p.id === socket.id); // 查找出牌玩家
    if (!validatePlay(room, player, cards)) return; // 如果出牌不合法，直接返回

    // 更新牌局状态
    player.cardCount -= cards.length; // 更新玩家的手牌数量
    player.cards = player.cards.filter(c => !cards.includes(c)); // 从玩家的手牌中移除出的牌
    room.lastPlay = { cards, player: player.seat }; // 记录上一次出的牌
    room.currentPlayer = (player.seat + 1) % 3; // 更新当前玩家，轮到下一个玩家出牌

    // 检查游戏结束
    if (player.cardCount === 0) { // 如果玩家的手牌数量为 0，游戏结束
        room.phase = GamePhase.ENDED; // 设置游戏阶段为 ended
    }

    broadcastRoomState(room); // 广播房间状态
}

// 出牌验证函数
function validatePlay(room, player, cards) {
    // 基础验证
    if (cards.length === 0) return false; // 如果出的牌为空，不合法
    if (!cards.every(c => player.cards.includes(c))) return false; // 如果出的牌不在玩家的手牌中，不合法

    // TODO: 调用前端验证逻辑或实现服务端验证
    // 这里可以添加更复杂的出牌规则验证，例如牌型、大小等

    return true; // 出牌合法
}

// 跳过处理函数
function handlePass(room, socket) {
    room.currentPlayer = (room.currentPlayer + 1) % 3; // 更新当前玩家，轮到下一个玩家出牌
    broadcastRoomState(room); // 广播房间状态
}

// 广播房间状态函数
function broadcastRoomState(room) {
    room.players.forEach(player => { // 遍历房间内的所有玩家
        io.to(player.id).emit('gameUpdate', room.getStateForPlayer(player.id)); // 向每个玩家发送 gameUpdate 事件，携带游戏状态
    });
}

// 启动 http 服务器，监听 3000 端口
httpServer.listen(3000, () => {
    console.log('服务器运行在 http://localhost:3000');
});
