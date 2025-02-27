import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/data/providers/service_providers.dart';
import 'package:landlords_3/presentation/pages/game/game_page.dart';
import 'package:landlords_3/presentation/pages/lobby/room_list.dart';
import 'package:landlords_3/presentation/providers/lobby_provider.dart';
import 'package:landlords_3/presentation/widgets/connection_status_indicator.dart';
import 'package:logger/logger.dart';

class LobbyPage extends ConsumerStatefulWidget {
  const LobbyPage({super.key});
  @override
  ConsumerState<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends ConsumerState<LobbyPage> {
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
            onPressed: () => _refreshRooms(),
          ),
          _buildPlayerInfo(playerName),
          _buildConnectionStatus(),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => ref.read(lobbyProvider.notifier).createAndJoinRoom().then((
              roomId,
            ) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => GamePage(roomId: roomId)),
              );
            }),
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

  Widget _buildConnectionStatus() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: const ConnectionStatusIndicator(),
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
                hintText: '输入ID查找房间',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {}, //TODO: 实现列表筛选
            ),
          ),
        ],
      ),
    );
  }

  void _refreshRooms() async {
    ref.read(lobbyProvider.notifier).toggleLoading(isLoading: true);
    ref.read(roomServiceProvider).refreshRoomList();
    ref.read(lobbyProvider.notifier).toggleLoading(isLoading: false);
  }
}
