import 'package:flutter/material.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';
import 'package:landlords_3/presentation/widgets/poker.dart';

enum PokerListAlignment { start, center, end }

class PokerList extends StatefulWidget {
  final List<PokerData> cards;
  final List<int> selectedIndices;
  final double minVisibleWidth;
  final PokerListAlignment alignment;
  final bool isTight;
  final double maxSpacingFactor;
  final Function(int) onCardTapped;
  final bool isSelectable;

  const PokerList({
    Key? key,
    required this.cards,
    required this.onCardTapped,
    this.selectedIndices = const [],
    this.minVisibleWidth = 20.0,
    this.alignment = PokerListAlignment.center,
    this.isTight = false,
    this.maxSpacingFactor = 0.5,
    this.isSelectable = true,
  }) : super(key: key);

  @override
  State<PokerList> createState() => _PokerListState();
}

class _PokerListState extends State<PokerList> {
  Offset? _startPosition;
  Offset? _currentPosition;
  List<int> _dragSelectedIndices = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart:
          widget.isSelectable
              ? (details) {
                _startPosition = details.localPosition;
                _currentPosition = details.localPosition;
                _dragSelectedIndices = [];
              }
              : null,
      onPanUpdate:
          widget.isSelectable
              ? (details) => _currentPosition = details.localPosition
              : null,
      onPanEnd:
          widget.isSelectable
              ? (details) {
                if (_startPosition != null && _currentPosition != null) {
                  _updateDragSelection(context);
                  for (int index in _dragSelectedIndices) {
                    widget.onCardTapped(index);
                  }
                }
                setState(() {
                  _startPosition = null;
                  _currentPosition = null;
                  _dragSelectedIndices = [];
                });
              }
              : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final containerHeight = constraints.maxHeight;
          final cardHeight = containerHeight;
          final cardWidth = cardHeight / 1.4;

          double overlapFactor = 1 - widget.minVisibleWidth / cardWidth;
          overlapFactor = overlapFactor.clamp(0, 1);

          double spacingFactor = widget.isTight ? 0 : widget.maxSpacingFactor;
          double spacing = cardWidth * spacingFactor;

          double totalWidth = cardWidth + (widget.cards.length - 1) * spacing;

          if (totalWidth > constraints.maxWidth && widget.cards.length > 1) {
            spacing =
                (constraints.maxWidth - cardWidth) / (widget.cards.length - 1);
            spacingFactor = spacing / cardWidth;
            overlapFactor = 0;
            totalWidth = constraints.maxWidth;
          }

          double startPosition = 0;
          switch (widget.alignment) {
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
                for (int i = 0; i < widget.cards.length; i++)
                  Positioned(
                    left: startPosition + i * spacing,
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: Poker(
                        card: widget.cards[i],
                        width: cardWidth,
                        height: cardHeight,
                        isSelected: widget.selectedIndices.contains(i),
                        onTapped:
                            widget.isSelectable
                                ? () => widget.onCardTapped(i)
                                : null,
                        isSelectable: widget.isSelectable,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateDragSelection(BuildContext context) {
    if (_startPosition == null || _currentPosition == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final cardHeight = size.height;
    final cardWidth = cardHeight / 1.4;

    double spacingFactor = widget.isTight ? 0 : widget.maxSpacingFactor;
    double spacing = cardWidth * spacingFactor;

    double totalWidth = cardWidth + (widget.cards.length - 1) * spacing;
    double startPosition = 0;
    switch (widget.alignment) {
      case PokerListAlignment.center:
        startPosition = (size.width - totalWidth) / 2;
        break;
      case PokerListAlignment.end:
        startPosition = size.width - totalWidth;
        break;
      case PokerListAlignment.start:
      default:
        startPosition = 0;
        break;
    }

    List<int> newSelectedIndices = [];
    for (int i = 0; i < widget.cards.length; i++) {
      double cardLeft = startPosition + i * spacing;
      double cardRight = cardLeft + cardWidth;

      // 检查卡牌是否与选择区域相交
      if (_isWithinSelectionArea(cardLeft, cardRight)) {
        newSelectedIndices.add(i);
      }
    }

    _dragSelectedIndices = newSelectedIndices;
  }

  bool _isWithinSelectionArea(double cardLeft, double cardRight) {
    if (_startPosition == null || _currentPosition == null) return false;

    double selectionLeft =
        _startPosition!.dx < _currentPosition!.dx
            ? _startPosition!.dx
            : _currentPosition!.dx;
    double selectionRight =
        _startPosition!.dx > _currentPosition!.dx
            ? _startPosition!.dx
            : _currentPosition!.dx;

    // 检查卡牌是否与选择区域相交
    return cardLeft <= selectionRight && cardRight >= selectionLeft;
  }
}
