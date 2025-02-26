import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network_services/constants/constants.dart';
import 'package:landlords_3/data/models/game_state.dart';
import 'package:landlords_3/presentation/pages/game/bottom_area.dart';
import 'package:landlords_3/presentation/pages/game/card_display_area.dart';
import 'package:landlords_3/presentation/pages/game/player_info.dart';
import 'package:landlords_3/presentation/pages/game/table_area.dart';
import 'package:landlords_3/presentation/pages/game/top_bar.dart';
import 'package:landlords_3/presentation/providers/game_provider.dart';

class GamePage extends ConsumerWidget {
  final String roomId;
  const GamePage({Key? key, required this.roomId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 初始化游戏状态
    final gameState = ref.watch(gameProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(gameProvider.notifier);
      if (notifier.state.gamePhase == GamePhase.preparing &&
          notifier.state.playerCards.isEmpty) {
        notifier.initializeGame(roomId);
      }
    });
    return Scaffold(
      body: Stack(
        children: [
          // 多实例调试信息
          Positioned(
            left: 10,
            top: 100,
            child: Container(
              padding: EdgeInsets.all(8),
              color: Colors.white54,
              child: Text("", style: TextStyle(fontSize: 20)),
            ),
          ),
          const TableArea(),
          Column(
            children: [
              const TopBar(),
              Expanded(
                child: Stack(
                  children: [
                    // 左侧玩家信息
                    Positioned(
                      left: 20.0,
                      top: 20.0,
                      child: const PlayerInfo(seatNumber: 1),
                    ),
                    // 右侧玩家信息
                    Positioned(
                      right: 20.0,
                      top: 20.0,
                      child: const PlayerInfo(seatNumber: 2),
                    ),
                    gameState.gamePhase == GamePhase.preparing
                        ? SizedBox.shrink()
                        : CardDisplayArea(),
                    // 卡牌展示区域
                  ],
                ),
              ),

              Stack(
                children: [
                  (gameState.gamePhase == GamePhase.bidding)
                      ? _buildBiddingUI(ref)
                      : BottomArea(),
                  Positioned(right: 24, top: 24, child: _buildChatButton()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiddingUI(WidgetRef ref) {
    final currentBid = ref.watch(gameProvider).currentBid;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("当前叫分: $currentBid", style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                [1, 2, 3]
                    .map(
                      (bid) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ElevatedButton(
                          onPressed:
                              () =>
                                  ref.read(gameProvider.notifier).placeBid(bid),
                          child: Text("叫 $bid 分"),
                        ),
                      ),
                    )
                    .toList(),
          ),
          ElevatedButton(
            onPressed: () => ref.read(gameProvider.notifier).placeBid(0),
            child: const Text("不叫"),
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: 实现表情包、语音功能
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(), // 圆形按钮
        padding: const EdgeInsets.all(20), // 增加内边距
      ),
      child: const Icon(Icons.chat_rounded, size: 32),
    );
  }
}
