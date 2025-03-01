import 'package:flutter/material.dart';
import 'package:landlords_3/core/network_services/constants/constants.dart';
import 'package:landlords_3/data/models/game_state.dart';
import 'package:landlords_3/data/models/poker.dart';
import 'package:landlords_3/presentation/widgets/poker_list_widget.dart';

class AdditionalCardsWidget extends StatelessWidget {
  final GameState gameState;

  const AdditionalCardsWidget(this.gameState, {super.key});

  @override
  Widget build(BuildContext context) {
    final isLandlordPhase = gameState.landlordIndex != -1;
    final showFront = isLandlordPhase;

    return _buildCardsVisual(showFront);
  }

  Widget _buildCardsVisual(bool showFront) {
    return SizedBox(
      width: 96,
      height: 64,
      child:
          showFront
              ? _buildFrontSide(gameState.additionalCards)
              : _buildBackSide(),
    );
  }

  Widget _buildFrontSide(List<Poker> cards) {
    return Row(
      children:
          [0, 1, 2]
              .map(
                (n) => _buildSingleCard(
                  cards[n].suitSymbol + cards[n].displayValue,
                  color: cards[n].color,
                ),
              )
              .toList(),
    );
  }

  Widget _buildBackSide() {
    return Row(children: [0, 1, 2].map((n) => _buildSingleCard("?")).toList());
  }

  Widget _buildSingleCard(String text, {Color color = Colors.amberAccent}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(child: Text(text, style: TextStyle(color: color))),
      ),
    );
  }
}
