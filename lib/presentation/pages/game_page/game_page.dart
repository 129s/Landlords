// lib/presentation/pages/game_page.dart
import 'package:flutter/material.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';
import 'package:landlords_3/presentation/pages/game_page/bottom_area.dart';
import 'package:landlords_3/presentation/pages/game_page/card_display_area.dart';
import 'package:landlords_3/presentation/pages/game_page/player_infro.dart';
import 'package:landlords_3/presentation/pages/game_page/table_area.dart';
import 'package:landlords_3/presentation/pages/game_page/top_bar.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // 示例卡牌列表
  List<PokerData> playerCards = [
    PokerData(suit: Suit.joker, value: CardValue.jokerSmall),
    PokerData(suit: Suit.joker, value: CardValue.jokerBig),
    PokerData(suit: Suit.hearts, value: CardValue.ace),
    PokerData(suit: Suit.hearts, value: CardValue.ace),
    PokerData(suit: Suit.hearts, value: CardValue.ace),
    PokerData(suit: Suit.diamonds, value: CardValue.king),
    PokerData(suit: Suit.clubs, value: CardValue.queen),
    PokerData(suit: Suit.spades, value: CardValue.jack),
    PokerData(suit: Suit.hearts, value: CardValue.ten),
    PokerData(suit: Suit.diamonds, value: CardValue.nine),
    PokerData(suit: Suit.clubs, value: CardValue.eight),
    PokerData(suit: Suit.spades, value: CardValue.jack),
    PokerData(suit: Suit.hearts, value: CardValue.ten),
    PokerData(suit: Suit.diamonds, value: CardValue.nine),
    PokerData(suit: Suit.clubs, value: CardValue.eight),
    PokerData(suit: Suit.spades, value: CardValue.jack),
    PokerData(suit: Suit.hearts, value: CardValue.ten),
    PokerData(suit: Suit.diamonds, value: CardValue.nine),
    PokerData(suit: Suit.clubs, value: CardValue.eight),
    PokerData(suit: Suit.spades, value: CardValue.jack),
    PokerData(suit: Suit.hearts, value: CardValue.ten),
  ];

  List<PokerData> displayedCards = []; // 用于存储展示的卡牌

  void _playCards(List<PokerData> cards) {
    setState(() {
      displayedCards = cards; // 将选中的卡牌添加到展示区域
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const TableArea(),
          Column(
            children: [
              // 1. 顶部：记牌器和功能按钮
              const TopBar(),

              Expanded(
                child: Stack(
                  children: [
                    // 左侧玩家信息
                    Positioned(
                      left: 20.0,
                      top: 20.0,
                      child: const PlayerInfo(isLeft: true),
                    ),
                    // 右侧玩家信息
                    Positioned(
                      right: 20.0,
                      top: 20.0,
                      child: const PlayerInfo(isLeft: false),
                    ),
                    // 卡牌展示区域
                    CardDisplayArea(displayedCards: displayedCards),
                  ],
                ),
              ),

              // 2. 底部：操作按钮和卡牌列表
              BottomArea(playerCards: playerCards, onCardsPlayed: _playCards),
            ],
          ),
        ],
      ),
    );
  }
}
