import 'package:flutter/material.dart';
import 'package:landlords_3/core/card/card_type.dart';
import 'package:landlords_3/data/models/game_state.dart';
import 'package:landlords_3/data/models/poker.dart';
import 'package:landlords_3/presentation/providers/game_provider.dart';
import 'package:logger/logger.dart';

class CardInfoPanel extends StatelessWidget {
  final GameState gameState;

  const CardInfoPanel({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final counts = _calculateCounts();
    return Container(
      constraints: BoxConstraints(maxWidth: 729),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 底牌部分
          _buildLandlordCards(),
          // 记牌器部分
          for (final entry in counts.entries)
            _buildCounterItem(label: entry.key, count: entry.value),
        ],
      ),
    );
  }

  Widget _buildLandlordCards() {
    final isLandlordPhase = gameState.landlordIndex != -1;
    const cardSize = 32.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          [0, 1, 2].map((index) {
            return Container(
              width: cardSize,
              height: cardSize * 1.4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(color: Colors.black, offset: const Offset(0, 1)),
                ],
              ),
              child:
                  isLandlordPhase && gameState.additionalCards.length > index
                      ? Center(
                        child: Text(
                          gameState.additionalCards[index].displayValue,
                          style: TextStyle(
                            color: _getCardColor(
                              gameState.additionalCards[index],
                            ),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      : const Center(
                        child: Icon(
                          Icons.question_mark,
                          size: 14,
                          color: Color(0xFFC5CAD6),
                        ),
                      ),
            );
          }).toList(),
    );
  }

  Widget _buildCounterItem({required String label, required int count}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 255, 159, 220),
          ),
        ),
        Center(
          child: Text(
            '$count',
            style: TextStyle(fontSize: 16, color: _getCountColor(count)),
          ),
        ),
      ],
    );
  }

  // 颜色方案
  Color _getCardColor(Poker card) {
    return card.color.withOpacity(0.9);
  }

  Color _getCountColor(int count) {
    if (count <= 0) return const Color.fromARGB(255, 255, 77, 65);
    if (count <= 2) return const Color.fromARGB(255, 255, 165, 47);
    return const Color.fromARGB(255, 125, 255, 168);
  }

  Map<String, int> _calculateCounts() {
    // 保持原有计算逻辑
    const initialCounts = {
      '★': 2,
      '2': 4,
      'A': 4,
      'K': 4,
      'Q': 4,
      'J': 4,
      'X': 4,
      '9': 4,
      '8': 4,
      '7': 4,
      '6': 4,
      '5': 4,
      '4': 4,
      '3': 4,
    };

    final playedCounts = gameState.lastPlayedCards.fold<Map<String, int>>({}, (
      map,
      card,
    ) {
      final key =
          card.value == CardValue.jokerBig || card.value == CardValue.jokerSmall
              ? '王'
              : card.displayValue;
      map[key] = (map[key] ?? 0) + 1;
      return map;
    });

    return initialCounts.map(
      (key, value) => MapEntry(key, value - (playedCounts[key] ?? 0)),
    );
  }
}
