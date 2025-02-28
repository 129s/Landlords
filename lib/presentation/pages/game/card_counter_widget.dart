import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/card/card_type.dart';
import 'package:landlords_3/core/card/card_utils.dart';
import 'package:landlords_3/data/models/game_state.dart';

class CardCounterWidget extends ConsumerWidget {
  final GameState gameState;

  const CardCounterWidget({super.key, required this.gameState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remainingCounts = _calculateRemainingCounts();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCardLabels(remainingCounts),
          const SizedBox(height: 4),
          _buildCountValues(remainingCounts),
        ],
      ),
    );
  }

  Map<CardValue, int> _calculateRemainingCounts() {
    const totalCounts = {
      CardValue.jokerBig: 1,
      CardValue.jokerSmall: 1,
      CardValue.two: 4,
      CardValue.ace: 4,
      CardValue.king: 4,
      CardValue.queen: 4,
      CardValue.jack: 4,
      CardValue.ten: 4,
      CardValue.nine: 4,
      CardValue.eight: 4,
      CardValue.seven: 4,
      CardValue.six: 4,
      CardValue.five: 4,
      CardValue.four: 4,
      CardValue.three: 4,
    };

    final counts = <CardValue, int>{};
    return totalCounts.map((key, total) {
      final remaining = total - (counts[key] ?? 0);
      return MapEntry(key, remaining > 0 ? remaining : 0);
    });
  }

  Widget _buildCardLabels(Map<CardValue, int> counts) {
    return _buildCardRow(
      orderedValues: counts.keys.toList(),
      builder:
          (value) => Text(
            _getDisplayLabel(value),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
    );
  }

  Widget _buildCountValues(Map<CardValue, int> counts) {
    return _buildCardRow(
      orderedValues: counts.keys.toList(),
      builder:
          (value) => Text(
            counts[value].toString(),
            style: TextStyle(
              color: counts[value]! > 0 ? Colors.amber : Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
    );
  }

  Widget _buildCardRow({
    required List<CardValue> orderedValues,
    required Widget Function(CardValue) builder,
  }) {
    const displayOrder = [
      CardValue.jokerBig,
      CardValue.jokerSmall,
      CardValue.two,
      CardValue.ace,
      CardValue.king,
      CardValue.queen,
      CardValue.jack,
      CardValue.ten,
      CardValue.nine,
      CardValue.eight,
      CardValue.seven,
      CardValue.six,
      CardValue.five,
      CardValue.four,
      CardValue.three,
    ];

    return SizedBox(
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            displayOrder
                .map(
                  (value) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: builder(value),
                  ),
                )
                .toList(),
      ),
    );
  }

  String _getDisplayLabel(CardValue value) {
    switch (value) {
      case CardValue.jokerBig:
        return '大王';
      case CardValue.jokerSmall:
        return '小王';
      case CardValue.ace:
        return 'A';
      case CardValue.two:
        return '2';
      case CardValue.king:
        return 'K';
      case CardValue.queen:
        return 'Q';
      case CardValue.jack:
        return 'J';
      default:
        return (CardUtils.getCardWeightByValue(value) - 2).toString();
    }
  }
}
