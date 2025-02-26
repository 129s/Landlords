import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/data/providers/socket_provider.dart';
import 'package:landlords_3/data/models/message.dart';
import 'package:landlords_3/presentation/pages/chat/MessageBubble.dart';
import 'package:landlords_3/presentation/providers/chat_provider.dart';
import 'package:landlords_3/data/providers/service_providers.dart';
import 'package:landlords_3/presentation/providers/lobby_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String roomId;

  const ChatPage({super.key, required this.roomId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isUserScrolling = false;
  bool _isMyLastMessage = false;

  late final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    // 滚动监听器
    _scrollController.addListener(() {
      // 当用户手动滚动时更新状态
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        _isUserScrolling = true;
      }
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _focusNode.requestFocus(); // 保持焦点
      return;
    }

    try {
      await ref
          .read(chatServiceProvider)
          .sendMessage(text)
          .then((_) => _roll());
      _isUserScrolling = false;
      _controller.clear();
      _focusNode.requestFocus();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('发送失败: ${e.toString()}')));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _roll() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
    _isMyLastMessage = false;
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider(widget.roomId)).value ?? [];
    // 在 build 方法中添加消息监听
    final messagesAsync = ref.watch(chatProvider(widget.roomId));
    messagesAsync.when(
      data: (messages) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isUserScrolling && !_isMyLastMessage) return;
          _roll();
        });
      },
      loading: () {},
      error: (error, _) {},
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('房间 ${widget.roomId.substring(0, 6)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              ref.read(lobbyProvider.notifier).leaveRoom();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageBubble(
                  message: message,
                  isMe:
                      message.senderId ==
                      ref.read(socketManagerProvider).socket.id,
                );
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '输入消息...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
