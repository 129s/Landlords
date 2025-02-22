import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network/socket_service.dart';
import 'package:landlords_3/presentation/pages/game/chat_page.dart';
import 'package:landlords_3/presentation/pages/lobby/room_list.dart';
import 'package:landlords_3/presentation/providers/lobby_provider.dart';
import 'package:landlords_3/presentation/widgets/connection_status_indicator.dart';
import 'package:landlords_3/presentation/widgets/player_name_dialog.dart';

class LobbyPage extends ConsumerStatefulWidget {
  const LobbyPage({super.key});

  @override
  ConsumerState<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends ConsumerState<LobbyPage> {
  @override
  void initState() {
    super.initState();
    _refreshRooms(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final lobbyState = ref.watch(lobbyProvider);
    final playerName = lobbyState.playerName ?? '未命名玩家';
    return Scaffold(
      appBar: AppBar(
        title: const Text('游戏大厅'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshRooms(context, ref),
          ),
          _buildPlayerInfo(playerName),
        ],
      ),
      body: Stack(
        // 使用 Stack
        children: [
          Column(
            children: [
              _buildSearchBar(context, ref),
              const Divider(height: 1),
              Expanded(
                child:
                    lobbyState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const RoomList(),
              ),
            ],
          ),
          const ConnectionStatusIndicator(), // 添加指示器
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateRoomDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlayerInfo(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.person),
          const SizedBox(width: 8),
          Text(name),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: '输入房间ID加入游戏',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => _joinRoom(value, ref, context),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshRooms(BuildContext context, WidgetRef ref) async {
    ref.read(lobbyProvider.notifier).toggleLoading();
    try {
      SocketService().requestRooms();
    } catch (e) {
      // 获取房间列表失败
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('获取房间列表失败，请稍后重试')));
    } finally {
      ref.read(lobbyProvider.notifier).toggleLoading();
    }
  }

  void _showCreateRoomDialog(BuildContext context, WidgetRef ref) async {
    if (ref.read(lobbyProvider).isGaming) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('您已经在游戏中，请先退出游戏')));
      return;
    }

    if (!ref.read(lobbyProvider.notifier).hasPlayerName()) {
      showDialog(
        context: context,
        builder: (context) => const PlayerNameDialog(title: '创建房间'),
      ).then((_) => ref.read(lobbyProvider.notifier).createRoom());
    }
    ref.read(lobbyProvider.notifier).createRoom();
    await SocketService().roomCreatedStream.first.then(
      (roomId) => {
        print("房间" + roomId),
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatPage(roomId: roomId)),
        ),
      },
    );
  }

  void _joinRoom(String roomId, WidgetRef ref, BuildContext context) {
    if (ref.read(lobbyProvider).isGaming) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('您已经在游戏中，请先退出游戏')));
      return;
    }

    if (!ref.read(lobbyProvider.notifier).hasPlayerName()) {
      showDialog(
        context: context,
        builder: (context) => const PlayerNameDialog(title: '加入房间'),
      ).then((_) => ref.read(lobbyProvider.notifier).joinRoom(roomId));
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatPage(roomId: roomId)),
    );
    ref.read(lobbyProvider.notifier).joinRoom(roomId);
  }
}
