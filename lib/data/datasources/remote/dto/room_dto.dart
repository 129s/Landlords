import 'package:landlords_3/data/datasources/remote/dto/player_dto.dart';
import 'package:landlords_3/domain/entities/room_model.dart';

class RoomDTO extends RoomModel {
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
