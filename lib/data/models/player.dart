import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable(explicitToJson: true)
class Player {
  final String id;
  final String name;
  final int seat;
  @JsonKey(defaultValue: false)
  final bool ready;
  @JsonKey(defaultValue: 0)
  final int cardCount;
  @JsonKey(defaultValue: false)
  final bool isLandlord;
  @JsonKey(defaultValue: -1)
  final int bidValue; // 玩家叫分

  Player({
    required this.id,
    required this.name,
    required this.seat,
    required this.ready,
    this.cardCount = 0,
    this.isLandlord = false,
    this.bidValue = -1,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
