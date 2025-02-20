import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/presentation/providers/game_provider.dart';
import 'package:landlords_3/presentation/widgets/poker_list.dart';

class CardDisplayArea extends ConsumerWidget {
  const CardDisplayArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            ref.read(gameProvider.notifier).clearSelectedCards();
          },
          child: Column(
            children: [
              Row(
                children: [
                  // 左(其他玩家 1)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: height / 2,
                        child: Center(
                          child: PokerList(
                            cards: gameState.displayedCardsOther1,
                            minVisibleWidth: 25.0,
                            alignment: PokerListAlignment.center,
                            onCardTapped: (_) {},
                            isTight: false,
                            isSelectable: false,
                            disableHoverEffect: true,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 右 (其他玩家 2)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: height / 2,
                        child: Center(
                          child: PokerList(
                            cards: gameState.displayedCardsOther2,
                            minVisibleWidth: 25.0,
                            alignment: PokerListAlignment.center,
                            onCardTapped: (_) {},
                            isTight: false,
                            isSelectable: false,
                            disableHoverEffect: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 下 (当前玩家)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: height / 2,
                    child: Center(
                      child: PokerList(
                        cards: gameState.displayedCards,
                        minVisibleWidth: 25.0,
                        alignment: PokerListAlignment.center,
                        onCardTapped: (_) {},
                        isTight: false,
                        isSelectable: false,
                        disableHoverEffect: true,
                      ),
                    ),
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
