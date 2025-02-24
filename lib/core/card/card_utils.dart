import 'package:landlords_3/core/card/card_type.dart';
import 'package:landlords_3/domain/entities/poker_model.dart';

class CardUtils {
  // 获取卡牌的权重值，用于比较大小
  static int getCardWeight(PokerModel card) {
    switch (card.value) {
      case CardValue.jokerBig:
        return 16;
      case CardValue.jokerSmall:
        return 15;
      case CardValue.two:
        return 14;
      case CardValue.ace:
        return 13;
      case CardValue.king:
        return 12;
      case CardValue.queen:
        return 11;
      case CardValue.jack:
        return 10;
      case CardValue.ten:
        return 9;
      case CardValue.nine:
        return 8;
      case CardValue.eight:
        return 7;
      case CardValue.seven:
        return 6;
      case CardValue.six:
        return 5;
      case CardValue.five:
        return 4;
      case CardValue.four:
        return 3;
      case CardValue.three:
        return 2;
      default:
        return 0;
    }
  }

  // 按照权重值排序卡牌
  static List<PokerModel> sortCards(List<PokerModel> cards) {
    final sortedCards = List<PokerModel>.from(cards);
    sortedCards.sort((a, b) => getCardWeight(b).compareTo(getCardWeight(a)));
    return sortedCards;
  }

  // 判断两手牌的大小，hand1 是否大于 hand2
  static bool isBigger(List<PokerModel> hand1, List<PokerModel> hand2) {
    if (hand1.isEmpty) return false;
    if (hand2.isEmpty) return true;

    final type1 = CardType.getType(hand1);
    final type2 = CardType.getType(hand2);

    if (type1 == CardTypeEnum.invalid || type2 == CardTypeEnum.invalid) {
      return false; // 无效牌型无法比较
    }

    if (type1 != type2) {
      if (type1 == CardTypeEnum.bomb) return true;
      if (type2 == CardTypeEnum.bomb) return false;
      return false; // 牌型不同无法比较
    }

    // 牌型相同，比较大小
    switch (type1) {
      case CardTypeEnum.single:
      case CardTypeEnum.pair:
      case CardTypeEnum.three:
        return getCardWeight(hand1.first) > getCardWeight(hand2.first);
      case CardTypeEnum.straight:
      case CardTypeEnum.straightPair:
      case CardTypeEnum.plane:
        return getCardWeight(hand1.first) > getCardWeight(hand2.first);
      case CardTypeEnum.bomb:
        return getCardWeight(hand1.first) > getCardWeight(hand2.first);
      case CardTypeEnum.rocket:
        return true; // 火箭最大
      case CardTypeEnum.threeWithOne:
      case CardTypeEnum.threeWithTwo:
        // 找到三张牌的部分进行比较
        final threeCards1 = findThreeCards(hand1);
        final threeCards2 = findThreeCards(hand2);
        if (threeCards1.isNotEmpty && threeCards2.isNotEmpty) {
          return getCardWeight(threeCards1.first) >
              getCardWeight(threeCards2.first);
        }
        return false;
      case CardTypeEnum.planeWithWings:
        // 找到飞机的主体部分进行比较
        final planeCards1 = findPlaneCards(hand1);
        final planeCards2 = findPlaneCards(hand2);
        if (planeCards1.isNotEmpty && planeCards2.isNotEmpty) {
          return getCardWeight(planeCards1.first) >
              getCardWeight(planeCards2.first);
        }
        return false;
      case CardTypeEnum.fourWithTwo:
      case CardTypeEnum.fourWithTwoPair:
        // 找到四张牌的部分进行比较
        final fourCards1 = findFourCards(hand1);
        final fourCards2 = findFourCards(hand2);
        if (fourCards1.isNotEmpty && fourCards2.isNotEmpty) {
          return getCardWeight(fourCards1.first) >
              getCardWeight(fourCards2.first);
        }
        return false;
      default:
        return false;
    }
  }

  // 辅助函数：查找三张相同的牌
  static List<PokerModel> findThreeCards(List<PokerModel> cards) {
    if (cards.length < 3) return [];
    final counts = <CardValue, int>{};
    for (final card in cards) {
      counts[card.value] = (counts[card.value] ?? 0) + 1;
    }
    for (final entry in counts.entries) {
      if (entry.value == 3) {
        return cards.where((card) => card.value == entry.key).toList();
      }
    }
    return [];
  }

  // 辅助函数：查找飞机牌的主体部分
  static List<PokerModel> findPlaneCards(List<PokerModel> cards) {
    if (cards.length < 6) return [];
    final counts = <CardValue, int>{};
    for (final card in cards) {
      counts[card.value] = (counts[card.value] ?? 0) + 1;
    }
    final threeCardValues =
        counts.entries
            .where((entry) => entry.value == 3)
            .map((entry) => entry.key)
            .toList();
    if (threeCardValues.length < 2) return [];

    threeCardValues.sort(
      (a, b) => getCardWeightByValue(b).compareTo(getCardWeightByValue(a)),
    );

    // 检查是否连续
    for (int i = 0; i < threeCardValues.length - 1; i++) {
      if (getCardWeightByValue(threeCardValues[i]) -
              getCardWeightByValue(threeCardValues[i + 1]) !=
          1) {
        return [];
      }
    }

    // 返回飞机牌的主体部分
    List<PokerModel> planeCards = [];
    for (final value in threeCardValues) {
      planeCards.addAll(cards.where((card) => card.value == value));
    }
    return planeCards;
  }

  // 辅助函数：查找四张相同的牌
  static List<PokerModel> findFourCards(List<PokerModel> cards) {
    if (cards.length < 4) return [];
    final counts = <CardValue, int>{};
    for (final card in cards) {
      counts[card.value] = (counts[card.value] ?? 0) + 1;
    }
    for (final entry in counts.entries) {
      if (entry.value == 4) {
        return cards.where((card) => card.value == entry.key).toList();
      }
    }
    return [];
  }

  // 根据 CardValue 获取权重值
  static int getCardWeightByValue(CardValue value) {
    switch (value) {
      case CardValue.jokerBig:
        return 16;
      case CardValue.jokerSmall:
        return 15;
      case CardValue.two:
        return 14;
      case CardValue.ace:
        return 13;
      case CardValue.king:
        return 12;
      case CardValue.queen:
        return 11;
      case CardValue.jack:
        return 10;
      case CardValue.ten:
        return 9;
      case CardValue.nine:
        return 8;
      case CardValue.eight:
        return 7;
      case CardValue.seven:
        return 6;
      case CardValue.six:
        return 5;
      case CardValue.five:
        return 4;
      case CardValue.four:
        return 3;
      case CardValue.three:
        return 2;
      default:
        return 0;
    }
  }
}
