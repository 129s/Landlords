import 'dart:async';
import 'package:landlords_3/core/network/socket_manager.dart';
import 'package:landlords_3/data/models/message.dart';

class ChatService {
  final SocketManager _socket = SocketManager();
  final _messageStream = StreamController<List<Message>>.broadcast();
  List<Message> _currentMessages = []; // 当前消息缓存

  ChatService() {}

  Stream<List<Message>> watchMessages(String roomId) {
    // 初始化时清空缓存
    _currentMessages = [];
    _socket.on<List<dynamic>>('message_history', (data) {
      final messages = data.map((e) => Message.fromJson(e)).toList();
      _currentMessages = messages; // 更新缓存
      _messageStream.add(messages);
    });

    _socket.on<Map<String, dynamic>>('new_message', (message) {
      final newMessage = Message.fromJson(message);
      _currentMessages = [..._currentMessages, newMessage];
      _messageStream.add(_currentMessages);
    });

    _socket.emit('request_messages', {'roomId': roomId});
    return _messageStream.stream;
  }

  Future<void> sendMessage(String roomId, String content) async {
    try {
      final message = {
        'roomId': roomId,
        'content': content,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      _socket.emit('send_message', message);
    } catch (e) {
      throw Exception('消息发送失败: ${e.toString()}');
    }
  }
}
