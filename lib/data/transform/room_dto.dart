import 'package:landlords_3/data/transform/player_dto.dart';
import 'package:landlords_3/data/models/room.dart';

class RoomDTO extends Room {
  RoomDTO({
    required super.id,
    required super.players,
    required super.createdAt,
  });

  factory RoomDTO.fromJson(Map<String, dynamic> json) {
    return RoomDTO(
      id: json['id'] as String,
      players:
          (json['players'] as List)
              .map((playerJson) => PlayerDTO.fromJson(playerJson).toModel())
              .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
