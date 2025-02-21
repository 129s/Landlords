import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/domain/entities/room_model.dart';
import 'package:landlords_3/presentation/providers/lobby_provider.dart';

class RoomList extends ConsumerWidget {
  const RoomList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(lobbyProvider).rooms;

    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (context, index) => _RoomListItem(room: rooms[index]),
    );
  }
}

class _RoomListItem extends StatelessWidget {
  final RoomModel room;

  const _RoomListItem({required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.people_alt),
        title: Text('房间ID: ${room.id}'),
        subtitle: Text('状态: ${room.displayStatus}'),
        trailing: _buildJoinButton(context),
        onTap: () => _showRoomDetail(context),
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: room.players.length == 3 ? Colors.grey : Colors.blue,
      ),
      onPressed: room.players.length == 3 ? null : () => _joinRoom(context),
      child: const Text('加入'),
    );
  }

  void _joinRoom(BuildContext context) {
    // TODO: 实现加入房间逻辑
  }

  void _showRoomDetail(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('房间详情 - ${room.id}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('创建时间: ${room.createdAt.toString()}'),
                const SizedBox(height: 8),
                Text('玩家人数: ${room.players.length}/3'),
              ],
            ),
          ),
    );
  }
}
