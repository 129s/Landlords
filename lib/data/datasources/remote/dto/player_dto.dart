import 'package:landlords_3/data/datasources/remote/dto/poker_dto.dart';
import 'package:landlords_3/domain/entities/player_model.dart';
import 'package:landlords_3/domain/entities/poker_model.dart';

class PlayerDTO {
  final String id;
  final String name;
  final int seat;
  final List<Map<String, dynamic>> cards;
  final bool isLandlord;

  const PlayerDTO({
    required this.id,
    required this.name,
    required this.seat,
    required this.cards,
    required this.isLandlord,
  });

  factory PlayerDTO.fromJson(Map<String, dynamic> json) {
    return PlayerDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      seat: json['seat'] as int,
      cards: (json['cards'] as List<dynamic>).cast<Map<String, dynamic>>(),
      isLandlord: json['isLandlord'] as bool,
    );
  }

  PlayerModel toModel() {
    return PlayerModel(
      id: id,
      name: name,
      seat: seat,
      cards: cards.map((card) => PokerDTO.fromJson(card).toModel()).toList(),
      isLandlord: isLandlord,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'seat': seat,
      'cards': cards,
      'isLandlord': isLandlord,
    };
  }
}
