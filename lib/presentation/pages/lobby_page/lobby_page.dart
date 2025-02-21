import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/presentation/pages/lobby_page/create_room_dialog.dart';
import 'package:landlords_3/presentation/pages/lobby_page/room_list.dart';
import 'package:landlords_3/presentation/providers/lobby_provider.dart';

class LobbyPage extends ConsumerWidget {
  const LobbyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lobbyState = ref.watch(lobbyProvider);
    final playerName = lobbyState.playerName ?? '未命名玩家';

    return Scaffold(
      appBar: AppBar(
        title: const Text('游戏大厅'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshRooms(ref),
          ),
          _buildPlayerInfo(playerName),
        ],
      ),
      body: Column(
        children: [
          _buildQuickActionBar(ref),
          const Divider(height: 1),
          Expanded(
            child:
                lobbyState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const RoomList(),
          ),
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

  Widget _buildQuickActionBar(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: '输入房间ID快速加入',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => _joinRoom(value, ref),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshRooms(WidgetRef ref) {
    ref.read(lobbyProvider.notifier).toggleLoading();
    // TODO: 调用获取房间列表的接口
    Future.delayed(const Duration(seconds: 1), () {
      ref.read(lobbyProvider.notifier).toggleLoading();
    });
  }

  void _showCreateRoomDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const CreateRoomDialog(),
    );
  }

  void _joinRoom(String roomId, WidgetRef ref) {
    // TODO: 实现快速加入逻辑
  }
}
