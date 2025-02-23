import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;

enum GameConnectionState { connecting, connected, disconnected, error }

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();

  late io.Socket _socket;
  String? _socketId;

  String? get id => _socketId;

  final _connectionController =
      StreamController<GameConnectionState>.broadcast();

  factory SocketManager() => _instance;

  SocketManager._internal() {
    _socket = io.io('http://localhost:3000', {
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.onConnect((_) {
      _socketId = _socket.id;
      _connectionController.add(GameConnectionState.connected);
      print('Socket connected with ID: $_socketId'); // Log connection
    });

    _socket.onDisconnect((_) {
      _connectionController.add(GameConnectionState.disconnected);
      print('Socket disconnected'); // Log disconnection
    });

    _socket.onError((err) {
      print('Socket error: $err'); // Log error
      _connectionController.addError(err);
    });
  }

  Stream<GameConnectionState> get connectionStream =>
      _connectionController.stream;

  void connect() {
    _connectionController.add(GameConnectionState.connecting);
    _socket.connect();
    print('Socket connecting...'); // Log connection attempt
  }

  void emit(String event, [dynamic data]) => _socket.emit(event, data);
  void on<T>(String event, void Function(T data) handler) =>
      _socket.on(event, (data) => handler(data as T));
  void off(String event) => _socket.off(event);
}
