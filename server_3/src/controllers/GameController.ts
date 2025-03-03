
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
    ) { }
    public handlePlayerAction(socket: Socket, action: PlayerAction, callback: Function) {
        const playerIndex = this.room.players.findIndex(p => p.id === socket.id);

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
        this.updateGameState();
    }

    // Room有人员离开时调用该方法
    public stopGame(reason: string = '游戏异常终止') {
        // 清除进行中的游戏数据
        this.gameState = new GameState();

        // 重置玩家状态
        this.gameState.players.forEach(player => {
            player.ready = false;
            player.isLandlord = false;
            player.bidValue = -1;
            player.cardCount = 0;
        });

        // 发送中断通知
        this.io.to(this.room.id).emit('gameInterrupted', {
            reason
        });

        // 更新游戏状态
        this.updateGameState();
    }

    // Room满员且都准备时或重新发牌时调用该方法，初始化游戏
    public initializeGame() {
        if (this.room.players.length !== 3) return;

        // 生成并分发扑克牌
        const allCards = this.generateAndShuffleCards();
        this.dealCards(allCards);

        // 进入叫分阶段
        this.gameState.gamePhase = GamePhase.bidding;
        this.gameState.currentPlayerIndex = 0; // 从第一个玩家开始叫分
        this.gameState.lastActivePlayerIndex = 0; // 从第一个玩家开始叫分

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
            Poker.fromJSON(c));


        // 验证牌型合法性
        if (!this.validatePlay(this.gameState, playedCards)) {
            callback({ 'status': 'fail' })
            return;
        }

        // 更新游戏状态
        this.gameState.allCards[playerIndex] = this.gameState.allCards[playerIndex].filter(p =>
            !playedCards.some(c => c.value == p.value && c.suit == p.suit));
        this.gameState.lastPlayedCards = playedCards;
        this.gameState.lastActivePlayerIndex = playerIndex;
        this.gameState.players[playerIndex].cardCount = this.gameState.allCards[playerIndex].length;

        this.gameState.currentPlayerIndex = (this.gameState.currentPlayerIndex + 1) % 3;

        // 检查游戏是否结束
        if (this.gameState.allCards[playerIndex].length === 0) {
            this.handleGameEnd();
            return;
        }

        this.updateGameState();
        callback({ 'status': 'success' })
    }

    private handlePlaceBid(playerIndex: number, bidValue: number, callback: Function) {
        // 阶段验证
        if (this.gameState.gamePhase !== GamePhase.bidding) {
            callback({ 'status': 'fail', 'reason': 'Not in bidding phase' });
            return;
        }

        // 轮到验证
        if (playerIndex !== this.gameState.currentPlayerIndex) {
            callback({ 'status': 'fail', 'reason': 'Not your turn to bid' });
            return;
        }

        // 参数有效性
        if (![0, 1, 2, 3].includes(bidValue)) { // 0表示不叫分
            callback({ 'status': 'fail', 'reason': 'Invalid bid value' });
            return;
        }

        const currentPlayer = this.gameState.players[playerIndex];
        const currentMaxBid = Math.max(...this.gameState.players.map(p => p.bidValue));


        if (bidValue !== 0) {
            // 非零叫分必须高于当前最高分
            if (bidValue <= currentMaxBid) {
                callback({ 'status': 'fail', 'reason': 'Bid must higher than current' });
                return;
            }
            this.gameState.lastActivePlayerIndex = playerIndex;// 非零叫分者成为当前最后一个活动玩家
        }
        currentPlayer.bidValue = bidValue;

        // 处理叫3分立即结束
        if (bidValue === 3) {
            return this.finalizeBidding(callback);
        }

        // 轮转
        this.gameState.currentPlayerIndex = (this.gameState.currentPlayerIndex + 1) % 3;

        // 检查是否轮转完成
        if (this.gameState.currentPlayerIndex === this.gameState.lastActivePlayerIndex) {
            this.finalizeBidding(callback);
        } else {
            this.updateGameState();
            callback({ 'status': 'success' });
        }
    }

    private finalizeBidding(callback: Function) {
        // 计算最高叫分
        const maxBid = Math.max(...this.gameState.players.map(p => p.bidValue));

        // 处理都不叫分的情况
        if (maxBid <= 0) {
            this.initializeGame(); // 重新发牌
            callback({ 'status': 'retry', 'reason': 'Redistributing cards' });
            return;
        }

        // 确定地主（取最后一个最高分玩家）
        const landlordIndex = this.gameState.players.reduce((acc, p, i) =>
            p.bidValue >= this.gameState.players[acc].bidValue ? i : acc, 0);

        // 分配地主身份
        this.gameState.players[landlordIndex].isLandlord = true;

        // 分发底牌
        this.gameState.allCards[landlordIndex].push(...this.gameState.additionalCards);
        this.gameState.allCards[landlordIndex].sort((a, b) => b.compareTo(a))

        // 更新地主剩余牌数
        this.gameState.players[landlordIndex].cardCount = 20;

        // 进入出牌阶段
        this.gameState.gamePhase = GamePhase.playing;
        this.gameState.currentPlayerIndex = landlordIndex;
        this.gameState.lastActivePlayerIndex = landlordIndex;

        callback({ 'status': 'success' });
        this.updateGameState();
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

        // 首轮不能跳过
        if (playerIndex == this.gameState.lastActivePlayerIndex) {
            callback({ 'status': 'fail' })
            return;
        }

        // 更新行动回合
        this.gameState.currentPlayerIndex = (this.gameState.currentPlayerIndex + 1) % 3;

        // 跳过轮次检测
        if (this.gameState.currentPlayerIndex === this.gameState.lastActivePlayerIndex) {
            this.gameState.lastPlayedCards = [];
        }

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
            cards.slice(0, 17).sort((a, b) => b.compareTo(a)),
            cards.slice(17, 34).sort((a, b) => b.compareTo(a)),
            cards.slice(34, 51).sort((a, b) => b.compareTo(a))
        ];
        // 底牌（最后3张）
        this.gameState.additionalCards = cards.slice(51, 54);

        // 更新剩余牌数
        this.gameState.players.forEach((player) => {
            player.cardCount = 17
        });

        this.updateGameState();
    }

    private validatePlay(gameState: GameState, playedCards: Poker[]): boolean {

        // 当lastPlayedCards为空时（新回合开始），只需验证牌型有效
        if (gameState.lastPlayedCards.length === 0) {
            return CardUtils.validateCards(playedCards).isValid;
        }

        return CardUtils.isBigger(playedCards, gameState.lastPlayedCards);
    }

    // 更新房间内所有玩家游戏状态
    private updateGameState() {
        this.room.players.forEach((player, index) => {
            console.log(`updateGameState: ${index}, ${player.id}`);
            console.log(this.gameState.toJSON(index));
            this.io.to(player.id).emit('gameStateUpdate',
                this.gameState.toJSON(index));
        });
    }

    private handleGameEnd() {
        // 确定获胜方
        const winnerIndex = this.gameState.players.findIndex(p => p.cardCount === 0);
        const isLandlordWin = this.gameState.players[winnerIndex].isLandlord;

        // 构建结果数据
        const result = {
            winnerIndex,
            isLandlordWin,
            players: this.gameState.players.map(p => ({
                id: p.id,
                isLandlord: p.isLandlord,
                finalCards: this.gameState.allCards
            }))
        };

        // 广播游戏结果
        this.io.to(this.room.id).emit('gameEnd', result);

        // 重置游戏状态
        this.gameState = new GameState();

        // 重置玩家状态
        this.room.players.forEach(player => {
            player.ready = false;
            player.isLandlord = false;
            player.bidValue = -1;
            player.cardCount = 0;
        });

        // 房间状态恢复等待
        this.room.roomStatus = RoomStatus.WAITING;
        this.updateGameState();
    }
}