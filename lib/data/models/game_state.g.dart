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
  players:
      (json['players'] as List<dynamic>?)
          ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
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
  currentPlayerIndex: (json['currentPlayerIndex'] as num?)?.toInt() ?? 0,
  currentBid: (json['currentBid'] as num?)?.toInt() ?? 0,
  highestBid: (json['highestBid'] as num?)?.toInt() ?? 0,
  selectedIndices:
      (json['selectedIndices'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  room:
      json['room'] == null
          ? null
          : Room.fromJson(json['room'] as Map<String, dynamic>),
  landlordIndex: (json['landlordIndex'] as num?)?.toInt() ?? -1,
);

Map<String, dynamic> _$GameStateToJson(GameState instance) => <String, dynamic>{
  'gamePhase': GameState._phaseToJson(instance.gamePhase),
  'players': instance.players.map((e) => e.toJson()).toList(),
  'lastPlayedCards': instance.lastPlayedCards.map((e) => e.toJson()).toList(),
  'playerCards': instance.playerCards.map((e) => e.toJson()).toList(),
  'additionalCards': instance.additionalCards.map((e) => e.toJson()).toList(),
  'currentPlayerIndex': instance.currentPlayerIndex,
  'currentBid': instance.currentBid,
  'highestBid': instance.highestBid,
  'selectedIndices': instance.selectedIndices,
  'room': instance.room?.toJson(),
  'landlordIndex': instance.landlordIndex,
};
