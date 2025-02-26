// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameState _$GameStateFromJson(Map<String, dynamic> json) => GameState(
  phase:
      json['phase'] == null
          ? GamePhase.preparing
          : GameState._phaseFromJson(json['phase'] as String),
  players:
      (json['players'] as List<dynamic>?)
          ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  lastPlayedCards:
      (json['lastPlayedCards'] as List<dynamic>?)
          ?.map((e) => Poker.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  currentPlayerSeat: (json['currentPlayerSeat'] as num?)?.toInt() ?? 0,
  currentBid: (json['currentBid'] as num?)?.toInt() ?? 0,
  playerCards:
      (json['history'] as List<dynamic>?)
          ?.map((e) => Poker.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  selectedIndices:
      (json['selectedIndices'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  room:
      json['room'] == null
          ? null
          : Room.fromJson(json['room'] as Map<String, dynamic>),
  isLandlord: json['isLandlord'] as bool? ?? false,
);

Map<String, dynamic> _$GameStateToJson(GameState instance) => <String, dynamic>{
  'phase': GameState._phaseToJson(instance.phase),
  'players': instance.players.map((e) => e.toJson()).toList(),
  'lastPlayedCards': instance.lastPlayedCards.map((e) => e.toJson()).toList(),
  'currentPlayerSeat': instance.currentPlayerSeat,
  'currentBid': instance.currentBid,
  'history': instance.playerCards.map((e) => e.toJson()).toList(),
  'selectedIndices': instance.selectedIndices,
  'room': instance.room?.toJson(),
  'isLandlord': instance.isLandlord,
};
