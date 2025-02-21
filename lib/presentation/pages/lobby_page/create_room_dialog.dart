import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/presentation/providers/lobby_provider.dart';

class CreateRoomDialog extends ConsumerWidget {
  const CreateRoomDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerName = ref.watch(lobbyProvider).playerName ?? '';
    final controller = TextEditingController(text: playerName);

    return AlertDialog(
      title: const Text('创建房间'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: '玩家名称',
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
            final name = controller.text;
            ref.read(lobbyProvider.notifier).setPlayerName(name);
            ref.read(lobbyProvider.notifier).createRoom();
            Navigator.pop(context);
          },
          child: const Text('创建'),
        ),
      ],
    );
  }
}
