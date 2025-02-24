import 'dart:async';
import 'package:landlords_3/core/network/socket_manager.dart';
import 'package:landlords_3/data/datasources/remote/dto/message_dto.dart';

class ChatService {
  final SocketManager _socket = SocketManager();
  final _messageStream = StreamController<List<MessageDTO>>.broadcast();

  ChatService() {
    _socket.on<List<dynamic>>('messageUpdate', (data) {
      _messageStream.add((data).map((e) => MessageDTO.fromJson(e)).toList());
    });
  }

  Stream<List<MessageDTO>> get messages => _messageStream.stream;

  void sendMessage(String roomId, String content) {
    final payload = {
      'roomId': roomId,
      'content': content,
      'socketId': _socket.id,
    };
    _socket.emit('send_message', payload);
  }
}
