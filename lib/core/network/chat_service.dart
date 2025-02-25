import 'dart:async';

import 'package:landlords_3/data/models/message.dart';
import 'package:landlords_3/core/network/socket_manager.dart';

class ChatService {
  final _socket = SocketManager().socket;

  /// 发送聊天消息
  Future<void> sendMessage(String content) {
    final completer = Completer<void>();
    _socket.emitWithAck(
      'send_message',
      {'content': content},
      ack: (response) {
        if (response['status'] == 'success') {
          completer.complete();
        } else {
          completer.completeError(response['error']);
        }
      },
    );
    return completer.future;
  }

  /// 消息历史流
  Stream<List<Message>> messageStream(String roomId) {
    final controller = StreamController<List<Message>>();

    _socket.on('message_history', (data) {
      final messages =
          (data as List).map((json) => Message.fromJson(json)).toList();
      controller.add(messages);
    });

    _socket.on('new_message', (data) {
      final message = Message.fromJson(data);
      controller.add([message]);
    });

    return controller.stream;
  }
}
