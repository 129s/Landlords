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
    static fromJSON(json: { suit: string; value: string }): Poker {
        // 转换花色字符串为枚举值
        const suitMapping: { [key: string]: Suit } = {
            'hearts': Suit.hearts,
            'diamonds': Suit.diamonds,
            'clubs': Suit.clubs,
            'spades': Suit.spades,
            'joker': Suit.joker
        };

        // 转换牌值字符串为枚举值
        const valueMapping: { [key: string]: CardValue } = {
            'three': CardValue.three,
            'four': CardValue.four,
            'five': CardValue.five,
            'six': CardValue.six,
            'seven': CardValue.seven,
            'eight': CardValue.eight,
            'nine': CardValue.nine,
            'ten': CardValue.ten,
            'jack': CardValue.jack,
            'queen': CardValue.queen,
            'king': CardValue.king,
            'ace': CardValue.ace,
            'two': CardValue.two,
            'jokerSmall': CardValue.jokerSmall,
            'jokerBig': CardValue.jokerBig
        }
        return new Poker(suitMapping[json.suit], valueMapping[json.value])
    }
    // 比较两张牌的大小
    compareTo(other: Poker): number {
        return this.weight - other.weight;
    }
}