import 'package:flutter/material.dart';
import 'package:landlords_3/data/models/poker.dart';
import 'package:landlords_3/presentation/widgets/poker_widget.dart';

enum PokerListAlignment { start, center, end }

class PokerListWidget extends StatefulWidget {
  final List<Poker> cards;
  final bool isLoading;
  final List<int> selectedIndices;
  final double minVisibleWidth;
  final PokerListAlignment alignment;
  final bool isTight;
  final double maxSpacingFactor;
  final Function(int) onCardTapped;
  final bool isSelectable;
  final bool disableHoverEffect; // 新增属性

  const PokerListWidget({
    super.key,
    required this.cards,
    this.isLoading = false,
    required this.onCardTapped,
    this.selectedIndices = const [],
    this.minVisibleWidth = 20.0,
    this.alignment = PokerListAlignment.center,
    this.isTight = false,
    this.maxSpacingFactor = 0.5,
    this.isSelectable = true,
    this.disableHoverEffect = false, // 默认不禁用悬停效果
  });

  @override
  State<PokerListWidget> createState() => _PokerListWidgetState();
}

class _PokerListWidgetState extends State<PokerListWidget> {
  Offset? _dragStartGlobal;
  Offset? _dragCurrentGlobal;

  // 缓存布局参数
  late double _cachedCardWidth;
  late double _cachedCardHeight;
  late double _cachedSpacing;
  late double _cachedStartPosition;
  late double _containerWidth;

  @override
  Widget build(BuildContext context) {
    // 空数据且非加载状态时不渲染
    if (widget.cards.isEmpty && !widget.isLoading) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        // 加载状态显示指示器
        if (widget.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
            ),
          );
        }
        _calculateLayoutParams(constraints);
        return GestureDetector(
          onPanStart: widget.isSelectable ? _handlePanStart : null,
          onPanUpdate: widget.isSelectable ? _handlePanUpdate : null,
          onPanEnd: widget.isSelectable ? _handlePanEnd : null,
          child: Stack(children: [_buildCardsStack()]),
        );
      },
    );
  }

  void _calculateLayoutParams(BoxConstraints constraints) {
    final containerHeight = constraints.maxHeight;
    _cachedCardHeight = containerHeight;
    _cachedCardWidth = _cachedCardHeight / 1.4;

    double overlapFactor = 1 - widget.minVisibleWidth / _cachedCardWidth;
    overlapFactor = overlapFactor.clamp(0, 1);

    double spacingFactor = widget.isTight ? 0 : widget.maxSpacingFactor;
    _cachedSpacing = _cachedCardWidth * spacingFactor;

    double totalWidth =
        _cachedCardWidth + (widget.cards.length - 1) * _cachedSpacing;
    _containerWidth = constraints.maxWidth;

    if (totalWidth > _containerWidth && widget.cards.length > 1) {
      _cachedSpacing =
          (_containerWidth - _cachedCardWidth) / (widget.cards.length - 1);
      totalWidth = _containerWidth;
    }

    switch (widget.alignment) {
      case PokerListAlignment.center:
        _cachedStartPosition = (_containerWidth - totalWidth) / 2;
        break;
      case PokerListAlignment.end:
        _cachedStartPosition = _containerWidth - totalWidth;
        break;
      default:
        _cachedStartPosition = 0;
        break;
    }
  }

  // 新增临时选择状态
  List<int> _tempSelectedIndices = [];
  Widget _buildCardsStack() {
    return SizedBox(
      height: _cachedCardHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < widget.cards.length; i++)
            Positioned(
              left: _cachedStartPosition + i * _cachedSpacing,
              child: SizedBox(
                width: _cachedCardWidth,
                height: _cachedCardHeight,
                child: PokerWidget(
                  card: widget.cards[i],
                  width: _cachedCardWidth,
                  height: _cachedCardHeight,
                  isTempSelected: _tempSelectedIndices.contains(i),
                  isSelected: widget.selectedIndices.contains(i),
                  onTapped:
                      widget.isSelectable ? () => widget.onCardTapped(i) : null,
                  isSelectable: widget.isSelectable,
                  disableHoverEffect: widget.disableHoverEffect, // 传递属性
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    _dragStartGlobal = details.globalPosition;
    _dragCurrentGlobal = details.globalPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _dragCurrentGlobal = details.globalPosition;
    final renderBox = context.findRenderObject() as RenderBox;
    _tempSelectedIndices = _calculateSelectedIndices(renderBox); // 更新临时状态
    setState(() {});
  }

  void _handlePanEnd(DragEndDetails _) {
    if (_tempSelectedIndices.isNotEmpty) {
      // 提交最终选择
      for (final index in _tempSelectedIndices) {
        widget.onCardTapped(index);
      }
    }
    setState(() {
      _tempSelectedIndices = [];
      _dragStartGlobal = null;
      _dragCurrentGlobal = null;
    });
  }

  List<int> _calculateSelectedIndices(RenderBox renderBox) {
    if (_dragStartGlobal == null || _dragCurrentGlobal == null) return [];

    final localStart = renderBox.globalToLocal(_dragStartGlobal!);
    final localEnd = renderBox.globalToLocal(_dragCurrentGlobal!);
    final selectionRect = Rect.fromPoints(localStart, localEnd);

    return widget.cards.asMap().keys.where((index) {
      final cardLeft = _cachedStartPosition + index * _cachedSpacing;

      // 计算实际可见宽度（考虑后续卡牌的覆盖）
      final nextCardLeft =
          index < widget.cards.length - 1
              ? _cachedStartPosition + (index + 1) * _cachedSpacing
              : double.infinity;

      final visibleRight =
          nextCardLeft < (cardLeft + _cachedCardWidth)
              ? nextCardLeft
              : cardLeft + _cachedCardWidth;

      final visibleRect = Rect.fromLTRB(
        cardLeft,
        0,
        visibleRight,
        _cachedCardHeight,
      );

      return visibleRect.overlaps(selectionRect);
    }).toList();
  }
}
