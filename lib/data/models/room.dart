import 'package:json_annotation/json_annotation.dart';
import 'package:landlords_3/data/models/player.dart';

part 'room.g.dart';

@JsonSerializable(explicitToJson: true)
class Room {
  final String id;
  @JsonKey(defaultValue: [])
  final List<Player> players;
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final DateTime createdAt;

  const Room({
    required this.id,
    required this.players,
    required this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  Map<String, dynamic> toJson() => _$RoomToJson(this);

  static DateTime _fromJson(int timestamp) =>
      DateTime.fromMillisecondsSinceEpoch(timestamp);
  static int _toJson(DateTime time) => time.millisecondsSinceEpoch;
}
