import 'package:landlords_3/data/models/poker.dart';

class Player {
  final String id;
  final String name;
  final int seat;
  final List<Poker> cards;
  final bool isLandlord;

  Player({
    required this.id,
    required this.name,
    required this.seat,
    this.cards = const [],
    this.isLandlord = false,
  });

  Player copyWith({
    String? id,
    String? name,
    int? seat,
    List<Poker>? cards,
    bool? isLandlord,
  }) {
    return Player(
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
      other is Player &&
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
