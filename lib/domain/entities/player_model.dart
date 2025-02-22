import 'package:landlords_3/domain/entities/user_model.dart';

class PlayerModel {
  final UserModel user; // 替换原有id和name
  final int seat;
  final int cardCount;
  final bool isLandlord;

  PlayerModel({
    required this.user,
    required this.seat,
    required this.cardCount,
    this.isLandlord = false,
  });

  PlayerModel copyWith({
    UserModel? user,
    int? seat,
    int? cardCount,
    bool? isLandlord,
  }) {
    return PlayerModel(
      user: user ?? this.user,
      seat: seat ?? this.seat,
      cardCount: cardCount ?? this.cardCount,
      isLandlord: isLandlord ?? this.isLandlord,
    );
  }

  @override
  String toString() {
    return 'PlayerModel{user: $user, seat: $seat, cardCount: $cardCount, isLandlord: $isLandlord}';
  }
}
