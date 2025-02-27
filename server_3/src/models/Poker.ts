import { CardValue, Suit } from "../core/card/CardType";
import { CardUtils } from "../core/card/CardUtils";


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
    toJSON(): object {
        return {
            suit: this.suit,
            value: this.value,
            displayValue: this.displayValue, // 保留显示值方便调试
            suitSymbol: this.suitSymbol
        };
    }

    // 比较两张牌的大小
    compareTo(other: Poker): number {
        return this.weight - other.weight;
    }

    // 显示用文字（可用于日志）
    get displayValue(): string {
        switch (this.value) {
            case CardValue.jokerBig: return '大王';
            case CardValue.jokerSmall: return '小王';
            case CardValue.ace: return 'A';
            case CardValue.two: return '2';
            case CardValue.king: return 'K';
            case CardValue.queen: return 'Q';
            case CardValue.jack: return 'J';
            case CardValue.ten: return '10';
            default:
                const numValue = Number(this.value);
                return isNaN(numValue) ? '' : (numValue + 3).toString();
        }
    }

    // 花色符号（调试用）
    get suitSymbol(): string {
        switch (this.suit) {
            case Suit.hearts: return '♥';
            case Suit.diamonds: return '♦';
            case Suit.clubs: return '♣';
            case Suit.spades: return '♠';
            default: return '';
        }
    }
}