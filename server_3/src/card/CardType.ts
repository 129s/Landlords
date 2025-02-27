// src/models/CardType.ts
import { Poker } from '../models/Poker';
import { CardUtils } from './CardUtils';

export enum Suit { hearts, diamonds, clubs, spades, joker }

export enum CardValue {
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,
    ten,
    jack,
    queen,
    king,
    ace,
    two,
    jokerSmall, // 小王
    jokerBig, // 大王
}

export enum CardTypeEnum {
    Single = 'single',         // 单张
    Pair = 'pair',             // 对子
    Three = 'three',           // 三张
    ThreeWithOne = 'threeWithOne',     // 三带一
    ThreeWithTwo = 'threeWithTwo',     // 三带二
    Straight = 'straight',     // 顺子
    StraightPair = 'straightPair', // 连对
    Plane = 'plane',           // 飞机
    PlaneWithWings = 'planeWithWings', // 飞机带翅膀
    Bomb = 'bomb',             // 炸弹
    Rocket = 'rocket',          // 火箭
    FourWithTwo = 'fourWithTwo',   // 四带二
    FourWithTwoPair = 'fourWithTwoPair', // 四带两对
    Invalid = 'invalid'        // 无效牌型
}

export class CardType {
    static getType(cards: Poker[]): CardTypeEnum {
        if (cards.length === 0) return CardTypeEnum.Invalid;

        const sorted = CardUtils.sortCards(cards);
        const length = sorted.length;

        // 火箭判断
        if (length === 2 &&
            sorted[0].value === CardValue.jokerBig &&
            sorted[1].value === CardValue.jokerSmall) {
            return CardTypeEnum.Rocket;
        }

        // 统计牌值出现次数
        const counts = new Map<CardValue, number>();
        sorted.forEach(card => {
            counts.set(card.value, (counts.get(card.value) || 0) + 1);
        });

        // 炸弹判断
        if (counts.size === 1 && Array.from(counts.values())[0] === 4) {
            return CardTypeEnum.Bomb;
        }

        // 单张
        if (length === 1) return CardTypeEnum.Single;

        // 对子
        if (length === 2 && counts.size === 1 && Array.from(counts.values())[0] === 2) {
            return CardTypeEnum.Pair;
        }

        // 三张
        if (length === 3 && counts.size === 1 && Array.from(counts.values())[0] === 3) {
            return CardTypeEnum.Three;
        }

        // 顺子判断
        if (this.isStraight(sorted)) {
            return CardTypeEnum.Straight;
        }

        // 连对判断
        if (this.isStraightPair(sorted)) {
            return CardTypeEnum.StraightPair;
        }

        // 飞机判断
        if (this.isPlane(sorted)) {
            return CardTypeEnum.Plane;
        }

        // 三带一
        if (length === 4 && counts.size === 2 &&
            Array.from(counts.values()).some(v => v === 3) &&
            Array.from(counts.values()).some(v => v === 1)) {
            return CardTypeEnum.ThreeWithOne;
        }

        // 三带二
        if (length === 5 && counts.size === 2 &&
            Array.from(counts.values()).some(v => v === 3) &&
            Array.from(counts.values()).some(v => v === 2)) {
            return CardTypeEnum.ThreeWithTwo;
        }

        // 飞机带翅膀
        if (this.isPlaneWithWings(sorted)) {
            return CardTypeEnum.PlaneWithWings;
        }

        // 四带二
        if (length === 6 && counts.size === 3 &&
            Array.from(counts.values()).some(v => v === 4) &&
            Array.from(counts.values()).filter(v => v === 1).length === 2) {
            return CardTypeEnum.FourWithTwo;
        }

        // 四带两对
        if (length === 8 && counts.size === 3 &&
            Array.from(counts.values()).some(v => v === 4) &&
            Array.from(counts.values()).filter(v => v === 2).length === 2) {
            return CardTypeEnum.FourWithTwoPair;
        }

        return CardTypeEnum.Invalid;
    }

    private static isStraight(cards: Poker[]): boolean {
        if (cards.length < 5 || cards.length > 12) return false;

        for (let i = 0; i < cards.length - 1; i++) {
            if ([CardValue.two, CardValue.jokerBig, CardValue.jokerSmall]
                .includes(cards[i].value)) return false;

            if (CardUtils.getCardWeight(cards[i].value) -
                CardUtils.getCardWeight(cards[i + 1].value) !== 1) {
                return false;
            }
        }
        return true;
    }

    private static isStraightPair(cards: Poker[]): boolean {
        if (cards.length < 6 || cards.length % 2 !== 0) return false;

        for (let i = 0; i < cards.length; i += 2) {
            if (i + 1 >= cards.length || cards[i].value !== cards[i + 1].value) {
                return false;
            }

            if ([CardValue.two, CardValue.jokerBig, CardValue.jokerSmall]
                .includes(cards[i].value)) return false;

            if (i < cards.length - 2 &&
                CardUtils.getCardWeight(cards[i].value) -
                CardUtils.getCardWeight(cards[i + 2].value) !== 1) {
                return false;
            }
        }
        return true;
    }

    private static isPlane(cards: Poker[]): boolean {
        if (cards.length < 6 || cards.length % 3 !== 0) return false;

        const counts = new Map<CardValue, number>();
        cards.forEach(card => {
            counts.set(card.value, (counts.get(card.value) || 0) + 1);
        });

        if (Array.from(counts.values()).some(v => v !== 3)) return false;

        const sortedValues = Array.from(counts.keys()).sort((a, b) =>
            CardUtils.getCardWeight(b) - CardUtils.getCardWeight(a));

        for (let i = 0; i < sortedValues.length - 1; i++) {
            if (CardUtils.getCardWeight(sortedValues[i]) -
                CardUtils.getCardWeight(sortedValues[i + 1]) !== 1) {
                return false;
            }
        }
        return true;
    }

    private static isPlaneWithWings(cards: Poker[]): boolean {
        if (cards.length < 8) return false;

        const counts = new Map<CardValue, number>();
        cards.forEach(card => {
            counts.set(card.value, (counts.get(card.value) || 0) + 1);
        });

        const threeCounts = Array.from(counts.values())
            .filter(v => v === 3).length;
        const wingCounts = Array.from(counts.values())
            .filter(v => v === 1 || v === 2).length;

        if (threeCounts < 2 || threeCounts !== wingCounts) return false;

        const planeCards = cards.filter(c =>
            counts.get(c.value)! === 3);
        return this.isPlane(planeCards);
    }
}