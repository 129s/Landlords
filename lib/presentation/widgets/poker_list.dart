import 'package:flutter/material.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';
import 'package:landlords_3/presentation/widgets/poker.dart';

enum PokerListAlignment { start, center, end }

class PokerList extends StatefulWidget {
  final List<PokerData> cards;
  final double minVisibleWidth; // 最小可见宽度，确保能看到数字
  final PokerListAlignment alignment; // 对齐方式
  final bool isTight; // 是否紧密排列
  final double maxSpacingFactor; // 最大间距因子
  final Function(int) onCardTapped; // 新增属性

  const PokerList({
    Key? key,
    required this.cards,
    required this.onCardTapped,
    this.minVisibleWidth = 20.0, // 最小可见宽度，确保能看到数字
    this.alignment = PokerListAlignment.center, // 默认居中对齐
    this.isTight = false, // 默认不紧密排列
    this.maxSpacingFactor = 0.5, // 最大间距因子
  }) : super(key: key);

  @override
  State<PokerList> createState() => _PokerListState();
}

class _PokerListState extends State<PokerList> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerHeight = constraints.maxHeight; // 获取容器高度
        final cardHeight = containerHeight; // 卡牌高度等于容器高度
        final cardWidth = cardHeight / 1.4; // 假设卡牌宽高比为 1:1.4，宽度由高度决定

        // 计算重叠因子，确保最小可见宽度
        double overlapFactor = 1 - widget.minVisibleWidth / cardWidth;
        overlapFactor = overlapFactor.clamp(0, 1); // 限制在 0 到 1 之间

        // 计算卡牌之间的间距
        double spacingFactor = widget.isTight ? 0 : widget.maxSpacingFactor;
        double spacing = cardWidth * spacingFactor; // 使用 spacingFactor

        // 计算总宽度
        double totalWidth = cardWidth + (widget.cards.length - 1) * spacing;

        // 如果卡牌总宽度超过容器宽度，则调整间距
        if (totalWidth > constraints.maxWidth && widget.cards.length > 1) {
          spacing =
              (constraints.maxWidth - cardWidth) / (widget.cards.length - 1);
          spacingFactor = spacing / cardWidth; // 重新计算 spacingFactor
          overlapFactor = 0; // 不重叠
          totalWidth = constraints.maxWidth; // 总宽度等于容器宽度
        }

        // 计算起始位置
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
                      onTapped: () {
                        widget.onCardTapped(i);
                      },
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
