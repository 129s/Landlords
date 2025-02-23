import 'dart:async';
import 'package:landlords_3/core/network/event_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

enum GameConnectionState { connecting, connected, disconnected, error }

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  late io.Socket _socket;
  final _connectionStream = StreamController<GameConnectionState>.broadcast();

  factory SocketManager() => _instance;

  SocketManager._internal() {
    _socket = io.io('http://localhost:3000', {
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _setupEventListeners();
  }

  Stream<GameConnectionState> get connectionStream => _connectionStream.stream;

  void _setupEventListeners() {
    _socket.onConnect(
      (_) => _connectionStream.add(GameConnectionState.connected),
    );
    _socket.onDisconnect(
      (_) => _connectionStream.add(GameConnectionState.disconnected),
    );
    _socket.onError((err) => _connectionStream.add(GameConnectionState.error));
  }

  void connect() {
    _connectionStream.add(GameConnectionState.connecting);
    _socket.connect();

    Timer(const Duration(seconds: 5), () {
      if (_socket.disconnected) {
        _connectionStream.add(GameConnectionState.error);
      }
    });
  }

  void disconnect() => _socket.disconnect();
  void emit(String event, [dynamic data]) => _socket.emit(event, data);
  void on<T>(String event, EventHandler<T> handler) =>
      _socket.on(event, (data) => handler.handle(data));

  void reconnect() {
    disconnect();
    connect();
  }
}
