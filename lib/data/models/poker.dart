import 'package:flutter/material.dart';

enum Suit { hearts, diamonds, clubs, spades, joker }

enum CardValue {
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
  jokerSmall, // 小王
  jokerBig, // 大王
}

class Poker {
  final Suit suit;
  final CardValue value;

  Poker({required this.suit, required this.value});

  // 用于显示的文字
  String get displayValue {
    switch (value) {
      case CardValue.ace:
        return 'A';
      case CardValue.two:
        return '2';
      case CardValue.three:
        return '3';
      case CardValue.four:
        return '4';
      case CardValue.five:
        return '5';
      case CardValue.six:
        return '6';
      case CardValue.seven:
        return '7';
      case CardValue.eight:
        return '8';
      case CardValue.nine:
        return '9';
      case CardValue.ten:
        return 'X';
      case CardValue.jack:
        return 'J';
      case CardValue.queen:
        return 'Q';
      case CardValue.king:
        return 'K';
      case CardValue.jokerSmall:
        return 'joker';
      case CardValue.jokerBig:
        return 'Joker';
      default:
        return '';
    }
  }

  // 获取颜色
  Color get color {
    if (suit == Suit.hearts || suit == Suit.diamonds) {
      return Colors.red;
    } else if (suit == Suit.joker) {
      return Colors.red; // 可以根据大小王设置不同的颜色
    } else {
      return Colors.black;
    }
  }

  // 获取花色符号
  String get suitSymbol {
    switch (suit) {
      case Suit.hearts:
        return '♥';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
      case Suit.spades:
        return '♠';
      default:
        return ''; // 大小王没有花色符号
    }
  }
}
