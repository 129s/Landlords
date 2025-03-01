import 'package:flutter/material.dart';
import 'package:landlords_3/core/network_services/constants/constants.dart';
import 'package:landlords_3/data/models/game_state.dart';
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
              ? PokerListWidget(
                cards: gameState.additionalCards,
                onCardTapped: (_) {},
                disableHoverEffect: true,
                isSelectable: false,
                alignment: PokerListAlignment.center,
              )
              : _buildBackSide(),
    );
  }

  Widget _buildBackSide() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(left: 0, child: _buildSingleBackCard()),
        Positioned(child: _buildSingleBackCard()),
        Positioned(right: 0, child: _buildSingleBackCard()),
      ],
    );
  }

  Widget _buildSingleBackCard() {
    return Container(
      width: 40,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage("assets/card_back_pattern.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
