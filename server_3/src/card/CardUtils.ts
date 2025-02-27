
import { Poker } from '../models/Poker';
import { CardValue, CardType, CardTypeEnum } from './CardType';

export class CardUtils {
    // 卡牌排序（降序排列）
    static sortCards(cards: Poker[]): Poker[] {
        return [...cards].sort((a, b) => b.weight - a.weight);
    }

    // 牌型验证
    static validateCards(cards: Poker[]): { isValid: boolean; type: CardTypeEnum } {
        return {
            isValid: CardType.getType(cards) !== CardTypeEnum.Invalid,
            type: CardType.getType(cards)
        };
    }

    // 比较两组卡牌的大小
    static isBigger(currentCards: Poker[], lastCards: Poker[]): boolean {
        const currentType = CardType.getType(currentCards);
        const lastType = CardType.getType(lastCards);

        // 无效牌型直接返回false
        if (currentType === CardTypeEnum.Invalid) return false;

        // 火箭最大
        if (currentType === CardTypeEnum.Rocket) return true;
        if (lastType === CardTypeEnum.Rocket) return false;

        // 炸弹比较
        if (currentType === CardTypeEnum.Bomb) {
            return lastType !== CardTypeEnum.Bomb ||
                this.getKeyCardWeight(currentCards) > this.getKeyCardWeight(lastCards);
        }

        // 牌型不同不能比较
        if (currentType !== lastType) return false;

        // 相同牌型比较
        return this.getKeyCardWeight(currentCards) > this.getKeyCardWeight(lastCards);
    }

    // 获取关键牌权重（用于比较的核心牌值）
    private static getKeyCardWeight(cards: Poker[]): number {
        const sorted = this.sortCards(cards);
        const type = CardType.getType(cards);

        switch (type) {
            case CardTypeEnum.Single:
            case CardTypeEnum.Pair:
            case CardTypeEnum.Three:
            case CardTypeEnum.Bomb:
                return sorted[0].weight;

            case CardTypeEnum.Straight:
            case CardTypeEnum.StraightPair:
                return sorted[0].weight; // 取最大牌值

            case CardTypeEnum.ThreeWithOne:
            case CardTypeEnum.ThreeWithTwo:
                return this.findThreePart(cards)[0].weight;

            case CardTypeEnum.Plane:
            case CardTypeEnum.PlaneWithWings:
                const planeCards = this.findPlanePart(cards);
                return planeCards[0].weight;

            case CardTypeEnum.FourWithTwo:
            case CardTypeEnum.FourWithTwoPair:
                return this.findFourPart(cards)[0].weight;

            default:
                return 0;
        }
    }

    // 辅助方法：查找三张部分
    private static findThreePart(cards: Poker[]): Poker[] {
        const counts = new Map<CardValue, number>();
        cards.forEach(card => counts.set(card.value, (counts.get(card.value) || 0) + 1));

        const threeValue = Array.from(counts.entries())
            .find(([_, count]) => count === 3)?.[0];

        return threeValue ? cards.filter(c => c.value === threeValue) : [];
    }

    // 辅助方法：查找四张部分
    private static findFourPart(cards: Poker[]): Poker[] {
        const counts = new Map<CardValue, number>();
        cards.forEach(card => counts.set(card.value, (counts.get(card.value) || 0) + 1));

        const fourValue = Array.from(counts.entries())
            .find(([_, count]) => count === 4)?.[0];

        return fourValue ? cards.filter(c => c.value === fourValue) : [];
    }

    // 辅助方法：查找飞机部分
    private static findPlanePart(cards: Poker[]): Poker[] {
        const counts = new Map<CardValue, number>();
        const triples = new Set<CardValue>();

        cards.forEach(card => {
            const count = (counts.get(card.value) || 0) + 1;
            counts.set(card.value, count);
            if (count === 3) triples.add(card.value);
        });

        return cards.filter(c => triples.has(c.value));
    }

    // 根据牌值获取权重（静态方法）
    static getCardWeight(value: CardValue): number {
        switch (value) {
            case CardValue.jokerBig: return 16;
            case CardValue.jokerSmall: return 15;
            case CardValue.two: return 14;
            case CardValue.ace: return 13;
            case CardValue.king: return 12;
            case CardValue.queen: return 11;
            case CardValue.jack: return 10;
            case CardValue.ten: return 9;
            case CardValue.nine: return 8;
            case CardValue.eight: return 7;
            case CardValue.seven: return 6;
            case CardValue.six: return 5;
            case CardValue.five: return 4;
            case CardValue.four: return 3;
            case CardValue.three: return 2;
            default: return 0;
        }
    }
}