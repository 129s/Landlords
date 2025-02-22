import 'package:landlords_3/data/datasources/remote/dto/user_dto.dart';
import 'package:landlords_3/domain/entities/player_model.dart';

class PlayerDTO extends PlayerModel {
  PlayerDTO({
    required super.user, // Use UserModel
    required super.seat,
    required super.cardCount,
    super.isLandlord = false,
  });

  factory PlayerDTO.fromJson(Map<String, dynamic> json) {
    return PlayerDTO(
      user: UserDTO.fromJson(json['user']), // Convert user json to UserModel
      seat: json['seat'] as int,
      cardCount: json['cardCount'] as int,
      isLandlord: json['isLandlord'] as bool? ?? false,
    );
  }
}
