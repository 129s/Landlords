import 'dart:async';

import 'package:landlords_3/core/network/event_handler.dart';
import 'package:landlords_3/core/network/socket_manager.dart';
import 'package:landlords_3/data/datasources/remote/dto/message_dto.dart';

class ChatService {
  final SocketManager _socket = SocketManager();
  final _messageStream = StreamController<List<MessageDTO>>.broadcast();

  ChatService() {
    _socket.on('messageUpdate', _MessageEventHandler(_messageStream));
  }

  Stream<List<MessageDTO>> get messages => _messageStream.stream;

  void sendMessage(String roomId, String content) =>
      _socket.emit('sendMessage', {'roomId': roomId, 'content': content});
}

class _MessageEventHandler implements EventHandler<List<MessageDTO>> {
  final StreamController<List<MessageDTO>> _controller;

  _MessageEventHandler(this._controller);

  @override
  List<MessageDTO> convert(dynamic data) =>
      (data as List).map((e) => MessageDTO.fromJson(e)).toList();

  @override
  void handle(dynamic data) => _controller.add(convert(data));
}
