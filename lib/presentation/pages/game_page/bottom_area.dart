// lib/presentation/widgets/bottom_area.dart
import 'package:flutter/material.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';
import 'package:landlords_3/presentation/widgets/poker_list.dart';

class BottomArea extends StatefulWidget {
  final List<PokerData> playerCards;
  final Function(List<PokerData>) onCardsPlayed;

  const BottomArea({
    Key? key,
    required this.playerCards,
    required this.onCardsPlayed,
  }) : super(key: key);

  @override
  State<BottomArea> createState() => _BottomAreaState();
}

class _BottomAreaState extends State<BottomArea> {
  List<int> selectedIndices = []; // 用于存储选中的卡牌的索引

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: Column(
        children: [
          // 操作按钮
          _buildActionButtons(),
          // 卡牌列表
          Expanded(
            // 使用 Expanded 让 PokerList 占据剩余空间
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PokerList(
                cards: widget.playerCards,
                minVisibleWidth: 25.0,
                onCardTapped: (index) {
                  setState(() {
                    if (selectedIndices.contains(index)) {
                      selectedIndices.remove(index);
                    } else {
                      selectedIndices.add(index);
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 操作按钮
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () {
            // TODO: 实现出牌功能
            List<PokerData> cardsToPlay = [];
            selectedIndices.sort(); // 确保索引是排序的
            for (int index in selectedIndices) {
              cardsToPlay.add(widget.playerCards[index]);
            }
            widget.onCardsPlayed(cardsToPlay); // 将选中的卡牌传递给 GamePage
            setState(() {
              // 移除已经打出的牌
              for (int index in selectedIndices.reversed) {
                widget.playerCards.removeAt(index);
              }
              selectedIndices.clear(); // 清空选中的卡牌
            });
          },
          child: const Text('出牌'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: 实现提示功能
          },
          child: const Text('提示'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: 实现跳过功能
          },
          child: const Text('跳过'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: 实现抢地主/叫分功能
          },
          child: const Text('抢地主/叫分'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: 实现表情包、语音功能
          },
          child: const Icon(Icons.chat_bubble),
        ),
      ],
    );
  }
}
