import 'dart:async';

import 'package:landlords_3/core/network/constants.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:logger/logger.dart';

/// SocketService 类：
///
/// 单例类，用于管理与服务器的 Socket 连接。
/// 它封装了 socket.io 客户端，并提供了一系列方法来连接、断开连接、发送消息和监听事件。
///
/// 主要功能：
///   - 初始化 Socket 连接，并监听连接、断开连接和错误事件。
///   - 提供连接状态的流，以便其他组件可以监听连接状态的变化。
///   - 提供 emit 方法，用于向服务器发送消息。
///   - 提供 connect 和 disconnect 方法，用于手动连接和断开连接。
///   - 提供 on 和 off 方法，用于注册和取消注册事件监听器。
///
/// 使用方式：
///   - 通过 SocketService() 获取单例实例。
///   - 使用 connect() 方法连接到服务器。
///   - 使用 emit() 方法发送消息。
///   - 使用 on() 方法监听服务器发送的事件。
///   - 使用 disconnect() 方法断开连接。
///   - 通过 connectionStream 监听连接状态的变化。

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
