import 'package:landlords_3/domain/entities/room_model.dart';
import 'package:landlords_3/domain/entities/player_model.dart';

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
              .map((playerJson) => PlayerDTO.fromJson(playerJson))
              .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class PlayerDTO extends PlayerModel {
  PlayerDTO({
    required super.id,
    required super.name,
    required super.seat,
    required super.cardCount,
    super.isLandlord = false,
  });

  factory PlayerDTO.fromJson(Map<String, dynamic> json) {
    return PlayerDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      seat: json['seat'] as int,
      cardCount: json['cardCount'] as int,
      isLandlord: json['isLandlord'] as bool? ?? false,
    );
  }
}
