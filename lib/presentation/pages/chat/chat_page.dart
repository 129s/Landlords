import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/data/providers/repo_providers.dart';
import 'package:landlords_3/domain/entities/message_model.dart';
import 'package:landlords_3/presentation/providers/chat_provider.dart';
import 'package:intl/intl.dart';
import 'package:landlords_3/presentation/providers/lobby_provider.dart';

class ChatPage extends ConsumerWidget {
  final String roomId;
  const ChatPage({required this.roomId});

  @override
  Widget build(BuildContext context, ref) {
    final messages = ref.watch(chatProvider(roomId));
    final currentPlayer = ref.watch(lobbyProvider.select((s) => s.playerName));

    return Scaffold(
      appBar: AppBar(
        title: Text('房间 $roomId'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _exitRoom(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              data: (list) {
                if (list.isEmpty) return _buildEmptyState(context);
                return ListView.builder(
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder:
                      (ctx, i) => _ChatBubble(
                        message: list[list.length - 1 - i],
                        isCurrentUser:
                            list[list.length - 1 - i].senderName ==
                            currentPlayer,
                      ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, _) => _buildErrorState(ref, e),
            ),
          ),
          _ChatInput(roomId: roomId),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) => Center(
    child: Text(
      '暂无消息，输入第一条消息吧！',
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
    ),
  );

  Widget _buildErrorState(WidgetRef ref, dynamic error) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text('消息加载失败: ${error.toString()}'),
      ElevatedButton(
        onPressed: () => ref.refresh(chatProvider(roomId)),
        child: const Text('重试'),
      ),
    ],
  );

  void _exitRoom(BuildContext context, WidgetRef ref) {
    ref.read(roomRepoProvider).leaveRoom(roomId).then((_) {
      ref.read(lobbyProvider.notifier).exitGame();
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }
}

class _ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;

  const _ChatBubble({required this.message, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isCurrentUser) ...[
              CircleAvatar(child: Text(message.senderName.substring(0, 1))),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isCurrentUser
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: Radius.circular(isCurrentUser ? 12 : 0),
                    bottomRight: Radius.circular(isCurrentUser ? 0 : 12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    if (!isCurrentUser)
                      Text(
                        message.senderName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    Text(message.content),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(message.timestamp.toLocal()),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isCurrentUser) ...[
              const SizedBox(width: 8),
              CircleAvatar(child: Text(message.senderName.substring(0, 1))),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends ConsumerWidget {
  final String roomId;
  final controller = TextEditingController();

  _ChatInput({required this.roomId});

  void _sendMessage(WidgetRef ref) {
    if (controller.text.isNotEmpty) {
      ref.read(roomRepoProvider).sendMessage(roomId, controller.text);
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context, ref) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '输入消息...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendMessage(ref),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () => _sendMessage(ref),
          ),
        ],
      ),
    );
  }
}
