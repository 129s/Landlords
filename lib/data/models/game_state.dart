import 'package:json_annotation/json_annotation.dart';
import 'package:landlords_3/core/services/constants.dart';
import 'package:landlords_3/data/models/player.dart';
import 'package:landlords_3/data/models/poker.dart';
import 'package:landlords_3/data/models/room.dart';

part 'game_state.g.dart';

@JsonSerializable(explicitToJson: true)
class GameState {
  @JsonKey(name: 'phase', fromJson: _phaseFromJson, toJson: _phaseToJson)
  final GamePhase phase;
  @JsonKey(name: 'players', defaultValue: [])
  final List<Player> players;
  @JsonKey(name: 'lastPlayedCards', defaultValue: [])
  final List<Poker> lastPlayedCards;
  @JsonKey(name: 'currentPlayerSeat', defaultValue: 0)
  final int currentPlayerSeat;
  @JsonKey(name: 'currentBid', defaultValue: 0)
  final int currentBid;
  @JsonKey(name: 'history', defaultValue: [])
  final List<Poker> playerCards;
  final List<int> selectedIndices;
  final Room? room;
  final bool isLandlord;

  const GameState({
    this.phase = GamePhase.preparing,
    this.players = const [],
    this.lastPlayedCards = const [],
    this.currentPlayerSeat = 0,
    this.currentBid = 0,
    this.playerCards = const [],
    this.selectedIndices = const [],
    this.room,
    this.isLandlord = false,
  });

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);
  Map<String, dynamic> toJson() => _$GameStateToJson(this);

  // 枚举转换方法
  static GamePhase _phaseFromJson(String phase) {
    switch (phase.toUpperCase()) {
      case 'BIDDING':
        return GamePhase.bidding;
      case 'PLAYING':
        return GamePhase.playing;
      case 'ENDED':
        return GamePhase.end;
      default:
        return GamePhase.preparing;
    }
  }

  static String _phaseToJson(GamePhase phase) => phase.name.toUpperCase();

  // 复制方法需要同步更新新增字段
  GameState copyWith({
    GamePhase? phase,
    List<Player>? players,
    List<Poker>? lastPlayedCards,
    int? currentPlayerSeat,
    int? currentBid,
    List<Poker>? playerCards,
    List<int>? selectedIndices,
    Room? room,
    bool? isLandlord,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      players: players ?? this.players,
      lastPlayedCards: lastPlayedCards ?? this.lastPlayedCards,
      currentPlayerSeat: currentPlayerSeat ?? this.currentPlayerSeat,
      currentBid: currentBid ?? this.currentBid,
      playerCards: playerCards ?? this.playerCards,
      selectedIndices: selectedIndices ?? this.selectedIndices,
      room: room ?? this.room,
      isLandlord: isLandlord ?? this.isLandlord,
    );
  }
}
