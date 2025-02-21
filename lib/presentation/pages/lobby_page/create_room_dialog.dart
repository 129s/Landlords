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
          const SizedBox(height: 16),
          const Text('高级选项'),
          SwitchListTile(
            title: const Text('需要密码'),
            value: false,
            onChanged: (_) {},
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
            ref.read(lobbyProvider.notifier).setPlayerName(controller.text);
            // TODO: 调用创建房间接口
            Navigator.pop(context);
          },
          child: const Text('创建'),
        ),
      ],
    );
  }
}
