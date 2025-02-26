import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/card/card_type.dart';
import 'package:landlords_3/core/network_services/constants/constants.dart';
import 'package:landlords_3/data/models/game_state.dart';
import 'package:landlords_3/presentation/pages/game/player_info_widget.dart';
import 'package:landlords_3/presentation/providers/game_provider.dart';
import 'package:landlords_3/presentation/widgets/poker_list_widget.dart';

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
          // 主内容区域
          Column(
            children: [
              // 顶部操作栏
              _buildTopBar(context, ref),
              // 中央游戏区域
              Expanded(child: _buildGameArea(gameState)),
              // 功能按钮栏
              _buildActionBar(gameState),
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

  Widget _buildTopBar(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.exit_to_app, color: Colors.white),
        onPressed: () => _handleExit(context, ref),
      ),
      title: _buildCardCounter(gameState), // 记牌器区域
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => _showSettings(context),
        ),
      ],
    );
  }

  Widget _buildCardCounter(GameState gameState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("剩余牌数", style: TextStyle(color: Colors.white, fontSize: 12)),
        Text(
          _calculateRemainingCards(gameState).toString(),
          style: const TextStyle(color: Colors.amber, fontSize: 18),
        ),
      ],
    );
  }

  int _calculateRemainingCards(GameState state) {
    // 计算逻辑：总牌数54 - 已出牌数 - 玩家手牌总数
    final playedCount = state.lastPlayedCards.length;
    final playerHands = state.players.fold<int>(
      0,
      (sum, p) => sum + p.cards.length,
    );
    return 54 - playedCount - playerHands - state.playerCards.length;
  }

  Widget _buildGameArea(GameState gameState) {
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
        _buildOpponentsInfo(gameState),
      ],
    );
  }

  Widget _buildActionBar(GameState gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child:
          gameState.gamePhase == GamePhase.bidding
              ? _buildBiddingButtons()
              : gameState.gamePhase == GamePhase.playing
              ? _buildPlayingButtons()
              : const SizedBox.shrink(),
    );
  }

  Widget _buildBiddingButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          [1, 2, 3]
              .map(
                (score) => ElevatedButton(
                  onPressed: () => _placeBid(score),
                  child: Text("$score 分"),
                ),
              )
              .toList(),
    );
  }

  Widget _buildPlayingButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(onPressed: _playCards, child: const Text("出牌")),
        const SizedBox(width: 36),
        ElevatedButton(onPressed: _showHint, child: const Text("提示")),
        const SizedBox(width: 36),
        ElevatedButton(onPressed: _passTurn, child: const Text("跳过")),
      ],
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
  Widget _buildOpponentsInfo(GameState gameState) {
    final myIndex = gameState.myPlayerIndex;
    final players = gameState.players;

    // 获取其他两个玩家的索引（根据斗地主座位逻辑）
    final leftPlayerIndex = (myIndex + 1) % 3;
    final rightPlayerIndex = (myIndex + 2) % 3;

    return Stack(
      children: [
        Positioned(
          left: 20,
          top: 20,
          child: PlayerInfoWidget(
            player: players[leftPlayerIndex],
            isLandlord: leftPlayerIndex == gameState.landlordIndex,
            isCurrentTurn: leftPlayerIndex == gameState.currentPlayerIndex,
            alignment: Alignment.centerLeft,
          ),
        ),
        Positioned(
          right: 20,
          top: 20,
          child: PlayerInfoWidget(
            player: players[rightPlayerIndex],
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

  // 交互方法（需要后续连接游戏逻辑）
  void _handleExit(BuildContext context, WidgetRef ref) {}
  void _showSettings(BuildContext context) {}
  void _placeBid(int score) {}
  void _playCards() {}
  void _showHint() {}
  void _passTurn() {}
}
