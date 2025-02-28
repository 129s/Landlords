
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
    private gameState = new GameState();

    constructor(
        private io: Server,
        private room: Room
    ) {
        this.setupSocketHandlers();
    }

    // 监听玩家操作事件
    private setupSocketHandlers() {
        this.io.on('connection', (socket: Socket) => {
            socket.on('playerAction', (action, callback) => {
                if (this.room.players.some(p => p.socketId === socket.id)) {
                    this.handlePlayerAction(socket, action, callback);
                }
            });
        });
    }

    private handlePlayerAction(socket: Socket, action: PlayerAction, callback: Function) {
        const playerIndex = this.room.players.findIndex(p => p.socketId === socket.id);

        console.log("PlayerAction: " + action.type);

        switch (action.type) {
            case 'playCards':
                this.handlePlayCards(playerIndex, action.data, callback);
                break;
            case 'placeBid':
                this.handlePlaceBid(playerIndex, action.data, callback);
                break;
            case 'passTurn':
                this.handlePassTurn(playerIndex, callback);
                break;
            default:
                throw new Error('Invalid action type');
        }
    }

    // Room更新时相应调用该方法，保持room和gamestate的players列表一致
    public updatePlayers(players: Player[]) {
        this.gameState.players = players;
    }

    // Room满员且都准备时调用该方法，初始化游戏
    public initializeGame() {
        if (this.room.players.length !== 3) return;

        // 生成并分发扑克牌
        const allCards = this.generateAndShuffleCards();
        this.dealCards(allCards);

        // 进入叫分阶段
        this.gameState.gamePhase = GamePhase.bidding;
        this.gameState.currentPlayerIndex = 0; // 从第一个玩家开始叫分

        //更新游戏状态
        this.updateGameState();
    }


    private handlePlayCards(playerIndex: number, cards: Array<Poker>, callback: Function) {
        console.log(cards);

        // 验证是否为当前玩家回合
        if (playerIndex != this.gameState.currentPlayerIndex) {
            callback({ 'status': 'fail' })
            console.log("not your turn");
            return;
        }

        // 转换卡牌对象
        const playedCards = cards.map((c: any) =>
            new Poker(c.suit, c.value as CardValue));

        // 验证牌型合法性
        if (!this.validatePlay(this.gameState, playedCards)) {
            callback({ 'status': 'fail' })
            return;
        }

        // 更新游戏状态
        this.gameState.allCards[playerIndex] = this.gameState.allCards[playerIndex].filter(p =>
            !playedCards.some(c => c.value === p.value && c.suit === p.suit));
        this.gameState.lastPlayedCards = playedCards;

        this.gameState.currentPlayerIndex = (this.gameState.currentPlayerIndex + 1) % 3;

        // 检查游戏是否结束
        if (this.gameState.allCards[playerIndex].length === 0) {
            this.handleGameEnd();
            return;
        }

        this.updateGameState();
        callback({ 'status': 'success' })
    }

    private handlePlaceBid(playerIndex: number, value: number, callback: Function) {

        if (playerIndex != this.gameState.currentPlayerIndex) {
            callback({ 'status': 'fail' })
            console.log("not your turn");
            return;
        }

        // 更新叫分状态
        this.gameState.players[playerIndex].bidValue = value;

        // 更新行动回合
        this.gameState.currentPlayerIndex = (this.gameState.currentPlayerIndex + 1) % 3;

        // 叫分结束处理
        if (this.checkBidCompletion(this.gameState)) {
            // 确定最高叫分者
            let maxBid = 0;
            let landlordIndex = -1;
            this.gameState.players.forEach((player, index) => {
                if (player.bidValue > maxBid) {
                    maxBid = player.bidValue;
                    landlordIndex = index;
                }
            });

            // 分配地主身份
            this.gameState.landlordIndex = landlordIndex;
            this.gameState.players[landlordIndex].isLandlord = true;

            // 分配底牌
            this.gameState.allCards[landlordIndex].push(...this.gameState.additionalCards);

            // 进入出牌阶段
            this.gameState.gamePhase = GamePhase.playing;
            this.gameState.currentPlayerIndex = landlordIndex;
        }

        this.updateGameState();
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

    private handlePassTurn(playerIndex: number, callback: Function) {

        if (playerIndex != this.gameState.currentPlayerIndex) {
            callback({ 'status': 'fail' })
            console.log("not your turn");
            return;
        }

        if (this.gameState.gamePhase != GamePhase.playing) {
            callback({ 'status': 'fail' })
            return;
        }

        // 更新行动回合
        this.gameState.currentPlayerIndex = (this.gameState.currentPlayerIndex + 1) % 3;

        this.updateGameState();
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
    private dealCards(cards: Poker[]) {
        // 给玩家发牌（每人17张）
        this.gameState.allCards = [
            cards.slice(0, 17),
            cards.slice(17, 34),
            cards.slice(34, 51)
        ];
        // 底牌（最后3张）
        this.gameState.additionalCards = cards.slice(51, 54);

        this.updateGameState();
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

    // 更新房间内所有玩家游戏状态
    private updateGameState() {
        console.log("updateGameState");
        this.room.players.forEach((player, index) => {
            this.io.to(player.socketId).emit('gameStateUpdate',
                this.gameState.toJSON(index));
        });
    }

    private handleGameEnd() {
    }
}