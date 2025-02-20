import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';

class Poker extends StatefulWidget {
  final bool isSelected;
  final PokerData card;
  final double width;
  final double height;
  final VoidCallback? onTapped; // 修改为可空
  final bool isSelectable; // 新增属性，控制是否可选择

  const Poker({
    Key? key,
    required this.card,
    required this.width,
    required this.height,
    this.onTapped,
    required this.isSelected,
    this.isSelectable = true, // 默认可选择
  }) : super(key: key);

  @override
  State<Poker> createState() => _PokerState();
}

class _PokerState extends State<Poker> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent event) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (PointerExitEvent event) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap:
            widget.isSelectable
                ? widget.onTapped
                : null, // 根据 isSelectable 决定是否响应点击
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          transform: Matrix4.translationValues(
            0,
            widget.isSelected ? -10 : 0, // 选中时向上悬停
            0,
          ),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color:
                _isHovered
                    ? Colors.amberAccent
                    : widget.isSelected
                    ? Colors.amber
                    : Colors.white, // 悬停时变暗
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
      ),
    );
  }

  // 构建 Header
  Widget _buildHeader() {
    if (widget.card.suit == Suit.joker) {
      // 大小王
      Color color =
          widget.card.value == CardValue.jokerBig ? Colors.red : Colors.grey;
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
            widget.card.displayValue,
            style: TextStyle(
              color: widget.card.color,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.card.suitSymbol,
            style: TextStyle(color: widget.card.color, fontSize: 24.0),
          ),
        ],
      );
    }
  }

  // 构建 Footer
  Widget _buildFooter() {
    if (widget.card.suit == Suit.joker) {
      // 大小王
      Color color =
          widget.card.value == CardValue.jokerBig ? Colors.red : Colors.grey;
      return Icon(Icons.star, color: color, size: 48.0);
    } else {
      // 其他牌
      return Text(
        widget.card.suitSymbol,
        style: TextStyle(color: widget.card.color, fontSize: 48.0),
      );
    }
  }
}
