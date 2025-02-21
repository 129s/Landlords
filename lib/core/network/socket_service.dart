import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late io.Socket socket;

  factory SocketService() => _instance;

  final StreamController<List<dynamic>> _roomsStreamController =
      StreamController<List<dynamic>>.broadcast();

  Stream<List<dynamic>> get roomsStream => _roomsStreamController.stream;

  SocketService._internal() {
    socket = io.io('http://localhost:3000', {
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.onConnect((_) {
      print('Connected to Socket.IO server');
      requestRooms();
    });

    socket.onDisconnect((_) {
      print('Disconnected from Socket.IO server');
    });

    socket.onError((data) {
      print('Socket.IO Error: $data');
    });

    // 监听 roomUpdate 事件，并将数据添加到 StreamController
    socket.on('roomUpdate', (data) {
      print('Received roomUpdate event: $data');
      _roomsStreamController.add(data as List<dynamic>);
    });

    socket.connect();
  }

  void joinRoom(String roomId, String playerName) {
    socket.emit('joinRoom', {'roomId': roomId, 'playerName': playerName});
  }

  void createRoom(String playerName) {
    socket.emit('createRoom', playerName);
  }

  void requestRooms() => socket.emit('requestRooms');

  void dispose() {
    _roomsStreamController.close();
    socket.disconnect();
  }
}
