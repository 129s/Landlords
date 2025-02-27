import 'package:json_annotation/json_annotation.dart';
import 'package:landlords_3/data/models/player.dart';

part 'room.g.dart';

@JsonSerializable(explicitToJson: true)
class Room {
  final String id;
  final List<Player> players;
  final String roomStatus;

  const Room({
    required this.id,
    required this.players,
    required this.roomStatus,
  });

  int get playerCount => players.length;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  Map<String, dynamic> toJson() => _$RoomToJson(this);
}
