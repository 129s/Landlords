import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/data/providers/room_repo_providers.dart';
import 'package:landlords_3/domain/entities/message_model.dart';
import 'package:landlords_3/presentation/providers/chat_provider.dart';

class ChatPage extends ConsumerWidget {
  final String roomId;

  const ChatPage({required this.roomId});

  @override
  Widget build(BuildContext context, ref) {
    final messages = ref.watch(chatMessagesProvider(roomId));

    return Scaffold(
      appBar: AppBar(title: Text('房间 $roomId')),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              data:
                  (list) => ListView.builder(
                    reverse: true,
                    itemCount: list.length,
                    itemBuilder: (ctx, i) => _ChatBubble(message: list[i]),
                  ),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败')),
            ),
          ),
          _ChatInput(roomId: roomId),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final MessageModel message;
  const _ChatBubble({required this.message});

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(child: Text(message.senderName[0])),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.senderName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(message.content),
                Text(
                  message.timestamp.toString(),
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
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
