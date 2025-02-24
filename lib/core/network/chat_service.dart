import 'dart:async';
import 'package:landlords_3/core/network/socket_manager.dart';
import 'package:landlords_3/data/transform/message_dto.dart';

class ChatService {
  final SocketManager _socket = SocketManager();
  final _messageStream = StreamController<List<MessageDTO>>.broadcast();
  final _messageHistoryRequests = <String, Completer<List<MessageDTO>>>{};

  ChatService() {
    _socket.on<List<dynamic>>('new_message', (data) {
      _messageStream.add(data.map((e) => MessageDTO.fromJson(e)).toList());
    });

    _socket.on<List<dynamic>>('message_history', (data) {
      final roomId = data.isNotEmpty ? data[0]['roomId'] : '';
      final completer = _messageHistoryRequests[roomId];
      if (completer != null && !completer.isCompleted) {
        completer.complete(data.map((e) => MessageDTO.fromJson(e)).toList());
      }
    });
  }

  Stream<List<MessageDTO>> watchMessages(String roomId) {
    return _messageStream.stream
        .where((messages) => messages.any((m) => m.roomId == roomId))
        .map(
          (allMessages) =>
              allMessages.where((m) => m.roomId == roomId).toList(),
        );
  }

  Future<void> sendMessage(String roomId, String content) async {
    final completer = Completer<void>();
    final payload = {
      'roomId': roomId,
      'content': content,
      'socketId': _socket.id,
    };

    _socket.emitWithAck('send_message', payload, (response) {
      if (response['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(response['error']));
      }
    });

    return completer.future;
  }
}
