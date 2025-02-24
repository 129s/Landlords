import 'dart:async';

import 'package:landlords_3/core/network/constants.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:logger/logger.dart';

class SocketManager {
  static final _instance = SocketManager._internal();
  late Socket _socket;
  final _logger = Logger();
  var _connectionState = GameConnectionState.disconnected;
  String? _socketId;
  String? get id => _socketId;

  // 连接状态流控制器
  final _connectionController =
      StreamController<GameConnectionState>.broadcast();

  SocketManager._internal() {
    _initSocket();
  }

  factory SocketManager() => _instance;

  void _initSocket() {
    _socket = io(
      'http://localhost:3000',
      OptionBuilder().setTransports(['websocket']).enableAutoConnect().build(),
    );

    _socket.onConnect((_) {
      _socketId = _socket.id;
      _connectionState = GameConnectionState.connected;
      _connectionController.add(_connectionState);
      _logger.i('Socket connected');
    });

    _socket.onDisconnect((_) {
      _connectionState = GameConnectionState.disconnected;
      _connectionController.add(_connectionState);
      _logger.w('Socket disconnected');
    });

    _socket.onError((err) {
      _connectionState = GameConnectionState.error;
      _connectionController.add(_connectionState);
      _logger.e('Socket error: $err');
    });
  }

  // 公共访问方法
  Stream<GameConnectionState> get connectionStream =>
      _connectionController.stream;
  Socket get socket => _socket;
  GameConnectionState get currentState => _connectionState;

  void emit(String event, [dynamic data]) {
    if (_connectionState == GameConnectionState.connected) {
      _socket.emit(event, data);
    }
  }

  void connect() {
    _connectionController.add(GameConnectionState.connecting);
    _socket.connect();
    print('Socket connecting...'); // Log connection attempt
  }

  void on<T>(String event, void Function(T data) handler) =>
      _socket.on(event, (data) => handler(data as T));
  void off(String event) => _socket.off(event);
  void disconnect() {
    _socket.disconnect();
  }
}
