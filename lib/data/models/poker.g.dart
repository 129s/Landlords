// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Poker _$PokerFromJson(Map<String, dynamic> json) => Poker(
  suit: Poker._suitFromJson(json['suit'] as String),
  value: Poker._valueFromJson(json['value'] as String),
);

Map<String, dynamic> _$PokerToJson(Poker instance) => <String, dynamic>{
  'suit': Poker._suitToJson(instance.suit),
  'value': Poker._valueToJson(instance.value),
};
