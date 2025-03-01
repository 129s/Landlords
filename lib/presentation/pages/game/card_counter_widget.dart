import 'package:flutter/material.dart';
import 'package:landlords_3/core/card/card_type.dart';
import 'package:landlords_3/core/network_services/constants/constants.dart';
import 'package:landlords_3/data/models/game_state.dart';
import 'package:landlords_3/data/models/poker.dart';

class CombinedCardsDisplay extends StatelessWidget {
  final GameState gameState;

  const CombinedCardsDisplay({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 底牌展示
          _buildAdditionalCards(context),
          const SizedBox(width: 20),
          // 记牌器
          _buildCardCounter(context),
        ],
      ),
    );
  }

  Widget _buildAdditionalCards(BuildContext context) {
    final isLandlordPhase = gameState.landlordIndex != -1;
    final showFront = isLandlordPhase;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children:
          [0, 1, 2].map((index) {
            return Container(
              width: 36,
              height: 42,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white24),
              ),
              child:
                  showFront && gameState.additionalCards.length > index
                      ? Center(
                        child: Text(
                          _getCardDisplay(gameState.additionalCards[index]),
                          style: TextStyle(
                            color: gameState.additionalCards[index].color,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      : const Center(child: Text("?")),
            );
          }).toList(),
    );
  }

  Widget _buildCardCounter(BuildContext context) {
    const cardOrder = [
      '王',
      '2',
      'A',
      'K',
      'Q',
      'J',
      '10',
      '9',
      '8',
      '7',
      '6',
      '5',
      '4',
      '3',
    ];
    final counts = _calculateCounts();

    return DefaultTextStyle(
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      child: Row(
        children:
            cardOrder.map((card) {
              return Container(
                width: 24,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(card),
                    Text(
                      counts[card].toString(),
                      style: TextStyle(
                        color: _getCountColor(counts[card]!),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  String _getCardDisplay(Poker card) {
    if ([CardValue.jokerSmall, CardValue.jokerBig].contains(card.value)) {
      return card.value == CardValue.jokerBig ? 'JOKER' : 'joker';
    }
    return card.displayValue;
  }

  Map<String, int> _calculateCounts() {
    const initialCounts = {
      '王': 2,
      '2': 4,
      'A': 4,
      'K': 4,
      'Q': 4,
      'J': 4,
      '10': 4,
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

  Color _getCountColor(int count) {
    if (count <= 0) return Colors.grey;
    if (count <= 2) return Colors.amber;
    return Colors.greenAccent;
  }
}
