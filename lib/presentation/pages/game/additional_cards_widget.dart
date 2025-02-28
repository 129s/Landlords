// 新建文件：presentation/pages/game/additional_cards_widget.dart
import 'package:flutter/material.dart';
import 'package:landlords_3/data/models/poker.dart';
import 'package:landlords_3/presentation/widgets/poker_list_widget.dart';

class AdditionalCardsWidget extends StatelessWidget {
  final List<Poker> cards;
  final bool isRevealed;

  const AdditionalCardsWidget({
    super.key,
    required this.cards,
    this.isRevealed = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child:
          cards.isNotEmpty
              ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '底牌',
                      style: TextStyle(
                        color: Colors.amber.shade200,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    PokerListWidget(
                      cards: cards,
                      onCardTapped: (_) {},
                      isSelectable: false,
                      disableHoverEffect: true,
                      alignment: PokerListAlignment.center,
                      minVisibleWidth: 30,
                    ),
                  ],
                ),
              )
              : const SizedBox.shrink(),
    );
  }
}
