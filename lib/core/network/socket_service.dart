import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;

enum GameConnectionState { connecting, connected, disconnected, error }

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late io.Socket socket;

  factory SocketService() => _instance;

  final StreamController<List<dynamic>> _roomsStreamController =
      StreamController<List<dynamic>>.broadcast();
  Stream<List<dynamic>> get roomsStream => _roomsStreamController.stream;

  final StreamController<GameConnectionState> _connectionController =
      StreamController<GameConnectionState>.broadcast();
  Stream<GameConnectionState> get connectionStream =>
      _connectionController.stream;

  final StreamController<List<dynamic>> _messageController =
      StreamController.broadcast();
  Stream<List<dynamic>> get messageStream => _messageController.stream;

  final StreamController<String> _roomCreatedController =
      StreamController<String>.broadcast();
  Stream<String> get roomCreatedStream => _roomCreatedController.stream;

  SocketService._internal() {
    _connect();
  }

  void _connect() {
    // 立即发出 connecting 状态
    _connectionController.add(GameConnectionState.connecting);

    socket = io.io('http://localhost:3000', {
      'transports': ['websocket'],
      'autoConnect': false,
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

    socket.on('roomCreated', (roomId) {
      print('Room created with ID: $roomId');
      _roomCreatedController.add(roomId as String);
    });

    socket.on('messageUpdate', (data) {
      print('Received message: $data');
      _messageController.add(data as List<dynamic>);
    });

    socket.connect();
  }

  void joinRoom(String roomId, String playerName) {
    socket.emit('joinRoom', {'roomId': roomId, 'playerName': playerName});
  }

  void createRoom(String playerName) {
    socket.emit('createRoom', playerName);
  }

  void leaveRoom(String roomId) {
    socket.emit('leaveRoom', roomId);
    socket.emit('room:request'); // 主动请求最新房间列表
    _roomsStreamController.add([]); // 清空旧数据
  }

  void requestRooms() => socket.emit('requestRooms');

  void dispose() {
    _roomsStreamController.close();
    //  socket.disconnect(); // 保持连接尝试
  }

  // 添加重连方法
  void reconnect() {
    // 确保先断开之前的连接
    socket.disconnect();
    // 重新连接
    _connect();
  }

  void sendChatMessage(String roomId, String message) {
    socket.emit('sendMessage', {'roomId': roomId, 'content': message});
  }
}
