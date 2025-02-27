
import { Server, Socket } from "socket.io";
import { CardUtils } from "../card/CardUtils";
import { CardTypeEnum, CardValue, Suit } from "../card/CardType";
import { GameState } from "../models/GameState";
import { Poker } from "../models/Poker";
import { GamePhase } from "../constants/constants";
import { RoomController } from "./RoomController";
import { v4 as uuidv4 } from 'uuid';

export class GameController {
    private gameStates = new Map<string, GameState>();
    private roomController: RoomController;

    constructor(private io: Server, roomController: RoomController) {
        this.roomController = roomController;
        this.setupSocketHandlers();
    }

    private setupSocketHandlers() {
        this.io.on('connection', (socket: Socket) => {
            socket.on('playCards', (cards: any[], callback) =>
                this.handlePlayCards(socket, cards, callback));
            socket.on('placeBid', (value: number) =>
                this.handlePlaceBid(socket, value));
            socket.on('passTurn', () =>
                this.handlePassTurn(socket));
        });
    }

    // 初始化游戏（由RoomController在房间满人时调用）
    public initializeGame(roomId: string) {
        const gameState = new GameState();
        const room = this.roomController.getRoom(roomId);

        if (!room || room.players.length !== 3) return;

        // 生成并分发扑克牌
        const allCards = this.generateAndShuffleCards();
        this.dealCards(roomId, gameState, allCards);

        gameState.gamePhase = GamePhase.bidding;
        gameState.currentPlayerIndex = 0; // 从第一个玩家开始叫分

        this.gameStates.set(roomId, gameState);
        this.updateGameState(roomId);
    }

    private handlePlayCards(socket: Socket, cards: any[], callback: Function) {
        const roomId = this.getPlayerRoomId(socket.id);
        const gameState = this.gameStates.get(roomId);
        const playerIndex = this.roomController.getPlayerIndexFromSocket(socket.id);

        if (!gameState) {
            console.log("null gameState");
            return;
        }

        if (playerIndex != gameState.currentPlayerIndex) {
            console.log("not your turn");
            return;
        }

        // 转换卡牌对象
        const playedCards = cards.map((c: any) =>
            new Poker(c.suit, c.value as CardValue));

        // 验证牌型合法性
        if (!this.validatePlay(gameState, playedCards)) {
            callback({ success: false, error: "Invalid card combination" });
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
        callback({ success: true });
    }

    private handlePlaceBid(socket: Socket, value: number) {
        const roomId = this.getPlayerRoomId(socket.id);
        const gameState = this.gameStates.get(roomId);
        const playerIndex = this.roomController.getPlayerIndexFromSocket(socket.id);

        if (!gameState) {
            console.log("null gameState");
            return;
        }

        if (playerIndex != gameState.currentPlayerIndex) {
            console.log("not your turn");
            return;
        }

        // 更新叫分状态
        gameState.allBids[playerIndex] = value;

        gameState.currentPlayerIndex = (gameState.currentPlayerIndex + 1) % 3;

        // 叫分结束处理
        if (value == 3) {
            gameState.landlordIndex = playerIndex;
            gameState.gamePhase = GamePhase.playing;
        }
        if (gameState.allBids.length >= 3) {
            gameState.landlordIndex = gameState.allBids.reduce((maxIndex, currentValue, currentIndex, array) => {
                return currentValue > array[maxIndex] ? currentIndex : maxIndex;
            }, 0);
            gameState.gamePhase = GamePhase.playing;
        }

        this.updateGameState(roomId);
    }

    private handlePassTurn(socket: Socket) {
        const roomId = this.getPlayerRoomId(socket.id);
        const gameState = this.gameStates.get(roomId);
        const playerIndex = this.roomController.getPlayerIndexFromSocket(socket.id);

        if (!gameState) {
            console.log("null gameState");
            return;
        }

        if (playerIndex != gameState.currentPlayerIndex) {
            console.log("not your turn");
            return;
        }

        // 在出牌阶段pass
        if (gameState.gamePhase === GamePhase.playing) {
            gameState.currentPlayerIndex = (gameState.currentPlayerIndex + 1) % 3;
            this.updateGameState(roomId);
        }
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
        return cards;
    }

    // 发牌
    private dealCards(roomId: string, gameState: GameState, allCards: Poker[]) {
        // 给玩家发牌（每人17张）
        gameState.allCards = [
            allCards.slice(0, 17),
            allCards.slice(17, 34),
            allCards.slice(34, 51)
        ];
        // 底牌（最后3张）
        gameState.additionalCards = allCards.slice(51, 54);

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
        const gameState = this.gameStates.get(roomId);
        if (!gameState) return;

        for (let i = 0; i < 3; i++) {
            let id = this.roomController.getRoom(roomId)?.players[i].socketId;
            if (!id) return;
            this.io.to(id).emit('gameUpdate', gameState.toJSON(i));
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