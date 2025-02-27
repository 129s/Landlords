import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/data/models/player.dart';
import 'package:landlords_3/data/models/room.dart';
import 'package:landlords_3/presentation/pages/chat/chat_page.dart';
import 'package:landlords_3/presentation/pages/game/game_page.dart';
import 'package:landlords_3/presentation/providers/lobby_provider.dart';
import 'package:landlords_3/presentation/widgets/player_name_dialog.dart';

class RoomList extends ConsumerWidget {
  const RoomList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lobbyState = ref.watch(lobbyProvider);
    final rooms = lobbyState.rooms;

    if (rooms.isEmpty && !lobbyState.isLoading) {
      return const Center(child: Text('暂无房间，请稍后刷新或创建房间'));
    }

    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (context, index) => _RoomListItem(room: rooms[index]),
    );
  }
}

class _RoomListItem extends StatelessWidget {
  final Room room;

  const _RoomListItem({required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.people_alt),
        title: Text('房间ID: ${room.id}'),
        subtitle: Text('状态: ${room.roomStatus}'),
        trailing: _buildJoinButton(context),
        onTap: () {},
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: room.playerCount == 3 ? Colors.grey : Colors.blue,
      ),
      onPressed: () {
        ProviderScope.containerOf(
          context,
        ).read(lobbyProvider.notifier).joinExistingRoom(room.id).then((_) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => GamePage(roomId: room.id)));
        });
      },
      child: const Text('加入'),
    );
  }
}
