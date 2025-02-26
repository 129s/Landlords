import 'package:json_annotation/json_annotation.dart';
import 'package:landlords_3/data/models/player.dart';

part 'room.g.dart';

@JsonSerializable(explicitToJson: true)
class Room {
  final String id;
  @JsonKey(name: 'player_count')
  final int playerCount;
  @JsonKey(name: 'room_status')
  final String roomStatus;
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final DateTime createdAt;

  const Room({
    required this.id,
    required this.playerCount,
    required this.roomStatus,
    required this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  Map<String, dynamic> toJson() => _$RoomToJson(this);

  // 时间转换方法
  static DateTime _fromJson(int timestamp) =>
      DateTime.fromMillisecondsSinceEpoch(timestamp);
  static int _toJson(DateTime time) => time.millisecondsSinceEpoch;
}
