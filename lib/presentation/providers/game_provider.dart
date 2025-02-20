import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';
import 'dart:math';

enum GamePhase { dealing, bidding, playing, gameOver }

class GameState {
  final List<PokerData> playerCards;
  final List<PokerData> displayedCards;
  final GamePhase phase;
  final int? landlordSeat; // 地主座位号
  final List<int> selectedIndices;

  const GameState({
    required this.playerCards,
    required this.displayedCards,
    required this.phase,
    this.landlordSeat,
    this.selectedIndices = const [],
  });

  GameState copyWith({
    List<PokerData>? playerCards,
    List<PokerData>? displayedCards,
    GamePhase? phase,
    int? landlordSeat,
    List<int>? selectedIndices,
  }) {
    return GameState(
      playerCards: playerCards ?? this.playerCards,
      displayedCards: displayedCards ?? this.displayedCards,
      phase: phase ?? this.phase,
      landlordSeat: landlordSeat ?? this.landlordSeat,
      selectedIndices: selectedIndices ?? this.selectedIndices,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier()
    : super(
        GameState(
          playerCards: [],
          displayedCards: [],
          phase: GamePhase.dealing,
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

  // 出牌逻辑
  void playSelectedCards() {
    final playedCards = [
      for (var index in state.selectedIndices) state.playerCards[index],
    ];

    state = state.copyWith(
      displayedCards: playedCards,
      playerCards: [
        for (var i = 0; i < state.playerCards.length; i++)
          if (!state.selectedIndices.contains(i)) state.playerCards[i],
      ],
      selectedIndices: [],
    );
  }

  void initializeGame() {
    final deck = _createShuffledDeck();
    state = state.copyWith(
      playerCards: deck.sublist(0, 17),
      displayedCards: [],
      phase: GamePhase.dealing,
      landlordSeat: null,
      selectedIndices: [],
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
