import { Poker } from './Poker';
import { Player } from './Player';
import { GamePhase } from '../constants/constants';

export class GameState {
    constructor(
        public players: Player[] = [],
        public gamePhase: GamePhase = GamePhase.preparing,
        public currentPlayerIndex: number = -1,
        public lastPlayedCards: Poker[] = [],
        public allCards: Poker[][] = [[], [], []],// 所有玩家的牌组，服务端属性不发送给客户端
        public landlordIndex: number = -1,
        public additionalCards: Poker[] = [],
        public highestBid: number = 0,
        public playerCards: Poker[] = []
    ) { }

    toJSON() {
        return {
            players: this.players.map(p => ({
                id: p.id,
                name: p.name,
                cardCount: p.cardCount,
                isLandlord: p.isLandlord
            })),
            gamePhase: this.gamePhase,
            currentPlayerIndex: this.currentPlayerIndex,
            lastPlayedCards: this.lastPlayedCards.map(c => c.toJSON()),
            landlordIndex: this.landlordIndex,
            additionalCards: this.additionalCards.map(c => c.toJSON()),
            highestBid: this.highestBid,
            playerCards: this.playerCards.map(c => c.toJSON())
        };
    }

    copyWith({
        players,
        gamePhase,
        currentPlayerIndex,
        lastPlayedCards,
        landlordIndex,
        allCards,
        additionalCards,
        highestBid,
        playerCards
    }: Partial<GameState>): GameState {
        return new GameState(
            players ?? this.players,
            gamePhase ?? this.gamePhase,
            currentPlayerIndex ?? this.currentPlayerIndex,
            lastPlayedCards ?? this.lastPlayedCards,
            allCards ?? this.allCards,
            landlordIndex ?? this.landlordIndex,
            additionalCards ?? this.additionalCards,
            highestBid ?? this.highestBid,
            playerCards ?? this.playerCards
        );
    }

    // 辅助方法：判断是否可以出牌
    canPlayCards(playerId: string): boolean {
        const player = this.players.find(p => p.id === playerId);
        return !!player &&
            this.gamePhase === GamePhase.playing &&
            this.currentPlayerIndex === this.players.indexOf(player);
    }

    // 辅助方法：判断是否可以叫分
    canPlaceBid(playerId: string): boolean {
        const player = this.players.find(p => p.id === playerId);
        return !!player &&
            this.gamePhase === GamePhase.bidding &&
            this.currentPlayerIndex === this.players.indexOf(player);
    }
}