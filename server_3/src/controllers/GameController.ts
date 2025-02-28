
import { Server, Socket } from "socket.io";
import { CardUtils } from "../card/CardUtils";
import { CardTypeEnum, CardValue, Suit } from "../card/CardType";
import { GameState } from "../models/GameState";
import { Poker } from "../models/Poker";
import { GamePhase } from "../constants/constants";
import { RoomController } from "./RoomController";
import { v4 as uuidv4 } from 'uuid';
import { Room, RoomStatus } from "../models/Room";
import { Player } from "../models/Player";

interface PlayerAction {
    type: string;
    data?: any;
}

export class GameController {
    private gameStates = new Map<string, GameState>();
    private roomController: RoomController;

    constructor(private io: Server, roomController: RoomController) {
        this.roomController = roomController;
        this.setupSocketHandlers();
    }

    // Room更新时相应调用该方法，保持room和gamestate的players列表一致
    // 考虑重构这部分实现
    public updatePlayers(roomId: string, players: Player[]) {
        const gameState = this.gameStates.get(roomId);

        if (!gameState) {
            console.log("null gameState");
            return;
        }

        gameState.players = players;
    }

    // 初始化游戏
    private initializeGame(roomId: string) {
        const room = this.roomController.getRoom(roomId);

        if (!room || room.players.length !== 3) return;
        const gameState = new GameState();

        // 生成并分发扑克牌
        const allCards = this.generateAndShuffleCards();
        this.dealCards(roomId, gameState, allCards);

        // 进入叫分阶段
        gameState.gamePhase = GamePhase.bidding;
        gameState.currentPlayerIndex = 0; // 从第一个玩家开始叫分

        this.gameStates.set(roomId, gameState);
        this.updateGameState(roomId);
    }

    // 监听事件
    private setupSocketHandlers() {
        this.io.on('connection', (socket: Socket) => {
            // 客户端的玩家操作
            socket.on('playerAction', (action, callback) => this.handlePlayerAction(socket, action, callback));
        });
    }

    private handlePlayerAction(socket: Socket, action: PlayerAction, callback: Function) {
        const playerIndex = this.roomController.getPlayerIndexFromSocket(socket.id);
        const roomId = this.getPlayerRoomId(socket.id);

        console.log("PlayerAction: " + action.type);

        switch (action.type) {
            case 'playCards':
                this.handlePlayCards(roomId, playerIndex, action.data, callback);
                break;
            case 'placeBid':
                this.handlePlaceBid(roomId, playerIndex, action.data, callback);
                break;
            case 'passTurn':
                this.handlePassTurn(roomId, playerIndex, callback);
                break;
            case 'toggleReady':
                this.handleToggleReady(socket, callback);
                break;
            default:
                throw new Error('Invalid action type');
        }
    }

    private handlePlayCards(roomId: string, playerIndex: number, cards: Array<Poker>, callback: Function) {
        console.log(cards);
        const gameState = this.gameStates.get(roomId);

        if (!gameState) {
            callback({ 'status': 'fail' })
            console.log("null gameState");
            return;
        }

        if (playerIndex != gameState.currentPlayerIndex) {
            callback({ 'status': 'fail' })
            console.log("not your turn");
            return;
        }

        // 转换卡牌对象
        const playedCards = cards.map((c: any) =>
            new Poker(c.suit, c.value as CardValue));

        // 验证牌型合法性
        if (!this.validatePlay(gameState, playedCards)) {
            callback({ 'status': 'fail' })
            return;
        }

        // 更新游戏状态
        gameState.allCards[playerIndex] = gameState.allCards[playerIndex].filter(p =>
            !playedCards.some(c => c.value === p.value && c.suit === p.suit));
        gameState.lastPlayedCards = playedCards;

        gameState.currentPlayerIndex = (gameState.currentPlayerIndex + 1) % 3;

        // 检查游戏是否结束
        if (gameState.allCards[playerIndex].length === 0) {
            this.handleGameEnd(roomId);
            return;
        }

        this.updateGameState(roomId);
        callback({ 'status': 'success' })
    }

    private handlePlaceBid(roomId: string, playerIndex: number, value: number, callback: Function) {
        const gameState = this.gameStates.get(roomId);

        if (!gameState) {
            callback({ 'status': 'fail' })
            console.log("null gameState");
            return;
        }

        if (playerIndex != gameState.currentPlayerIndex) {
            callback({ 'status': 'fail' })
            console.log("not your turn");
            return;
        }

        // 更新叫分状态
        gameState.players[playerIndex].bidValue = value;

        gameState.currentPlayerIndex = (gameState.currentPlayerIndex + 1) % 3;

        // 叫分结束处理
        if (this.checkBidCompletion(gameState)) {
            // 确定最高叫分者
            let maxBid = 0;
            let landlordIndex = -1;
            gameState.players.forEach((player, index) => {
                if (player.bidValue > maxBid) {
                    maxBid = player.bidValue;
                    landlordIndex = index;
                }
            });

            // 分配地主身份
            gameState.landlordIndex = landlordIndex;
            gameState.players[landlordIndex].isLandlord = true;

            // 分配底牌
            gameState.allCards[landlordIndex].push(...gameState.additionalCards);

            // 进入出牌阶段
            gameState.gamePhase = GamePhase.playing;
            gameState.currentPlayerIndex = landlordIndex;
        }

        this.updateGameState(roomId);
        callback({ 'status': 'success' })
    }

    private checkBidCompletion(gameState: GameState): boolean {
        // 条件1：有玩家叫3分
        if (gameState.players.some(p => p.bidValue === 3)) return true;

        // 条件2：连续两位pass
        const lastTwoPlayers = [
            gameState.players[(gameState.currentPlayerIndex + 1) % 3],
            gameState.players[(gameState.currentPlayerIndex + 2) % 3]
        ];
        if (lastTwoPlayers.every(p => p.bidValue === -1)) return true;

        // 条件3：所有玩家完成叫分
        return gameState.players.every(p => p.bidValue !== undefined);
    }

    private handlePassTurn(roomId: string, playerIndex: number, callback: Function) {
        const gameState = this.gameStates.get(roomId);

        if (!gameState) {
            callback({ 'status': 'fail' })
            console.log("null gameState");
            return;
        }

        if (playerIndex != gameState.currentPlayerIndex) {
            callback({ 'status': 'fail' })
            console.log("not your turn");
            return;
        }

        if (gameState.gamePhase != GamePhase.playing) {
            callback({ 'status': 'fail' })
            return;
        }

        gameState.currentPlayerIndex = (gameState.currentPlayerIndex + 1) % 3;
        this.updateGameState(roomId);
        callback({ 'status': 'success' });
    }

    private handleToggleReady(socket: Socket, callback: Function) {
        const room = this.roomController.getPlayerRoom(socket.id);
        if (!room) {
            callback({ 'status': 'fail' });
            return;
        }

        const player = room.players.find(p => p.socketId === socket.id);
        if (!player) {
            callback({ 'status': 'fail' });
            return;
        }

        player.ready = !player.ready;

        // 检测是否开始游戏
        if (room.players.every(p => p.ready) &&
            room.players.length === 3) {
            room.roomStatus = RoomStatus.PLAYING;
            this.initializeGame(room.id);
        }

        this.roomController.updateRoomState(room);
        callback({ 'status': 'success' });
    }

    // 生成并洗牌
    private generateAndShuffleCards(): Poker[] {
        const cards: Poker[] = [];
        // 生成普通牌
        for (const suit of [Suit.hearts, Suit.diamonds, Suit.clubs, Suit.spades]) {
            for (let value = CardValue.three; value <= CardValue.two; value++) {
                cards.push(new Poker(suit, value as CardValue));
            }
        }
        // 添加大小王
        cards.push(new Poker(Suit.joker, CardValue.jokerSmall));
        cards.push(new Poker(Suit.joker, CardValue.jokerBig));

        // Fisher-Yates洗牌算法
        for (let i = cards.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [cards[i], cards[j]] = [cards[j], cards[i]];
        }
        console.log(...cards);
        return cards;
    }

    // 发牌
    private dealCards(roomId: string, gameState: GameState, cards: Poker[]) {
        // 给玩家发牌（每人17张）
        gameState.allCards = [
            cards.slice(0, 17),
            cards.slice(17, 34),
            cards.slice(34, 51)
        ];
        // 底牌（最后3张）
        gameState.additionalCards = cards.slice(51, 54);

        this.updateGameState(roomId);
    }

    private validatePlay(gameState: GameState, playedCards: Poker[]): boolean {
        // 使用CardUtils验证牌型
        const { isValid, type } = CardUtils.validateCards(playedCards);

        // 首轮出牌或需要压过前一轮
        if (gameState.lastPlayedCards.length === 0) {
            return type !== CardTypeEnum.Invalid;
        }

        return CardUtils.isBigger(playedCards, gameState.lastPlayedCards);
    }

    private updateGameState(roomId: string) {
        console.log("updateGameState");
        const gameState = this.gameStates.get(roomId);
        if (!gameState) return;

        for (let i = 0; i < 3; i++) {
            let id = this.roomController.getRoom(roomId)?.players[i].socketId;
            if (!id) return;
            this.io.to(id).emit('gameStateUpdate', gameState.toJSON(i));
        }
    }

    private handleGameEnd(roomId: string) {
        const gameState = this.gameStates.get(roomId);
        if (!gameState) return;

        // 确定获胜队伍

        // 发送游戏结束事件

        // 清理游戏状态
        this.gameStates.delete(roomId);
    }

    private getPlayerRoomId(socketId: string): string {
        const room = this.roomController.getPlayerRoom(socketId);
        if (!room?.id) {
            throw new Error(`Player ${socketId} not in any room`);
        }
        return room.id;
    }
}