class PlayerModel {
  final String id;
  final String name;
  final int seat;
  final int cardCount;
  final bool isLandlord;

  PlayerModel({
    required this.id,
    required this.name,
    required this.seat,
    required this.cardCount,
    this.isLandlord = false,
  });

  PlayerModel copyWith({
    String? id,
    String? name,
    int? seat,
    int? cardCount,
    bool? isLandlord,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      seat: seat ?? this.seat,
      cardCount: cardCount ?? this.cardCount,
      isLandlord: isLandlord ?? this.isLandlord,
    );
  }

  @override
  String toString() {
    return 'PlayerData{id: $id, name: $name, seat: $seat, cardCount: $cardCount, isLandlord: $isLandlord}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          seat == other.seat &&
          cardCount == other.cardCount &&
          isLandlord == other.isLandlord;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      seat.hashCode ^
      cardCount.hashCode ^
      isLandlord.hashCode;
}
