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
  final List<Poker> lastPlayedCards; // 最后一次出的牌（全局），因为每回合只显示一组牌
  final List<Poker> playerCards; // 我方玩家手牌
  final List<Poker> additionalCards; // 底牌
  final int myPlayerIndex; // 我方玩家索引(索引充当座位号)
  final int currentPlayerIndex; // 当前行动玩家索引
  final int currentBid;
  final int? highestBid;
  final List<int> selectedIndices;
  final Room? room;
  final int landlordIndex;
  bool get isLandlord => myPlayerIndex == landlordIndex;

  const GameState({
    this.gamePhase = GamePhase.preparing,

    this.playerCards = const [],
    this.lastPlayedCards = const [],
    this.additionalCards = const [], //底牌和playercards分开算，即playerCards中不含有底牌
    this.myPlayerIndex = 0,
    this.currentPlayerIndex = 0,
    this.currentBid = 0,
    this.highestBid = 0,
    this.selectedIndices = const [],
    this.room,
    this.landlordIndex = -1, // 初始值-1表示未设置
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
    GamePhase? gamePhase,
    List<Poker>? lastPlayedCards,
    List<Poker>? playerCards,
    List<Poker>? additionalCards,
    int? myPlayerIndex,
    int? currentPlayerIndex,
    int? currentBid,
    int? highestBid,
    List<int>? selectedIndices,
    Room? room,
    int? landlordIndex,
  }) {
    return GameState(
      gamePhase: gamePhase ?? this.gamePhase,
      lastPlayedCards: lastPlayedCards ?? this.lastPlayedCards,
      playerCards: playerCards ?? this.playerCards,
      additionalCards: additionalCards ?? this.additionalCards,
      myPlayerIndex: myPlayerIndex ?? this.myPlayerIndex,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      currentBid: currentBid ?? this.currentBid,
      highestBid: highestBid ?? this.highestBid,
      selectedIndices: selectedIndices ?? this.selectedIndices,
      room: room ?? this.room,
      landlordIndex: landlordIndex ?? this.landlordIndex,
    );
  }
}
