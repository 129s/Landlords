// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameState _$GameStateFromJson(Map<String, dynamic> json) => GameState(
  gamePhase:
      json['gamePhase'] == null
          ? GamePhase.preparing
          : GameState._phaseFromJson(json['gamePhase'] as String),
  playerCards:
      (json['playerCards'] as List<dynamic>?)
          ?.map((e) => Poker.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  lastPlayedCards:
      (json['lastPlayedCards'] as List<dynamic>?)
          ?.map((e) => Poker.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  additionalCards:
      (json['additionalCards'] as List<dynamic>?)
          ?.map((e) => Poker.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  myPlayerIndex: (json['myPlayerIndex'] as num?)?.toInt() ?? 0,
  currentPlayerIndex: (json['currentPlayerIndex'] as num?)?.toInt() ?? 0,
  players:
      (json['players'] as List<dynamic>?)
          ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  selectedIndices:
      (json['selectedIndices'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  landlordIndex: (json['landlordIndex'] as num?)?.toInt() ?? -1,
);

Map<String, dynamic> _$GameStateToJson(GameState instance) => <String, dynamic>{
  'gamePhase': GameState._phaseToJson(instance.gamePhase),
  'lastPlayedCards': instance.lastPlayedCards.map((e) => e.toJson()).toList(),
  'playerCards': instance.playerCards.map((e) => e.toJson()).toList(),
  'additionalCards': instance.additionalCards.map((e) => e.toJson()).toList(),
  'myPlayerIndex': instance.myPlayerIndex,
  'currentPlayerIndex': instance.currentPlayerIndex,
  'players': instance.players.map((e) => e.toJson()).toList(),
  'selectedIndices': instance.selectedIndices,
  'landlordIndex': instance.landlordIndex,
};
