import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';
import 'dart:math';
import 'package:landlords_3/core/utils/card_type.dart';
import 'package:landlords_3/core/utils/card_utils.dart';

enum GamePhase { dealing, bidding, playing, gameOver }

class GameState {
  final List<PokerData> playerCards;
  final List<PokerData> displayedCards; // 当前玩家
  final List<PokerData> displayedCardsOther1; // 其他玩家1
  final List<PokerData> displayedCardsOther2; // 其他玩家2
  final GamePhase phase;
  final int? landlordSeat; // 地主座位号
  final List<int> selectedIndices;
  final List<PokerData> lastPlayedCards; // 上一手出的牌

  const GameState({
    required this.playerCards,
    required this.displayedCards,
    required this.displayedCardsOther1,
    required this.displayedCardsOther2,
    required this.phase,
    this.landlordSeat,
    this.selectedIndices = const [],
    this.lastPlayedCards = const [],
  });

  GameState copyWith({
    List<PokerData>? playerCards,
    List<PokerData>? displayedCards,
    List<PokerData>? displayedCardsOther1,
    List<PokerData>? displayedCardsOther2,
    GamePhase? phase,
    int? landlordSeat,
    List<int>? selectedIndices,
    List<PokerData>? lastPlayedCards,
  }) {
    return GameState(
      playerCards: playerCards ?? this.playerCards,
      displayedCards: displayedCards ?? this.displayedCards,
      displayedCardsOther1: displayedCardsOther1 ?? this.displayedCardsOther1,
      displayedCardsOther2: displayedCardsOther2 ?? this.displayedCardsOther2,
      phase: phase ?? this.phase,
      landlordSeat: landlordSeat ?? this.landlordSeat,
      selectedIndices: selectedIndices ?? this.selectedIndices,
      lastPlayedCards: lastPlayedCards ?? this.lastPlayedCards,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier()
    : super(
        GameState(
          playerCards: [],
          displayedCards: [],
          displayedCardsOther1: [],
          displayedCardsOther2: [],
          phase: GamePhase.dealing,
          lastPlayedCards: [],
        ),
      );

  // 发牌逻辑
  void dealCards() {
    final deck = _createShuffledDeck();
    state = state.copyWith(
      playerCards: deck.sublist(0, 17),
      phase: GamePhase.bidding,
    );
  }

  // 卡牌选择逻辑
  void toggleCardSelection(int index) {
    final newIndices = List<int>.from(state.selectedIndices);
    newIndices.contains(index)
        ? newIndices.remove(index)
        : newIndices.add(index);
    state = state.copyWith(selectedIndices: newIndices);
  }

  // 出牌逻辑 (需要修改)
  void playSelectedCards() {
    final selectedCards =
        state.selectedIndices.map((index) => state.playerCards[index]).toList();

    // 验证牌型
    final cardType = CardType.getType(selectedCards);
    if (cardType == CardTypeEnum.invalid) {
      print('Invalid card type!');
      return; // 牌型不合法，不执行出牌
    }

    // 验证大小
    if (state.lastPlayedCards.isNotEmpty &&
        !CardUtils.isBigger(selectedCards, state.lastPlayedCards)) {
      print('Cards are not bigger than last played cards!');
      return; // 牌太小，不执行出牌
    }

    // 假设当前玩家出牌，更新当前玩家的 displayedCards
    state = state.copyWith(
      displayedCards: selectedCards,
      playerCards:
          state.playerCards
              .where((card) => !selectedCards.contains(card))
              .toList(),
      selectedIndices: [],
      lastPlayedCards: selectedCards, // 更新上一手牌
    );

    // TODO:  需要根据游戏逻辑，判断是哪个玩家出牌，并更新对应的 displayedCardsOther1 或 displayedCardsOther2
  }

  void initializeGame() {
    final deck = _createShuffledDeck();
    state = state.copyWith(
      playerCards: deck.sublist(0, 17),
      displayedCards: [],
      displayedCardsOther1: [],
      displayedCardsOther2: [],
      phase: GamePhase.dealing,
      landlordSeat: null,
      selectedIndices: [],
      lastPlayedCards: [], // 初始化上一手牌
    );
  }

  // 清空选择
  void clearSelectedCards() {
    state = state.copyWith(selectedIndices: []);
  }

  List<PokerData> _createShuffledDeck() {
    final List<PokerData> deck = [];

    // 添加普通牌
    for (var suit in Suit.values) {
      if (suit != Suit.joker) {
        for (var value in CardValue.values) {
          if (value != CardValue.jokerBig && value != CardValue.jokerSmall) {
            deck.add(PokerData(suit: suit, value: value));
          }
        }
      }
    }

    // 添加大小王
    deck.add(PokerData(suit: Suit.joker, value: CardValue.jokerSmall));
    deck.add(PokerData(suit: Suit.joker, value: CardValue.jokerBig));

    // 洗牌
    deck.shuffle(Random());

    return deck;
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});
