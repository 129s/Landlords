import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';
import 'package:landlords_3/presentation/providers/game_provider.dart';
import 'package:landlords_3/presentation/widgets/poker_list.dart';

class CardDisplayArea extends ConsumerWidget {
  final List<PokerData> displayedCards;

  const CardDisplayArea({Key? key, required this.displayedCards})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // 使 GestureDetector 占据整个区域
      onTap: () {
        // 点击时清空选择
        ref.read(gameProvider.notifier).clearSelectedCards();
      },
      child: Center(
        child: PokerList(
          cards: displayedCards,
          minVisibleWidth: 25.0,
          alignment: PokerListAlignment.center,
          onCardTapped: (_) {},
          isTight: false,
          isSelectable: false, // 设置为不可选择
          disableHoverEffect: true, // 禁用悬停效果
        ),
      ),
    );
  }
}
