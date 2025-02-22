// presentation\pages\lobby_page\lobby_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network/socket_service.dart';
import 'package:landlords_3/data/providers/socket_provider.dart';
import 'package:landlords_3/presentation/pages/lobby_page/create_room_dialog.dart';
import 'package:landlords_3/presentation/pages/lobby_page/room_list.dart';
import 'package:landlords_3/presentation/providers/lobby_provider.dart';
import 'package:landlords_3/presentation/widgets/connection_status_indicator.dart'; // 导入
import 'package:landlords_3/presentation/providers/user_provider.dart'; // Import user provider

class LobbyPage extends ConsumerWidget {
  const LobbyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lobbyState = ref.watch(lobbyProvider);
    final user = ref.watch(userProvider); // Get user from provider
    final playerName = user?.username ?? '未命名玩家'; // Use user's username

    return Scaffold(
      appBar: AppBar(
        title: const Text('游戏大厅'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshRooms(ref, context), // 传递 context
          ),
          _buildPlayerInfo(playerName),
        ],
      ),
      body: Stack(
        // 使用 Stack
        children: [
          Column(
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

  Widget _buildQuickActionBar(WidgetRef ref) {
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
              onSubmitted: (value) => _joinRoom(value, ref),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshRooms(WidgetRef ref, BuildContext context) async {
    // 添加 context 参数
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

  void _showCreateRoomDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const CreateRoomDialog(),
    );
  }

  void _joinRoom(String roomId, WidgetRef ref) {
    ref.read(lobbyProvider.notifier).joinRoom(roomId);
  }
}
