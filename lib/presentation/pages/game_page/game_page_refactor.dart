import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/presentation/providers/game_provider.dart';

// 占位组件，后续替换
class TableBackground extends StatelessWidget {
  const TableBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.green.shade700);
  }
}

// 占位组件，后续替换
class CardDisplayLayer extends StatelessWidget {
  const CardDisplayLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Card Display Area'));
  }
}

// 占位组件，后续替换
class BottomControlPanel extends StatelessWidget {
  const BottomControlPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Center(child: Text('Bottom Control Panel')),
      ),
    );
  }
}

// 占位组件，后续替换
class PlayerInfoPanel extends StatelessWidget {
  final int playerOrder;

  const PlayerInfoPanel({Key? key, required this.playerOrder})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('Player Info $playerOrder');
  }
}

enum SocketStatus { connected, connecting, disconnected, error }

extension SocketStatusExtension on SocketStatus {
  Color get color {
    switch (this) {
      case SocketStatus.connected:
        return Colors.green;
      case SocketStatus.connecting:
        return Colors.yellow;
      case SocketStatus.disconnected:
        return Colors.grey;
      case SocketStatus.error:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case SocketStatus.connected:
        return Icons.check_circle;
      case SocketStatus.connecting:
        return Icons.sync;
      case SocketStatus.disconnected:
        return Icons.signal_wifi_off;
      case SocketStatus.error:
        return Icons.error;
    }
  }

  String get displayText {
    switch (this) {
      case SocketStatus.connected:
        return '已连接';
      case SocketStatus.connecting:
        return '连接中...';
      case SocketStatus.disconnected:
        return '已断开';
      case SocketStatus.error:
        return '连接错误';
    }
  }
}

class ConnectionStatusBar extends ConsumerWidget {
  const ConnectionStatusBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(gameProvider.select((s) => s.socketStatus));

    return Container(
      color: status.color,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(status.icon, color: Colors.white),
          const SizedBox(width: 8.0),
          Text(status.displayText, style: const TextStyle(color: Colors.white)),
          if (status == SocketStatus.error)
            TextButton(
              onPressed: () {
                ref.read(gameProvider.notifier).reconnect();
              },
              child: const Text('重试', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}

class GamePage extends ConsumerStatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  @override
  void initState() {
    super.initState();
    // 确保在 build 完成后初始化 GameProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 监听连接状态
    final connectionStatus = ref.watch(
      gameProvider.select((s) => s.socketStatus),
    );

    return Scaffold(body: _buildConnectionAwareUI(connectionStatus));
  }

  Widget _buildConnectionAwareUI(SocketStatus status) {
    return switch (status) {
      SocketStatus.connected => _buildGameContent(),
      SocketStatus.connecting => _buildLoading(),
      _ => _buildReconnectButton(), // 包括 disconnected 和 error
    };
  }

  Widget _buildGameContent() {
    return Stack(
      children: [
        const TableBackground(),
        _buildPlayerInfoRow(),
        const Center(child: CardDisplayLayer()),
        const BottomControlPanel(),
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ConnectionStatusBar(),
        ),
      ],
    );
  }

  Widget _buildPlayerInfoRow() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PlayerInfoPanel(playerOrder: 0), // 假设 0 是当前玩家
            PlayerInfoPanel(playerOrder: 1),
            PlayerInfoPanel(playerOrder: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildReconnectButton() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('连接失败，请重试'),
          ElevatedButton(
            onPressed: () {
              ref.read(gameProvider.notifier).reconnect();
            },
            child: const Text('重新连接'),
          ),
        ],
      ),
    );
  }
}
