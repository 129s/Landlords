import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/domain/entities/room_model.dart';
import 'package:landlords_3/presentation/providers/lobby_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late io.Socket socket;

  factory SocketService() => _instance;

  SocketService._internal() {
    socket = io.io('http://localhost:3000', {
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
  }

  void joinRoom(String roomId, String playerName) {
    socket.emit('joinRoom', {'roomId': roomId, 'playerName': playerName});
  }

  void createRoom(String playerName) {
    socket.emit('createRoom', playerName);
  }

  void listen(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void requestRooms() => socket.emit('requestRooms');
}
