import 'dart:async';

import 'package:landlords_3/core/network/constants.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:logger/logger.dart';

class SocketService {
  final _logger = Logger();
  late Socket _socket;
  GameConnectionState _connectionState = GameConnectionState.disconnected;

  // 流控制
  final _connectionController =
      StreamController<GameConnectionState>.broadcast();

  // get
  Stream<GameConnectionState> get connectionStream =>
      _connectionController.stream;
  Socket get socket => _socket;

  // 单例
  static final _instance = SocketService._internal();
  SocketService._internal() {
    _initSocket();
  }
  factory SocketService() => _instance;

  // 初始化
  void _initSocket() {
    _socket = io(
      'http://localhost:3000',
      OptionBuilder().setTransports(['websocket']).enableAutoConnect().build(),
    );

    _socket.onConnect((_) {
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

  void emit(String event, [dynamic data]) {
    if (_connectionState == GameConnectionState.connected) {
      _socket.emit(event, data);
    }
    _logger.i('Socket emit event: $event');
  }

  void connect() {
    _connectionController.add(GameConnectionState.connecting);
    _socket.connect();
    _logger.i('Socket connecting...');
  }

  void disconnect() {
    _socket.disconnect();
  }

  void on<T>(String event, void Function(T data) handler) =>
      _socket.on(event, (data) => handler(data as T));
  void off(String event) => _socket.off(event);
}
