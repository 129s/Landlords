import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/presentation/pages/lobby/lobby_page.dart';
import 'package:landlords_3/presentation/providers/lobby_provider.dart';

class TopBar extends ConsumerWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(color: Colors.brown.withAlpha(225)),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(color: Colors.amberAccent, Icons.exit_to_app),
            onPressed: () {
              ref.read(lobbyProvider.notifier).leaveRoom();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LobbyPage()),
                );
              }
            },
          ),
          const Text(
            '记牌器 ',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.amberAccent),
          ),
          IconButton(
            icon: const Icon(color: Colors.amberAccent, Icons.settings),
            onPressed: () {
              // TODO: 实现设置功能
            },
          ),
        ],
      ),
    );
  }
}
