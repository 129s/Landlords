// presentation/pages/lobby_page/create_room_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/presentation/providers/lobby_provider.dart';

class CreateRoomDialog extends ConsumerWidget {
  const CreateRoomDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _roomNameController = TextEditingController();

    return AlertDialog(
      title: const Text('创建房间'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _roomNameController,
            decoration: const InputDecoration(
              labelText: '房间名称',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            final roomName = _roomNameController.text;
            if (roomName.isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('房间名称不能为空')));
              return;
            }
            ref.read(lobbyProvider.notifier).createRoom(roomName);
            Navigator.pop(context);
          },
          child: const Text('创建'),
        ),
      ],
    );
  }
}
