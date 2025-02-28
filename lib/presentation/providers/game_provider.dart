import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network_services/constants/constants.dart';
import 'package:landlords_3/core/network_services/game_service.dart';
import 'package:landlords_3/core/network_services/room_service.dart';
import 'package:landlords_3/data/providers/service_providers.dart';
import 'package:landlords_3/data/models/game_state.dart';
import 'package:landlords_3/data/models/poker.dart';
import 'package:landlords_3/core/card/card_type.dart';
import 'package:landlords_3/core/card/card_utils.dart';

class GameNotifier extends StateNotifier<GameState> {
  final GameService _gameService;
  final RoomService _roomService;
  StreamSubscription? _gameSubscription;

  GameNotifier(this._gameService, this._roomService)
    : super(const GameState()) {
    // 实时监听游戏更新
    _gameSubscription = _gameService.gameStateStream.listen((gameState) {
      if (gameState != null) state = gameState;
    });
  }

  // 初始化游戏（从服务端获取数据）
  Future<void> initializeGame() async {
    try {
      state = state.copyWith(gamePhase: GamePhase.preparing);
    } catch (e) {
      state = state.copyWith(gamePhase: GamePhase.error);
    }
  }

  // 提交出牌
  Future<void> playSelectedCards() async {
    final cards =
        state.selectedIndices.map((index) => state.playerCards[index]).toList();
    return _gameService.playCards(cards);
  }

  // 跳过
  Future<void> passTurn() async {
    return _gameService.passTurn();
  }

  // 退出房间
  Future<void> leaveGame() async {
    return _roomService.leaveRoom();
  }

  // 选择卡牌
  void toggleCardSelection(int index) {
    final newIndices = List<int>.from(state.selectedIndices);
    newIndices.contains(index)
        ? newIndices.remove(index)
        : newIndices.add(index);
    state = state.copyWith(selectedIndices: newIndices);
  }

  // 提示
  void showHint() {
    final playableCards = _findPlayableCards();
    if (playableCards.isNotEmpty) {
      final indices =
          playableCards.map((c) => state.playerCards.indexOf(c)).toList();
      state = state.copyWith(selectedIndices: indices);
    }
  }

  // 清空选择
  void clearSelectedCards() {
    state = state.copyWith(selectedIndices: []);
  }

  List<Poker> _findPlayableCards() {
    // 实现智能选牌算法（示例基础逻辑）
    final allCards = state.playerCards;
    final lastPlayed = state.lastPlayedCards;

    // 优先找单张
    for (final card in allCards) {
      if (CardUtils.isBigger([card], lastPlayed)) {
        return [card];
      }
    }

    // 其他牌型检测（需要扩展）
    return [];
  }

  void placeBid(int bidValue) {
    _gameService.placeBid(bidValue);
  }

  void toggleReady() {
    _gameService.toggleReady();
  }

  // 出牌验证逻辑
  bool _validateCards(List<Poker> cards) {
    if (cards.isEmpty) return false;

    final cardType = CardType.getType(cards);
    if (cardType == CardTypeEnum.invalid) return false;

    // 首出
    if (state.lastPlayedCards.isEmpty) {
      return true;
    }

    // 炸弹
    if (cardType == CardTypeEnum.bomb) {
      return state.lastPlayedCards.length != 4 ||
          CardUtils.isBigger(cards, state.lastPlayedCards);
    }

    return CardUtils.isBigger(cards, state.lastPlayedCards) &&
        cardType == CardType.getType(state.lastPlayedCards);
  }
}

final gameProvider = StateNotifierProvider.autoDispose<GameNotifier, GameState>(
  (ref) => GameNotifier(
    ref.read(gameServiceProvider),
    ref.read(roomServiceProvider),
  ),
);
