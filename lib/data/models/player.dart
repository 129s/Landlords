import 'package:landlords_3/data/models/poker.dart';

import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable(explicitToJson: true)
class Player {
  final String id;
  final String name;
  final int seat;
  @JsonKey(defaultValue: [])
  final List<Poker> cards;
  @JsonKey(defaultValue: false)
  final bool isLandlord;

  Player({
    required this.id,
    required this.name,
    required this.seat,
    this.cards = const [],
    this.isLandlord = false,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
