import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network/game_service.dart';
import 'package:landlords_3/core/network/room_service.dart';
import 'package:landlords_3/data/providers/service_providers.dart';
import 'package:landlords_3/data/models/game_state_model.dart';
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
      state = state.copyWith(
        roomId: roomId,
        players: room.players,
        phase: GamePhase.dealing,
      );
      _setupSocketListeners();
    } catch (e) {
      state = state.copyWith(phase: GamePhase.gameOver);
    }
  }

  void _setupSocketListeners() {
    // TODO: 监听游戏状态更新
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

  // 提交出牌
  Future<void> playSelectedCards() async {
    if (state.selectedIndices.isEmpty) return;

    final cards =
        state.selectedIndices.map((index) => state.playerCards[index]).toList();

    if (_validateCards(cards)) {
      await _gameService.playCards(cards);
      state = state.copyWith(
        playerCards:
            state.playerCards.where((card) => !cards.contains(card)).toList(),
        selectedIndices: [],
      );
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
