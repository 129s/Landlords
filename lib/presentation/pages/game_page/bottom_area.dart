import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/presentation/providers/game_provider.dart';
import 'package:landlords_3/presentation/widgets/poker_list_widget.dart';

class BottomArea extends ConsumerWidget {
  const BottomArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(child: _buildActionButtons(ref)),
          ),
          Expanded(
            child: PokerListWidget(
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          onPressed: () => ref.read(gameProvider.notifier).playSelectedCards(),
          text: '出牌',
        ),
        const SizedBox(width: 24), // 增加间距
        _buildActionButton(
          onPressed: () {
            // TODO: 实现提示功能
          },
          text: '提示',
        ),
        const SizedBox(width: 24), // 增加间距
        _buildActionButton(
          onPressed: () {
            // TODO: 实现跳过功能
          },
          text: '跳过',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String text,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ), // 增加内边距
        textStyle: const TextStyle(fontSize: 18), // 增大字体
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // 圆角
        ),
      ),
      child: Text(text),
    );
  }
}
