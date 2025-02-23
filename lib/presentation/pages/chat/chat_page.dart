import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/data/providers/socket_provider.dart';
import 'package:landlords_3/domain/entities/message_model.dart';
import 'package:landlords_3/presentation/pages/chat/MessageBubble.dart';
import 'package:landlords_3/presentation/providers/chat_provider.dart';
import 'package:landlords_3/data/providers/repo_providers.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String roomId;

  const ChatPage({super.key, required this.roomId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _autoScrollEnabled = true;
  bool _userScrolling = false;

  late final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    // 滚动监听
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      // 用户手动滚动时检测位置
      if (_userScrolling) {
        // 距离底部超过70像素时关闭自动滚动
        if ((maxScroll - currentScroll) > 70) {
          setState(() => _autoScrollEnabled = false);
        } else {
          setState(() => _autoScrollEnabled = true);
        }
        _userScrolling = false;
      }
    });
  }

  void _sendMessage() async {
    // 在发送成功后添加滚动控制
    if (_autoScrollEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _focusNode.requestFocus(); // 保持焦点
      return;
    }

    try {
      await ref.read(roomRepoProvider).sendMessage(widget.roomId, text);
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

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider(widget.roomId)).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('房间 ${widget.roomId.substring(0, 6)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // 检测用户滚动行为
                if (notification is UserScrollNotification) {
                  _userScrolling = true;
                }
                return false;
              },
              child: ListView.builder(
                controller: _scrollController,
                // 添加滚动后自动恢复判断
                reverse: false,
                padding: const EdgeInsets.all(8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return MessageBubble(
                    message: message,
                    isMe:
                        message.senderId == ref.read(socketManagerProvider).id,
                  );
                },
              ),
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
