import 'package:json_annotation/json_annotation.dart';
import 'package:landlords_3/core/network_services/constants/constants.dart';
import 'package:landlords_3/data/models/player.dart';
import 'package:landlords_3/data/models/poker.dart';
import 'package:landlords_3/data/models/room.dart';

part 'game_state.g.dart';

@JsonSerializable(explicitToJson: true)
class GameState {
  @JsonKey(name: 'gamePhase', fromJson: _phaseFromJson, toJson: _phaseToJson)
  final GamePhase gamePhase;
  @JsonKey(name: 'players', defaultValue: [])
  final List<Player> players;
  @JsonKey(name: 'lastPlayedCards', defaultValue: [])
  final List<Poker> lastPlayedCards;
  @JsonKey(name: 'currentPlayerIndex', defaultValue: 0)
  final int currentPlayerIndex;
  @JsonKey(name: 'currentBid', defaultValue: 0)
  final int currentBid;
  @JsonKey(name: 'highestBid', defaultValue: 0)
  final int? highestBid;
  @JsonKey(name: 'playerCards', defaultValue: [])
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
