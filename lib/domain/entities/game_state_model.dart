import 'package:landlords_3/domain/entities/player_model.dart';
import 'package:landlords_3/domain/entities/poker_model.dart';
import 'package:landlords_3/presentation/providers/game_provider.dart';

class GameState {
  final List<PlayerModel> players; // 服务端玩家数据
  final List<PokerModel> playerCards; // 当前玩家手牌
  final List<PokerModel> lastPlayedCards; // 全局最后出牌
  final GamePhase phase;
  final int currentPlayerSeat; // 当前行动玩家座位
  final List<int> selectedIndices;
  final String? roomId;
  final bool isLandlord; // 是否地主

  const GameState({
    required this.players,
    this.playerCards = const [],
    this.lastPlayedCards = const [],
    this.phase = GamePhase.connecting,
    this.currentPlayerSeat = 0,
    this.selectedIndices = const [],
    this.roomId,
    this.isLandlord = false,
  });

  GameState copyWith({
    List<PlayerModel>? players,
    List<PokerModel>? playerCards,
    List<PokerModel>? lastPlayedCards,
    GamePhase? phase,
    int? currentPlayerSeat,
    List<int>? selectedIndices,
    String? roomId,
    bool? isLandlord,
  }) {
    return GameState(
      players: players ?? this.players,
      playerCards: playerCards ?? this.playerCards,
      lastPlayedCards: lastPlayedCards ?? this.lastPlayedCards,
      phase: phase ?? this.phase,
      currentPlayerSeat: currentPlayerSeat ?? this.currentPlayerSeat,
      selectedIndices: selectedIndices ?? this.selectedIndices,
      roomId: roomId ?? this.roomId,
      isLandlord: isLandlord ?? this.isLandlord,
    );
  }
}
