import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/card/card_type.dart';
import 'package:landlords_3/core/network_services/constants/constants.dart';
import 'package:landlords_3/data/models/game_state.dart';
import 'package:landlords_3/data/models/player.dart';
import 'package:landlords_3/data/providers/service_providers.dart';
import 'package:landlords_3/presentation/pages/game/additional_cards_widget.dart';
import 'package:landlords_3/presentation/pages/game/card_counter_widget.dart';
import 'package:landlords_3/presentation/pages/game/player_info_widget.dart';
import 'package:landlords_3/presentation/pages/lobby/lobby_page.dart';
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
          // 底牌展示
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            child: Center(
              child: AdditionalCardsWidget(
                cards: gameState.additionalCards,
                isRevealed: gameState.landlordIndex != -1,
              ),
            ),
          ),
          // 主内容区域
          Column(
            children: [
              // 顶部操作栏
              _buildTopBar(context, gameState, gameNotifer),
              // 中央游戏区域
              Expanded(child: _buildGameArea(gameState, ref)),
              // 功能按钮栏
              _buildActionBar(gameState, gameNotifer),
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
        Center(child: CardCounterWidget(gameState: gameState)),
      ],
    );
  }

  Widget _buildGameArea(GameState gameState, WidgetRef ref) {
    return Stack(
      children: [
        // 其他玩家出牌区域
        Positioned(
          top: 20,
          left: 20,
          child: _buildOpponentPlayedCards(isLeftPlayer: true),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: _buildOpponentPlayedCards(isLeftPlayer: false),
        ),
        // 当前出牌区域
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: _buildCurrentPlayCards(),
        ),
        // 其他玩家信息
        _buildOpponentsInfo(gameState, ref),
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
              ? SizedBox.shrink() // 非玩家行动回合不显示行动栏
              : gameState.gamePhase == GamePhase.bidding
              ? _buildBiddingButtons(gameState, gameNotifer)
              : gameState.gamePhase == GamePhase.playing
              ? _buildPlayerControls(gameNotifer)
              : const SizedBox.shrink(),
    );
  }

  // 准备按钮
  Widget _buildPreparingButtons(GameState gameState, GameNotifier gameNotifer) {
    final isPrepared = gameState.players[gameState.myPlayerIndex].ready;
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
                .reduce((current, next) => current < next ? current : next);
            final isDisabled =
                score == 0
                    ? false
                    : gameState.players[gameState.myPlayerIndex].bidValue <
                        maxBidValue;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDisabled ? Colors.blueGrey : Colors.blue,
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
    final players = gameState.players;

    // 获取其他两个玩家的索引（根据斗地主座位逻辑）
    final leftPlayerIndex = (myIndex + 1) % 3;
    final rightPlayerIndex = (myIndex + 2) % 3;
    final leftPlayer =
        leftPlayerIndex > players.length
            ? Player(id: "", name: "等待加入", seat: 0, ready: false)
            : players[leftPlayerIndex];
    final rightPlayer =
        rightPlayerIndex > players.length
            ? Player(id: "", name: "等待加入", seat: 0, ready: false)
            : players[rightPlayerIndex];

    return Stack(
      children: [
        Positioned(
          left: 20,
          top: 20,
          child: PlayerInfoWidget(
            player: leftPlayer,
            isLandlord: leftPlayerIndex == gameState.landlordIndex,
            isCurrentTurn: leftPlayerIndex == gameState.currentPlayerIndex,
            alignment: Alignment.centerLeft,
          ),
        ),
        Positioned(
          right: 20,
          top: 20,
          child: PlayerInfoWidget(
            player: rightPlayer,
            isLandlord: rightPlayerIndex == gameState.landlordIndex,
            isCurrentTurn: rightPlayerIndex == gameState.currentPlayerIndex,
            alignment: Alignment.centerRight,
          ),
        ),
      ],
    );
  }

  Widget _buildOpponentPlayedCards({required bool isLeftPlayer}) {
    return Consumer(
      builder: (context, ref, _) {
        final gameState = ref.watch(gameProvider);
        final myIndex = gameState.myPlayerIndex;
        final currentPlayerIndex = gameState.currentPlayerIndex;

        // 判断是否是当前玩家的对手
        final isOpponent = currentPlayerIndex != myIndex;
        final isLeftOpponent = (myIndex + 1) % 3 == currentPlayerIndex;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child:
              (isOpponent && gameState.lastPlayedCards.isNotEmpty)
                  ? Column(
                    key: ValueKey(gameState.lastPlayedCards.hashCode),
                    children: [
                      // 出牌方向指示器（根据座位关系显示左右箭头）
                      Icon(
                        isLeftOpponent ? Icons.arrow_back : Icons.arrow_forward,
                        color: Colors.white.withOpacity(0.5),
                        size: 24,
                      ),
                      // 对手出牌展示
                      PokerListWidget(
                        cards: gameState.lastPlayedCards,
                        onCardTapped: (_) {},
                        isSelectable: false,
                        disableHoverEffect: true,
                        alignment:
                            isLeftOpponent
                                ? PokerListAlignment.start
                                : PokerListAlignment.end,
                        minVisibleWidth: 10,
                      ),
                    ],
                  )
                  : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildCurrentPlayCards() {
    return Consumer(
      builder: (context, ref, _) {
        final gameState = ref.watch(gameProvider);
        final lastPlayed = gameState.lastPlayedCards;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child:
              lastPlayed.isNotEmpty
                  ? Column(
                    key: ValueKey(lastPlayed.hashCode),
                    children: [
                      // 当前牌局展示
                      PokerListWidget(
                        cards: lastPlayed,
                        onCardTapped: (_) {},
                        isSelectable: false,
                        disableHoverEffect: true,
                        alignment: PokerListAlignment.center,
                      ),
                      // 出牌类型提示
                      if (CardType.getType(lastPlayed) != CardTypeEnum.invalid)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            CardType.getTypeName(CardType.getType(lastPlayed)),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  )
                  : const SizedBox.shrink(),
        );
      },
    );
  }
}
