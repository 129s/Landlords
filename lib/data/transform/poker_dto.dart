import 'package:landlords_3/data/models/poker.dart';

class PokerDTO {
  final String suit;
  final String value;

  const PokerDTO({required this.suit, required this.value});

  factory PokerDTO.fromJson(Map<String, dynamic> json) {
    return PokerDTO(
      suit: json['suit'] as String,
      value: json['value'] as String,
    );
  }

  Poker toModel() {
    return Poker(suit: _parseSuit(suit), value: _parseValue(value));
  }

  Map<String, dynamic> toJson() {
    return {'suit': suit, 'value': value};
  }

  Suit _parseSuit(String suit) {
    switch (suit.toLowerCase()) {
      case 'hearts':
        return Suit.hearts;
      case 'diamonds':
        return Suit.diamonds;
      case 'clubs':
        return Suit.clubs;
      case 'spades':
        return Suit.spades;
      case 'joker':
        return Suit.joker;
      default:
        throw ArgumentError('Invalid suit: $suit');
    }
  }

  CardValue _parseValue(String value) {
    switch (value.toLowerCase()) {
      case 'ace':
        return CardValue.ace;
      case 'two':
        return CardValue.two;
      case 'three':
        return CardValue.three;
      case 'four':
        return CardValue.four;
      case 'five':
        return CardValue.five;
      case 'six':
        return CardValue.six;
      case 'seven':
        return CardValue.seven;
      case 'eight':
        return CardValue.eight;
      case 'nine':
        return CardValue.nine;
      case 'ten':
        return CardValue.ten;
      case 'jack':
        return CardValue.jack;
      case 'queen':
        return CardValue.queen;
      case 'king':
        return CardValue.king;
      case 'jokersmall':
        return CardValue.jokerSmall;
      case 'jokerbig':
        return CardValue.jokerBig;
      default:
        throw ArgumentError('Invalid card value: $value');
    }
  }
}
