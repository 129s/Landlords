class CardUtils {
    static shuffle(deck) {
        // Fisher-Yates shuffle algorithm
        for (let i = deck.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [deck[i], deck[j]] = [deck[j], deck[i]];
        }
        return deck;
    }

    static getCardType(cards) {
        if (!cards || cards.length === 0) return 'PASS';

        const sortedCards = this.sortCards([...cards]);
        const len = sortedCards.length;

        if (len === 1) return 'SINGLE';

        if (len === 2 && sortedCards[0].suit === 'joker') {
            return 'ROCKET'; // 王炸
        }

        if (len === 2 && sortedCards[0].value === sortedCards[1].value) return 'PAIR';

        if (len === 3 && sortedCards[0].value === sortedCards[1].value && sortedCards[1].value === sortedCards[2].value) return 'TRIPLE';

        if (len === 3 && sortedCards[0].value === sortedCards[1].value && sortedCards[1].value === sortedCards[2].value) return 'TRIPLE';

        if (len >= 5 && this.isStraight(sortedCards)) return 'STRAIGHT';

        if (len >= 6 && this.isStraightPair(sortedCards)) return 'STRAIGHT_PAIR';

        if (len === 4 && this.isBomb(sortedCards)) return 'BOMB';

        if (len === 4 && this.isTripleWithSingle(sortedCards)) return 'TRIPLE_WITH_SINGLE';

        if (len === 5 && this.isTripleWithPair(sortedCards)) return 'TRIPLE_WITH_PAIR';

        if (len >= 8 && this.isPlane(sortedCards)) return 'PLANE';

        if (len >= 12 && this.isPlaneWithWings(sortedCards)) return 'PLANE_WITH_WINGS';

        if (len === 6 || len === 8) {
            if (this.isFourWithTwo(sortedCards)) return 'FOUR_WITH_TWO';
        }

        return 'INVALID';
    }

    static isBigger(newCards, oldCards) {
        const newType = this.getCardType(newCards);
        const oldType = this.getCardType(oldCards);

        if (newType === 'INVALID') return false;
        if (oldType === 'PASS') return true;
        if (newType === 'ROCKET') return true;
        if (oldType === 'ROCKET') return false;
        if (newType === 'BOMB' && oldType !== 'BOMB') return true;
        if (newType !== 'BOMB' && oldType === 'BOMB') return false;

        if (newType !== oldType) return false;

        const newValue = this.getCardValue(newCards[0].value);
        const oldValue = this.getCardValue(oldCards[0].value);

        return newValue > oldValue;
    }

    static sortCards(cards) {
        const valueOrder = ['3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', '2', 'small', 'big'];
        return cards.sort((a, b) => {
            const valueA = valueOrder.indexOf(a.value);
            const valueB = valueOrder.indexOf(b.value);
            return valueA - valueB;
        });
    }

    static getCardValue(value) {
        const valueOrder = ['3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', '2', 'small', 'big'];
        return valueOrder.indexOf(value);
    }

    static isStraight(cards) {
        if (cards.length < 5) return false;
        for (let i = 0; i < cards.length - 1; i++) {
            const currentValue = this.getCardValue(cards[i].value);
            const nextValue = this.getCardValue(cards[i + 1].value);
            if (nextValue - currentValue !== 1 || cards[i].value === '2') return false;
        }
        return true;
    }

    static isStraightPair(cards) {
        if (cards.length < 6 || cards.length % 2 !== 0) return false;
        for (let i = 0; i < cards.length - 2; i += 2) {
            if (cards[i].value !== cards[i + 1].value) return false;
            const currentValue = this.getCardValue(cards[i].value);
            const nextValue = this.getCardValue(cards[i + 2].value);
            if (nextValue - currentValue !== 1 || cards[i].value === '2') return false;
        }
        return true;
    }

    static isBomb(cards) {
        if (cards.length !== 4) return false;
        return cards.every(card => card.value === cards[0].value);
    }

    static isTripleWithSingle(cards) {
        if (cards.length !== 4) return false;
        const counts = {};
        for (const card of cards) {
            counts[card.value] = (counts[card.value] || 0) + 1;
        }
        let hasTriple = false;
        let hasSingle = false;
        for (const value in counts) {
            if (counts[value] === 3) hasTriple = true;
            else if (counts[value] === 1) hasSingle = true;
        }
        return hasTriple && hasSingle;
    }

    static isTripleWithPair(cards) {
        if (cards.length !== 5) return false;
        const counts = {};
        for (const card of cards) {
            counts[card.value] = (counts[card.value] || 0) + 1;
        }
        let hasTriple = false;
        let hasPair = false;
        for (const value in counts) {
            if (counts[value] === 3) hasTriple = true;
            else if (counts[value] === 2) hasPair = true;
        }
        return hasTriple && hasPair;
    }

    static isPlane(cards) {
        if (cards.length < 6 || cards.length % 3 !== 0) return false;
        for (let i = 0; i < cards.length - 3; i += 3) {
            if (cards[i].value !== cards[i + 1].value || cards[i].value !== cards[i + 2].value) return false;
            const currentValue = this.getCardValue(cards[i].value);
            const nextValue = this.getCardValue(cards[i + 3].value);
            if (nextValue - currentValue !== 1 || cards[i].value === '2') return false;
        }
        return true;
    }

    static isPlaneWithWings(cards) {
        if (cards.length < 12 || cards.length % 4 !== 0) return false;
        const tripleCount = cards.length / 4;
        if (tripleCount < 2) return false;

        const triples = [];
        const singles = [];
        const counts = {};

        for (const card of cards) {
            counts[card.value] = (counts[card.value] || 0) + 1;
        }

        for (const value in counts) {
            if (counts[value] === 3) {
                triples.push(value);
            } else if (counts[value] === 1) {
                singles.push(value);
            } else {
                return false; // Invalid combination
            }
        }

        if (triples.length !== tripleCount || singles.length !== tripleCount) return false;

        const sortedTriples = triples.sort((a, b) => this.getCardValue(a) - this.getCardValue(b));

        for (let i = 0; i < sortedTriples.length - 1; i++) {
            const currentValue = this.getCardValue(sortedTriples[i]);
            const nextValue = this.getCardValue(sortedTriples[i + 1]);
            if (nextValue - currentValue !== 1 || sortedTriples[i] === '2') return false;
        }

        return true;
    }

    static isFourWithTwo(cards) {
        if (cards.length !== 6 && cards.length !== 8) return false;

        const counts = {};
        for (const card of cards) {
            counts[card.value] = (counts[card.value] || 0) + 1;
        }

        let hasFour = false;
        let hasTwo = false;

        for (const value in counts) {
            if (counts[value] === 4) hasFour = true;
            else if (counts[value] === 1 && cards.length === 6) hasTwo = true;
            else if (counts[value] === 2 && cards.length === 8) hasTwo = true;
        }

        return hasFour && hasTwo;
    }
}

module.exports = CardUtils;
