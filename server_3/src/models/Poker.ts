import { CardValue, Suit } from "../card/CardType";
import { CardUtils } from "../card/CardUtils";


export class Poker {
    constructor(
        public readonly suit: Suit,
        public readonly value: CardValue
    ) { }

    // 权重值用于比较大小（后端核心逻辑需要）
    get weight(): number {
        return CardUtils.getCardWeight(this.value);
    }

    // 序列化方法（用于网络传输）
    toJSON() {
        return {
            suit: Suit[this.suit],
            value: CardValue[this.value]
        };
    }

    // 比较两张牌的大小
    compareTo(other: Poker): number {
        return this.weight - other.weight;
    }
}