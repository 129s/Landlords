import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/presentation/pages/game_page/bottom_area.dart';
import 'package:landlords_3/presentation/pages/game_page/card_display_area.dart';
import 'package:landlords_3/presentation/pages/game_page/player_info.dart';
import 'package:landlords_3/presentation/pages/game_page/table_area.dart';
import 'package:landlords_3/presentation/pages/game_page/top_bar.dart';
import 'package:landlords_3/presentation/providers/game_provider.dart';

class GamePage extends ConsumerWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 初始化游戏状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(gameProvider.notifier);
      if (notifier.state.phase == GamePhase.dealing &&
          notifier.state.playerCards.isEmpty) {
        notifier.initializeGame();
      }
    });
    final gameState = ref.watch(gameProvider);
    return Scaffold(
      body: Stack(
        children: [
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
                      child: const PlayerInfo(isLeft: true),
                    ),
                    // 右侧玩家信息
                    Positioned(
                      right: 20.0,
                      top: 20.0,
                      child: const PlayerInfo(isLeft: false),
                    ),
                    // 卡牌展示区域
                    CardDisplayArea(),
                    // 多实例调试信息
                    Center(
                      child: Text(
                        '${const String.fromEnvironment('PLAYER_NAME')}',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),

              Stack(
                children: [
                  BottomArea(),
                  Positioned(right: 24, top: 24, child: _buildChatButton()),
                ],
              ),
            ],
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
