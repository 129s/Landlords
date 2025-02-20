import 'package:landlords_3/domain/entities/poker_data.dart';

class PokerModel extends PokerData {
  PokerModel({required Suit suit, required CardValue value})
    : super(suit: suit, value: value);

  // 添加领域实体转换方法
  factory PokerModel.fromEntity(PokerData entity) {
    return PokerModel(suit: entity.suit, value: entity.value);
  }
  // 转换为领域实体
  PokerData toEntity() {
    return PokerData(suit: suit, value: value);
  }

  factory PokerModel.fromJson(Map<String, dynamic> json) {
    return PokerModel(
      suit: Suit.values[json['suit']],
      value: CardValue.values[json['value']],
    );
  }

  Map<String, dynamic> toJson() {
    return {'suit': suit.index, 'value': value.index};
  }
}
