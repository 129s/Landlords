import 'package:flutter/material.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';
import 'package:landlords_3/presentation/widgets/poker_list.dart';

class CardDisplayArea extends StatelessWidget {
  final List<PokerData> displayedCards;

  const CardDisplayArea({Key? key, required this.displayedCards})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PokerList(
        cards: displayedCards,
        minVisibleWidth: 25.0,
        alignment: PokerListAlignment.center,
        onCardTapped: (_) {},
        isTight: false,
        isSelectable: false, // 设置为不可选择
      ),
    );
  }
}
