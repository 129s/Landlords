import 'package:landlords_3/domain/entities/poker_model.dart';

class PlayerModel {
  final String id;
  final String name;
  final int seat;
  final List<PokerModel> cards;
  final bool isLandlord;

  PlayerModel({
    required this.id,
    required this.name,
    required this.seat,
    this.cards = const [],
    this.isLandlord = false,
  });

  PlayerModel copyWith({
    String? id,
    String? name,
    int? seat,
    List<PokerModel>? cards,
    bool? isLandlord,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      seat: seat ?? this.seat,
      cards: cards ?? this.cards,
      isLandlord: isLandlord ?? this.isLandlord,
    );
  }

  @override
  String toString() {
    return 'PlayerData{id: $id, name: $name, seat: $seat, cards: $cards, isLandlord: $isLandlord}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          seat == other.seat &&
          cards == other.cards &&
          isLandlord == other.isLandlord;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      seat.hashCode ^
      cards.hashCode ^
      isLandlord.hashCode;
}
