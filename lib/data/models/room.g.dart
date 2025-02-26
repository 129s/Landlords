// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
  id: json['id'] as String,
  playerCount: (json['player_count'] as num).toInt(),
  roomStatus: json['room_status'] as String,
  createdAt: Room._fromJson((json['createdAt'] as num).toInt()),
);

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
  'id': instance.id,
  'player_count': instance.playerCount,
  'room_status': instance.roomStatus,
  'createdAt': Room._toJson(instance.createdAt),
};
