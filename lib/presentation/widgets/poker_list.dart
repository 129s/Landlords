import 'package:flutter/material.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';
import 'package:landlords_3/presentation/widgets/poker.dart';

enum PokerListAlignment { start, center, end }

class PokerList extends StatelessWidget {
  final List<PokerData> cards;
  final List<int> selectedIndices;
  final double minVisibleWidth;
  final PokerListAlignment alignment;
  final bool isTight;
  final double maxSpacingFactor;
  final Function(int) onCardTapped;

  const PokerList({
    Key? key,
    required this.cards,
    required this.onCardTapped,
    this.selectedIndices = const [],
    this.minVisibleWidth = 20.0,
    this.alignment = PokerListAlignment.center,
    this.isTight = false,
    this.maxSpacingFactor = 0.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerHeight = constraints.maxHeight;
        final cardHeight = containerHeight;
        final cardWidth = cardHeight / 1.4;

        double overlapFactor = 1 - minVisibleWidth / cardWidth;
        overlapFactor = overlapFactor.clamp(0, 1);

        double spacingFactor = isTight ? 0 : maxSpacingFactor;
        double spacing = cardWidth * spacingFactor;

        double totalWidth = cardWidth + (cards.length - 1) * spacing;

        if (totalWidth > constraints.maxWidth && cards.length > 1) {
          spacing = (constraints.maxWidth - cardWidth) / (cards.length - 1);
          spacingFactor = spacing / cardWidth;
          overlapFactor = 0;
          totalWidth = constraints.maxWidth;
        }

        double startPosition = 0;
        switch (alignment) {
          case PokerListAlignment.center:
            startPosition = (constraints.maxWidth - totalWidth) / 2;
            break;
          case PokerListAlignment.end:
            startPosition = constraints.maxWidth - totalWidth;
            break;
          case PokerListAlignment.start:
          default:
            startPosition = 0;
            break;
        }

        return SizedBox(
          height: cardHeight,
          child: Stack(
            children: [
              for (int i = 0; i < cards.length; i++)
                Positioned(
                  left: startPosition + i * spacing,
                  child: SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: Poker(
                      card: cards[i],
                      width: cardWidth,
                      height: cardHeight,
                      isSelected: selectedIndices.contains(i),
                      onTapped: () => onCardTapped(i),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
