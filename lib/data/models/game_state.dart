import 'package:landlords_3/data/models/player.dart';
import 'package:landlords_3/data/models/poker.dart';
import 'package:landlords_3/presentation/providers/game_provider.dart';

class GameState {
  final List<Player> players; // 服务端玩家数据
  final List<Poker> playerCards; // 当前玩家手牌
  final List<Poker> lastPlayedCards; // 全局最后出牌
  final GamePhase phase;
  final int currentPlayerSeat; // 当前行动玩家座位
  final List<int> selectedIndices;
  final String? roomId;
  final bool isLandlord; // 是否地主
  final String actionType;

  const GameState({
    required this.players,
    this.playerCards = const [],
    this.lastPlayedCards = const [],
    this.phase = GamePhase.connecting,
    this.currentPlayerSeat = 0,
    this.selectedIndices = const [],
    this.roomId,
    this.isLandlord = false,
    this.actionType = 'STATE_UPDATE',
  });
}
