import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/data/providers/repo_providers.dart';
import 'package:landlords_3/presentation/pages/chat/chat_page.dart';
import 'package:landlords_3/presentation/pages/lobby/room_list.dart';
import 'package:landlords_3/presentation/providers/lobby_provider.dart';
import 'package:landlords_3/presentation/widgets/connection_status_indicator.dart';

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
            onPressed: () => _refreshRooms(context, ref),
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
        onPressed: () => _createRoom(context, ref),
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
      ref.read(roomRepoProvider).watchRooms().listen((rooms) {
        ref.read(lobbyProvider.notifier).updateRooms(rooms);
      });
    } catch (e) {
      // 获取房间列表失败
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('获取房间列表失败，请稍后重试')));
    } finally {
      ref.read(lobbyProvider.notifier).toggleLoading();
    }
  }

  void _createRoom(BuildContext context, WidgetRef ref) async {
    try {
      final isValid = await ref
          .read(lobbyProvider.notifier)
          .validatePlayerName(context);
      if (!isValid || !context.mounted) return;

      final roomId = await ref.read(roomRepoProvider).createRoom();

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatPage(roomId: roomId)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('创建失败: ${e.toString()}')));
      }
    }
  }

  void _joinRoom(String roomId, WidgetRef ref, BuildContext context) async {
    final isValid = await ref
        .read(lobbyProvider.notifier)
        .validatePlayerName(context);
    if (!isValid || !context.mounted) return;

    try {
      await ref.read(lobbyProvider.notifier).joinRoom(roomId);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatPage(roomId: roomId)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加入失败: ${e.toString()}')));
      }
    }
  }
}
