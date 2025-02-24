import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network/game_service.dart';
import 'package:landlords_3/core/network/room_service.dart';
import 'package:landlords_3/data/providers/service_providers.dart';
import 'package:landlords_3/data/models/game_state.dart';
import 'package:landlords_3/data/models/poker.dart';
import 'package:landlords_3/core/card/card_type.dart';
import 'package:landlords_3/core/card/card_utils.dart';

enum GamePhase { connecting, dealing, bidding, playing, gameOver }

class GameNotifier extends StateNotifier<GameState> {
  final GameService _gameService;
  final RoomService _roomService;

  GameNotifier(this._gameService, this._roomService)
    : super(const GameState(players: []));

  // 初始化游戏（从服务端获取数据）
  Future<void> initializeGame(String roomId) async {
    try {
      final room = await _roomService.getRoomDetails(roomId);
      // TODO: 更新状态
      _setupSocketListeners();
    } catch (e) {
      // TODO: 更新状态
    }
  }

  void _setupSocketListeners() {
    // TODO: 监听游戏状态更新
  }

  void clearSelectedCards() {
    // TODO: 更新状态
  }

  // 选择卡牌
  void toggleCardSelection(int index) {
    final newIndices = List<int>.from(state.selectedIndices);
    newIndices.contains(index)
        ? newIndices.remove(index)
        : newIndices.add(index);
    // TODO: 更新状态
  }

  // 提交出牌
  Future<void> playSelectedCards() async {
    if (state.selectedIndices.isEmpty) return;

    final cards =
        state.selectedIndices.map((index) => state.playerCards[index]).toList();

    if (_validateCards(cards)) {
      await _gameService.playCards(cards);
      // TODO: 更新状态
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
    await _roomService.leaveRoom();
    state = const GameState(players: []);
  }
}

final gameProvider = StateNotifierProvider.autoDispose<GameNotifier, GameState>(
  (ref) {
    return GameNotifier(
      ref.read(gameServiceProvider),
      ref.read(roomServiceProvider),
    );
  },
);
