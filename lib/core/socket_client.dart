import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  static IO.Socket? _socket;

  static IO.Socket get socket {
    _socket ??= IO.io('http://localhost:3000', {
      'transports': ['websocket'],
      'autoConnect': false,
    });
    return _socket!;
  }

  static void connect() {
    if (!_socket!.connected) {
      _socket!.connect();
    }
  }
}
