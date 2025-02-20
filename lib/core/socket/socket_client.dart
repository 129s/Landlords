import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  static final Map<String, IO.Socket> _sockets = {};

  static IO.Socket getSocket(String playerName) {
    if (!_sockets.containsKey(playerName)) {
      final socket = IO.io('http://localhost:3000', {
        'transports': ['websocket'],
        'query': {'playerName': playerName},
        'autoConnect': false,
      });

      socket.on('connect', (_) {
        print('Socket connected for player: $playerName');
      });

      socket.on('disconnect', (_) {
        print('Socket disconnected for player: $playerName');
      });

      _sockets[playerName] = socket;
    }
    return _sockets[playerName]!;
  }

  static void connect(String playerName) {
    final socket = getSocket(playerName);
    if (!socket.connected) {
      socket.connect();
    }
  }

  static void disconnect(String playerName) {
    final socket = getSocket(playerName);
    if (socket.connected) {
      socket.disconnect();
      _sockets.remove(playerName);
    }
  }
}
