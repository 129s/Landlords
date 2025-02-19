import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';

class Poker extends StatefulWidget {
  final PokerData card;
  final double width;
  final double height;
  final VoidCallback onTapped;

  const Poker({
    Key? key,
    required this.card,
    required this.width,
    required this.height,
    required this.onTapped,
  }) : super(key: key);

  @override
  State<Poker> createState() => _PokerState();
}

class _PokerState extends State<Poker> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTapped();
        isSelected = isSelected ? false : true;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Header
            Positioned(top: 4.0, left: 4.0, child: _buildHeader()),

            // Footer
            Positioned(bottom: 16.0, right: 4.0, child: _buildFooter()),
          ],
        ),
      ),
    );
  }

  // 构建 Header
  Widget _buildHeader() {
    var card = widget.card;
    if (card.suit == Suit.joker) {
      // 大小王
      Color color = card.value == CardValue.jokerBig ? Colors.red : Colors.grey;
      String text = 'JOKER';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            text
                .split('')
                .map(
                  (char) => Text(
                    char,
                    style: TextStyle(
                      color: color,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                .toList(),
      );
    } else {
      // 其他牌
      return Column(
        children: [
          Text(
            card.displayValue,
            style: TextStyle(
              color: card.color,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            card.suitSymbol,
            style: TextStyle(color: card.color, fontSize: 24.0),
          ),
        ],
      );
    }
  }

  // 构建 Footer
  Widget _buildFooter() {
    var card = widget.card;
    if (card.suit == Suit.joker) {
      // 大小王
      Color color = card.value == CardValue.jokerBig ? Colors.red : Colors.grey;
      return Icon(Icons.star, color: color, size: 48.0);
    } else {
      // 其他牌
      return Text(
        card.suitSymbol,
        style: TextStyle(color: card.color, fontSize: 48.0),
      );
    }
  }
}
