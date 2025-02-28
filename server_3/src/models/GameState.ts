import { Poker } from './Poker';
import { Player } from './Player';
import { GamePhase } from '../constants/constants';

export class GameState {
    constructor(
        public gamePhase: GamePhase = GamePhase.preparing,
        public currentPlayerIndex: number = -1,
        public lastPlayedCards: Poker[] = [],
        public landlordIndex: number = -1,
        public additionalCards: Poker[] = [],
        public allCards: Poker[][] = [[], [], []],// 所有玩家的牌组
        public players: Player[] = [],// 玩家列表
    ) { }

    toJSON(index: number) {
        return {
            gamePhase: this.gamePhase,
            currentPlayerIndex: index,
            lastPlayedCards: this.lastPlayedCards.map(c => c.toJSON()),
            landlordIndex: this.landlordIndex,
            additionalCards: this.additionalCards.map(c => c.toJSON()),
            players: this.players,
            playerCards: this.allCards[index].map(c => c.toJSON())// 发送到客户端的我方玩家手牌
        };
    }

    copyWith({
        gamePhase,
        currentPlayerIndex,
        lastPlayedCards,
        landlordIndex,
        allCards,
        additionalCards,
    }: Partial<GameState>): GameState {
        return new GameState(
            gamePhase ?? this.gamePhase,
            currentPlayerIndex ?? this.currentPlayerIndex,
            lastPlayedCards ?? this.lastPlayedCards,
            landlordIndex ?? this.landlordIndex,
            additionalCards ?? this.additionalCards,
            allCards ?? this.allCards,
        );
    }
}