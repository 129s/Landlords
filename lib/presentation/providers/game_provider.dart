import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/services/constants.dart';
import 'package:landlords_3/core/services/game_service.dart';
import 'package:landlords_3/core/services/room_service.dart';
import 'package:landlords_3/data/providers/service_providers.dart';
import 'package:landlords_3/data/models/game_state.dart';
import 'package:landlords_3/data/models/poker.dart';
import 'package:landlords_3/core/card/card_type.dart';
import 'package:landlords_3/core/card/card_utils.dart';

class GameNotifier extends StateNotifier<GameState> {
  final GameService _gameService;
  final RoomService _roomService;
  StreamSubscription? _gameStateSub;

  GameNotifier(this._gameService, this._roomService)
    : super(const GameState(players: []));

  // 初始化游戏（从服务端获取数据）
  Future<void> initializeGame() async {
    try {
      final room = _roomService.currentRoom;
      state = state.copyWith(room: room);
      _setupSocketListeners();
    } catch (e) {
      state = state.copyWith(phase: GamePhase.error);
    }
  }

  // 修改game_provider.dart中的_setupSocketListeners
  void _setupSocketListeners() {
    _gameStateSub = _gameService.gameStateStream().listen((newState) {
      if (newState.phase == GamePhase.bidding &&
          newState.currentPlayerSeat == state.currentPlayerSeat) {
        //
      }
      state = newState.copyWith(
        selectedIndices: state.selectedIndices,
        playerCards: state.playerCards,
      );
    });
  }

  void clearSelectedCards() {
    state = state.copyWith(selectedIndices: []);
  }

  // 选择卡牌
  void toggleCardSelection(int index) {
    final newIndices = List<int>.from(state.selectedIndices);
    newIndices.contains(index)
        ? newIndices.remove(index)
        : newIndices.add(index);
    state = state.copyWith(selectedIndices: newIndices);
  }

  void placeBid(int bidValue) {
    if (state.currentPlayerSeat != state.currentPlayerSeat) return;

    _gameService.placeBid(bidValue);
  }

  // 提交出牌
  Future<void> playSelectedCards() async {
    if (state.selectedIndices.isEmpty) return;

    final cards =
        state.selectedIndices.map((index) => state.playerCards[index]).toList();

    if (_validateCards(cards)) {
      _gameService.playCards(cards);
      clearSelectedCards();
      // 更新本地手牌状态
      final newCards = List<Poker>.from(state.playerCards)
        ..removeWhere((c) => cards.contains(c));
      state = state.copyWith(playerCards: newCards);
    }
  }

  bool _validateCards(List<Poker> cards) {
    if (state.lastPlayedCards.isNotEmpty) {
      return CardUtils.isBigger(cards, state.lastPlayedCards) &&
          CardType.getType(cards) != CardTypeEnum.invalid;
    }
    return CardType.getType(cards) != CardTypeEnum.invalid;
  }

  // 退出房间
  Future<void> leaveGame() async {
    _roomService.leaveRoom();
    state = const GameState(players: []);
  }

  @override
  void dispose() {
    _gameStateSub?.cancel();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider.autoDispose<GameNotifier, GameState>(
  (ref) => GameNotifier(
    ref.read(gameServiceProvider),
    ref.read(roomServiceProvider),
  ),
);
