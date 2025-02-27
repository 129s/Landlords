// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
  id: json['id'] as String,
  name: json['name'] as String,
  seat: (json['seat'] as num).toInt(),
  ready: json['ready'] as bool? ?? false,
  cardCount: (json['cardCount'] as num?)?.toInt() ?? 0,
  isLandlord: json['isLandlord'] as bool? ?? false,
);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'seat': instance.seat,
  'cardCount': instance.cardCount,
  'ready': instance.ready,
  'isLandlord': instance.isLandlord,
};
