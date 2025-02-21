class CardType {
  static getType(cardIds) {
    const cards = this._idsToCards(cardIds);
    if (cards.length === 0) return 'INVALID';

    const sortedCards = this.sortCards(cards);
    const length = sortedCards.length;

    // 火箭检测
    if (length === 2 &&
      cards.some(c => c.value === 'JOKER_SMALL') &&
      cards.some(c => c.value === 'JOKER_BIG')) {
      return 'ROCKET';
    }

    // 统计牌值出现次数
    const counts = this._countValues(sortedCards);

    // 炸弹检测
    if (Object.keys(counts).length === 1 && counts[Object.keys(counts)[0]] === 4) {
      return 'BOMB';
    }

    // 其他牌型检测...
  }

  static _countValues(cards) {
    return cards.reduce((acc, { value }) => {
      acc[value] = (acc[value] || 0) + 1;
      return acc;
    }, {});
  }

  static _idsToCards(ids) {
    return ids.map(id => {
      if (id === 52) return { value: 'JOKER_SMALL' };
      if (id === 53) return { value: 'JOKER_BIG' };

      const valueIndex = Math.floor(id / 4);
      const values = ['3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', '2'];
      return { value: values[valueIndex] };
    });
  }

  static sortCards(cards) {
    const weights = {
      '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9, '10': 10,
      'J': 11, 'Q': 12, 'K': 13, 'A': 14, '2': 15,
      'JOKER_SMALL': 16, 'JOKER_BIG': 17
    };

    return [...cards].sort((a, b) => weights[b.value] - weights[a.value]);
  }
}