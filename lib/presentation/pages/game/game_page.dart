import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/card/card_type.dart';
import 'package:landlords_3/core/network_services/constants/constants.dart';
import 'package:landlords_3/data/models/game_state.dart';
import 'package:landlords_3/data/models/player.dart';
import 'package:landlords_3/presentation/pages/game/additional_cards_widget.dart';
import 'package:landlords_3/presentation/pages/game/card_counter_widget.dart';
import 'package:landlords_3/presentation/pages/game/player_info_widget.dart';
import 'package:landlords_3/presentation/providers/game_provider.dart';
import 'package:landlords_3/presentation/widgets/poker_list_widget.dart';
import 'package:logger/logger.dart';

class GamePage extends ConsumerWidget {
  final String roomId;

  const GamePage({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifer = ref.watch(gameProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          // 背景图片
          _buildBackground(),
          // 玩家信息
          _buildOpponentsInfo(gameState, ref),
          // 主内容区域
          Column(
            children: [
              // 顶部操作栏
              _buildTopBar(context, gameState, gameNotifer),
              Expanded(
                child: Stack(
                  children: [
                    // 最后一个玩家出牌
                    Center(
                      child: SizedBox(
                        height: 128,
                        child: PokerListWidget(
                          cards: gameState.lastPlayedCards,
                          onCardTapped: (_) {},
                          disableHoverEffect: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 功能按钮栏
              _buildActionBar(gameState, gameNotifer),
              // 调试GameState相关信息
              // Container(
              //   margin: EdgeInsets.all(24),
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 12,
              //     vertical: 8,
              //   ),
              //   decoration: BoxDecoration(
              //     color: Colors.black54,
              //     borderRadius: BorderRadius.circular(16),
              //   ),
              //   child: Text(
              //     "${gameState.toJson()}",
              //     style: TextStyle(color: Colors.amber),
              //   ),
              // ),
              // 玩家手牌区域
              _buildMyHandCards(gameState, gameNotifer),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/table_background.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    GameState gameState,
    GameNotifier gameNotifer,
  ) {
    return Stack(
      children: [
        Positioned(
          left: 24,
          top: 24,
          child: IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed:
                () => gameNotifer.leaveGame().then((_) {
                  Navigator.pop(context);
                }), // 退出并返回大厅
          ),
        ),
        Positioned(
          right: 24,
          top: 24,
          child: IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {}, // 设置按钮 TODO: 显示设置面板
          ),
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AdditionalCardsWidget(gameState),
              CardCounterWidget(gameState: gameState),
            ],
          ),
        ),
      ],
    );
  }

  //行动栏
  Widget _buildActionBar(GameState gameState, GameNotifier gameNotifer) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child:
          gameState.gamePhase == GamePhase.preparing
              ? _buildPreparingButtons(gameState, gameNotifer)
              : gameState.currentPlayerIndex != gameState.myPlayerIndex
              ? const SizedBox.shrink() // 非玩家行动回合不显示行动栏
              : gameState.gamePhase == GamePhase.bidding
              ? _buildBiddingButtons(gameState, gameNotifer)
              : gameState.gamePhase == GamePhase.playing
              ? _buildPlayerControls(gameNotifer)
              : const SizedBox.shrink(),
    );
  }

  // 准备按钮
  Widget _buildPreparingButtons(GameState gameState, GameNotifier gameNotifer) {
    final isPrepared = _getMyPlayer(gameState).ready;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isPrepared ? Colors.green : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => gameNotifer.toggleReady(),
            child: isPrepared ? const Text("解除") : const Text("准备"),
          ),
        ),
      ],
    );
  }

  // 叫分按钮
  Widget _buildBiddingButtons(GameState gameState, GameNotifier gameNotifer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          [0, 1, 2, 3].map((score) {
            final maxBidValue = gameState.players
                .map((e) => e.bidValue)
                .reduce((current, next) => current > next ? current : next);
            Logger().d(maxBidValue);
            final isDisabled = score == 0 ? false : score <= maxBidValue;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDisabled ? Colors.grey : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed:
                    isDisabled ? null : () => gameNotifer.placeBid(score),
                child: score > 0 ? Text("$score 分") : const Text("不叫"),
              ),
            );
          }).toList(),
    );
  }

  // 控制按钮
  Widget _buildPlayerControls(GameNotifier gameNotifer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: Icons.help_outline,
          label: '提示',
          onPressed: () => gameNotifer.showHint(),
        ),
        _buildActionButton(
          icon: Icons.close,
          label: '不出',
          onPressed: () => gameNotifer.passTurn(),
        ),
        _buildActionButton(
          icon: Icons.play_arrow,
          label: '出牌',
          onPressed: () => gameNotifer.playSelectedCards(),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    const iconSize = 24.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue.shade600,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 2,
          animationDuration: const Duration(milliseconds: 150),
        ),
        onPressed: onPressed,
        child: SizedBox(
          width: 100, // 固定宽度保持按钮大小一致
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyHandCards(GameState gameState, GameNotifier gameNotifer) {
    return SizedBox(
      height: 150,
      child: PokerListWidget(
        cards: gameState.playerCards,
        onCardTapped: (index) => gameNotifer.toggleCardSelection(index),
        selectedIndices: gameState.selectedIndices,
      ),
    );
  }

  // 玩家信息组件
  Widget _buildOpponentsInfo(GameState gameState, WidgetRef ref) {
    final myIndex = gameState.myPlayerIndex;

    // 获取其他两个玩家的索引（根据斗地主座位逻辑）
    final leftPlayerIndex = (myIndex - 1) % 3;
    final rightPlayerIndex = (myIndex + 1) % 3;
    final leftPlayer = _getPlayerBySeat(gameState, leftPlayerIndex);

    final rightPlayer = _getPlayerBySeat(gameState, rightPlayerIndex);

    return Stack(
      children: [
        Positioned(
          left: 24,
          top: 96,
          child: PlayerInfoWidget(
            player: leftPlayer,
            isLandlord: leftPlayerIndex == gameState.landlordIndex,
            isCurrentTurn: leftPlayerIndex == gameState.currentPlayerIndex,
            alignment: Alignment.centerLeft,
            gamePhase: gameState.gamePhase,
          ),
        ),
        Positioned(
          right: 24,
          top: 96,
          child: PlayerInfoWidget(
            player: rightPlayer,
            isLandlord: rightPlayerIndex == gameState.landlordIndex,
            isCurrentTurn: rightPlayerIndex == gameState.currentPlayerIndex,
            alignment: Alignment.centerRight,
            gamePhase: gameState.gamePhase,
          ),
        ),
      ],
    );
  }

  Player _buildWaitingPlayer(int seat) {
    return Player(
      id: "waiting_$seat",
      name: "等待加入",
      seat: seat,
      ready: false,
      cardCount: 0,
      isLandlord: false,
      bidValue: 0,
    );
  }

  Player _getMyPlayer(GameState gameState) {
    return gameState.players.firstWhere(
      (p) => p.seat == gameState.myPlayerIndex,
    );
  }

  Player _getPlayerBySeat(GameState gameState, int seat) {
    return gameState.players.firstWhere(
      (p) => p.seat == seat,
      orElse: () => _buildWaitingPlayer(seat),
    );
  }
}
