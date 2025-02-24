// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
  id: json['id'] as String,
  name: json['name'] as String,
  seat: (json['seat'] as num).toInt(),
  cards:
      (json['cards'] as List<dynamic>?)
          ?.map((e) => Poker.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  isLandlord: json['isLandlord'] as bool? ?? false,
);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'seat': instance.seat,
  'cards': instance.cards.map((e) => e.toJson()).toList(),
  'isLandlord': instance.isLandlord,
};
