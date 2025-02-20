import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  static final Map<String, IO.Socket> _sockets = {};
  static final Map<String, List<Function(bool)>> _connectionListeners = {};
  static final Map<String, List<Function(dynamic)>> _errorListeners = {};

  static IO.Socket getSocket(String playerName) {
    if (!_sockets.containsKey(playerName)) {
      final socket = IO.io('http://localhost:3000', {
        'transports': ['websocket'],
        'query': {'playerName': playerName},
        'autoConnect': false,
      });

      _sockets[playerName] = socket;

      // 初始状态设置为断开
      _notifyConnectionListeners(playerName, false);

      socket.on('connect', (_) {
        print('Socket connected for player: $playerName');
        _notifyConnectionListeners(playerName, true);
      });

      socket.on('disconnect', (_) {
        print('Socket disconnected for player: $playerName');
        _notifyConnectionListeners(playerName, false);
      });

      socket.on('connect_error', (err) {
        print('Socket connect_error for player: $playerName: $err');
        _notifyErrorListeners(playerName, err);
      });

      socket.on('error', (err) {
        print('Socket error for player: $playerName: $err');
        _notifyErrorListeners(playerName, err);
      });
    }
    return _sockets[playerName]!;
  }

  // 添加重连次数限制
  static void connect(String playerName) {
    if (_sockets[playerName]?.connected ?? false) return;
    _sockets[playerName]?.connect();
    _sockets[playerName]?.onDisconnect(
      (_) => _clearSocketAfterDelay(playerName),
    );
  }

  static void _clearSocketAfterDelay(String playerName) {
    Timer(Duration(seconds: 30), () {
      if (!(_sockets[playerName]?.connected ?? true)) {
        _sockets.remove(playerName);
      }
    });
  }

  static void disconnect(String playerName) {
    final socket = getSocket(playerName);
    if (socket.connected) {
      socket.disconnect();
      _sockets.remove(playerName);
      _connectionListeners.remove(playerName);
      _errorListeners.remove(playerName);
    }
  }

  // 添加连接状态监听
  static void addConnectionListener(
    String playerName,
    void Function(bool) listener,
  ) {
    if (!_connectionListeners.containsKey(playerName)) {
      _connectionListeners[playerName] = [];
    }
    _connectionListeners[playerName]!.add(listener);

    // 立即通知一次当前状态
    final socket = _sockets[playerName];
    if (socket != null) {
      listener(socket.connected);
    }
  }

  // 添加错误监听
  static void addErrorListener(
    String playerName,
    void Function(dynamic) listener,
  ) {
    if (!_errorListeners.containsKey(playerName)) {
      _errorListeners[playerName] = [];
    }
    _errorListeners[playerName]!.add(listener);
  }

  // 通知连接状态监听器
  static void _notifyConnectionListeners(String playerName, bool isConnected) {
    if (_connectionListeners.containsKey(playerName)) {
      for (final listener in _connectionListeners[playerName]!) {
        listener(isConnected);
      }
    }
  }

  // 通知错误监听器
  static void _notifyErrorListeners(String playerName, dynamic error) {
    if (_errorListeners.containsKey(playerName)) {
      for (final listener in _errorListeners[playerName]!) {
        listener(error);
      }
    }
  }
}
