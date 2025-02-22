import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:landlords_3/presentation/providers/user_provider.dart'; // Import user provider
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GameConnectionState { connecting, connected, disconnected, error }

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late io.Socket socket;
  String? _userId; // Store userId

  factory SocketService() => _instance;

  final StreamController<List<dynamic>> _roomsStreamController =
      StreamController<List<dynamic>>.broadcast();

  Stream<List<dynamic>> get roomsStream => _roomsStreamController.stream;

  final StreamController<GameConnectionState> _connectionController =
      StreamController<GameConnectionState>.broadcast();

  Stream<GameConnectionState> get connectionStream =>
      _connectionController.stream;

  SocketService._internal() {
    _connect();
  }

  void _connect() {
    // 立即发出 connecting 状态
    _connectionController.add(GameConnectionState.connecting);

    socket = io.io('http://localhost:3000', {
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'userId': _userId}, // Send userId on connect
    });

    // 添加连接超时机制
    Timer(const Duration(seconds: 5), () {
      if (socket.disconnected &&
          _connectionController.hasListener &&
          _connectionController.isClosed == false) {
        _connectionController.add(GameConnectionState.error);
      }
    });

    socket.onConnect((_) {
      _connectionController.add(GameConnectionState.connected);
    });

    socket.onDisconnect((_) {
      _connectionController.add(GameConnectionState.disconnected);
    });

    socket.onError((data) {
      _connectionController.add(GameConnectionState.error);
    });

    // 监听 roomUpdate 事件，并将数据添加到 StreamController
    socket.on('roomUpdate', (data) {
      print('Received roomUpdate event: $data');
      _roomsStreamController.add(data as List<dynamic>);
    });

    socket.connect();
  }

  void joinRoom({required String roomId, required String userId}) {
    socket.emit('joinRoom', {'roomId': roomId, 'userId': userId});
  }

  void createRoom({required String roomName, required String userId}) {
    socket.emit('createRoom', {'roomName': roomName, 'userId': userId});
  }

  void requestRooms() => socket.emit('requestRooms');

  void dispose() {
    _roomsStreamController.close();
    //  socket.disconnect(); // 注释掉，保持连接尝试
  }

  // 添加重连方法
  void reconnect() {
    // 确保先断开之前的连接
    socket.disconnect();
    // 重新连接
    _connect();
  }

  // Set userId
  void setUserId(String userId) {
    _userId = userId;
  }
}
