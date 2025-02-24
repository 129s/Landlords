import 'package:landlords_3/domain/entities/poker_model.dart';
import 'package:landlords_3/core/card/card_utils.dart';

enum CardTypeEnum {
  single, // 单张
  pair, // 对子
  three, // 三张
  threeWithOne, // 三带一
  threeWithTwo, // 三带二
  straight, // 顺子
  straightPair, // 连对
  plane, // 飞机
  planeWithWings, // 飞机带翅膀
  bomb, // 炸弹
  rocket, // 火箭
  fourWithTwo, // 四带二
  fourWithTwoPair, // 四带两对
  invalid, // 不合法的牌型
}

class CardType {
  static CardTypeEnum getType(List<PokerModel> cards) {
    if (cards.isEmpty) return CardTypeEnum.invalid;

    final sortedCards = CardUtils.sortCards(cards);
    final length = sortedCards.length;

    // 火箭
    if (length == 2 &&
        sortedCards[0].value == CardValue.jokerBig &&
        sortedCards[1].value == CardValue.jokerSmall) {
      return CardTypeEnum.rocket;
    }

    // 统计每张牌的数量
    final counts = <CardValue, int>{};
    for (final card in sortedCards) {
      counts[card.value] = (counts[card.value] ?? 0) + 1;
    }

    // 炸弹
    if (counts.length == 1 && counts.values.first == 4) {
      return CardTypeEnum.bomb;
    }

    // 单张
    if (length == 1) {
      return CardTypeEnum.single;
    }

    // 对子
    if (length == 2 && counts.length == 1 && counts.values.first == 2) {
      return CardTypeEnum.pair;
    }

    // 三张
    if (length == 3 && counts.length == 1 && counts.values.first == 3) {
      return CardTypeEnum.three;
    }

    // 顺子
    if (_isStraight(sortedCards)) {
      return CardTypeEnum.straight;
    }

    // 连对
    if (_isStraightPair(sortedCards)) {
      return CardTypeEnum.straightPair;
    }

    // 飞机
    if (_isPlane(sortedCards)) {
      return CardTypeEnum.plane;
    }

    // 三带一
    if (length == 4 &&
        counts.length == 2 &&
        counts.containsValue(3) &&
        counts.containsValue(1)) {
      return CardTypeEnum.threeWithOne;
    }

    // 三带二
    if (length == 5 &&
        counts.length == 2 &&
        counts.containsValue(3) &&
        counts.containsValue(2)) {
      return CardTypeEnum.threeWithTwo;
    }

    // 飞机带翅膀
    if (_isPlaneWithWings(sortedCards)) {
      return CardTypeEnum.planeWithWings;
    }

    // 四带二
    if (length == 6 &&
        counts.length == 3 &&
        counts.containsValue(4) &&
        counts.containsValue(1)) {
      return CardTypeEnum.fourWithTwo;
    }

    // 四带两对
    if (length == 8 &&
        counts.length == 3 &&
        counts.containsValue(4) &&
        counts.containsValue(2)) {
      return CardTypeEnum.fourWithTwoPair;
    }

    return CardTypeEnum.invalid;
  }

  // 判断是否是顺子
  static bool _isStraight(List<PokerModel> cards) {
    if (cards.length < 5 || cards.length > 12) return false; // 顺子长度必须在 5-12 之间
    for (int i = 0; i < cards.length - 1; i++) {
      if (cards[i].value == CardValue.two ||
          cards[i].value == CardValue.jokerBig ||
          cards[i].value == CardValue.jokerSmall)
        return false; // 顺子不能包含 2 和大小王
      if (CardUtils.getCardWeight(cards[i]) -
              CardUtils.getCardWeight(cards[i + 1]) !=
          1)
        return false; // 必须是连续的
    }
    return true;
  }

  // 判断是否是连对
  static bool _isStraightPair(List<PokerModel> cards) {
    if (cards.length < 6 || cards.length % 2 != 0)
      return false; // 连对长度必须大于等于 6 且是偶数
    for (int i = 0; i < cards.length - 2; i += 2) {
      if (cards[i].value != cards[i + 1].value) return false; // 必须是对子
      if (cards[i].value == CardValue.two ||
          cards[i].value == CardValue.jokerBig ||
          cards[i].value == CardValue.jokerSmall)
        return false; // 连对不能包含 2 和大小王
      if (CardUtils.getCardWeight(cards[i]) -
              CardUtils.getCardWeight(cards[i + 2]) !=
          1)
        return false; // 必须是连续的
    }
    return true;
  }

  // 判断是否是飞机
  static bool _isPlane(List<PokerModel> cards) {
    if (cards.length < 6 || cards.length % 3 != 0)
      return false; // 飞机长度必须大于等于 6 且是 3 的倍数
    final counts = <CardValue, int>{};
    for (final card in cards) {
      counts[card.value] = (counts[card.value] ?? 0) + 1;
    }
    if (counts.values.any((count) => count != 3)) return false; // 必须都是三张
    final cardValues = counts.keys.toList();
    cardValues.sort(
      (a, b) => CardUtils.getCardWeightByValue(
        b,
      ).compareTo(CardUtils.getCardWeightByValue(a)),
    );
    for (int i = 0; i < cardValues.length - 1; i++) {
      if (CardUtils.getCardWeightByValue(cardValues[i]) -
              CardUtils.getCardWeightByValue(cardValues[i + 1]) !=
          1)
        return false; // 必须是连续的
    }
    return true;
  }

  // 判断是否是飞机带翅膀
  static bool _isPlaneWithWings(List<PokerModel> cards) {
    if (cards.length < 8) return false; // 飞机带翅膀长度必须大于等于 8
    final counts = <CardValue, int>{};
    for (final card in cards) {
      counts[card.value] = (counts[card.value] ?? 0) + 1;
    }
    final threeCount = counts.values.where((count) => count == 3).length;
    final oneCount = counts.values.where((count) => count == 1).length;
    final twoCount = counts.values.where((count) => count == 2).length;

    // 飞机带单张
    if (threeCount >= 2 && (oneCount == threeCount || twoCount == threeCount)) {
      // 提取飞机部分
      List<PokerModel> planeCards = [];
      counts.forEach((key, value) {
        if (value == 3) {
          planeCards.addAll(cards.where((card) => card.value == key));
        }
      });
      if (_isPlane(planeCards)) {
        return true;
      }
    }
    return false;
  }
}
