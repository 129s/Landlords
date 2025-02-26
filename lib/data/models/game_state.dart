import 'package:json_annotation/json_annotation.dart';
import 'package:landlords_3/core/network_services/constants/constants.dart';
import 'package:landlords_3/data/models/player.dart';
import 'package:landlords_3/data/models/poker.dart';
import 'package:landlords_3/data/models/room.dart';

part 'game_state.g.dart';

@JsonSerializable(explicitToJson: true)
class GameState {
  @JsonKey(fromJson: _phaseFromJson, toJson: _phaseToJson)
  final GamePhase gamePhase;
  final List<Player> players;
  final List<Poker> lastPlayedCards;
  final int currentPlayerIndex;
  final int currentBid;
  final int? highestBid;
  final List<Poker> playerCards;
  final List<int> selectedIndices;
  final Room? room;
  final bool isLandlord;

  const GameState({
    this.gamePhase = GamePhase.preparing,
    this.players = const [],
    this.lastPlayedCards = const [],
    this.currentPlayerIndex = 0,
    this.currentBid = 0,
    this.highestBid = 0,
    this.playerCards = const [],
    this.selectedIndices = const [],
    this.room,
    this.isLandlord = false,
  });

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);
  Map<String, dynamic> toJson() => _$GameStateToJson(this);

  // 枚举转换方法
  static GamePhase _phaseFromJson(String json) => GamePhase.values.firstWhere(
    (e) => e.name == json,
    orElse: () => GamePhase.error,
  );

  static String _phaseToJson(GamePhase phase) => phase.name;

  GameState copyWith({
    GamePhase? phase,
    List<Player>? players,
    List<Poker>? lastPlayedCards,
    int? currentPlayerIndex,
    int? currentBid,
    int? highestBid,
    List<Poker>? playerCards,
    List<int>? selectedIndices,
    Room? room,
    bool? isLandlord,
  }) {
    return GameState(
      gamePhase: phase ?? this.gamePhase,
      players: players ?? this.players,
      lastPlayedCards: lastPlayedCards ?? this.lastPlayedCards,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      currentBid: currentBid ?? this.currentBid,
      highestBid: highestBid ?? this.highestBid,
      playerCards: playerCards ?? this.playerCards,
      selectedIndices: selectedIndices ?? this.selectedIndices,
      room: room ?? this.room,
      isLandlord: isLandlord ?? this.isLandlord,
    );
  }
}
