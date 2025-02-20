import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/presentation/providers/game_provider.dart';
import 'package:landlords_3/presentation/widgets/poker_list.dart';

class BottomArea extends ConsumerWidget {
  const BottomArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: Column(
        children: [
          _buildActionButtons(ref),
          Expanded(
            child: PokerList(
              cards: gameState.playerCards,
              minVisibleWidth: 25.0,
              selectedIndices: gameState.selectedIndices,
              onCardTapped:
                  (index) => ref
                      .read(gameProvider.notifier)
                      .toggleCardSelection(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(WidgetRef ref) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => ref.read(gameProvider.notifier).playSelectedCards(),
          child: const Text('出牌'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: 实现提示功能
          },
          child: const Text('提示'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: 实现跳过功能
          },
          child: const Text('跳过'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: 实现抢地主/叫分功能
          },
          child: const Text('抢地主/叫分'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: 实现表情包、语音功能
          },
          child: const Icon(Icons.chat_bubble),
        ),
      ],
    );
  }
}
