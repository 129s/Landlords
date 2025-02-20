import 'package:landlords_3/core/socket/socket_client.dart';
import 'package:landlords_3/data/datasources/game_remote_data_source.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final String playerName;

  GameRemoteDataSourceImpl({required this.playerName});

  IO.Socket get socket => SocketClient.getSocket(playerName);

  @override
  Future<String> createRoom(String playerName) async {
    final completer = Completer<String>();
    socket.emit('createRoom', playerName);
    socket.once('roomCreated', (roomId) {
      completer.complete(roomId);
    });
    return completer.future;
  }

  @override
  Future<void> joinRoom(String roomId, String playerName) async {
    socket.emit('joinRoom', {'roomId': roomId, 'playerName': playerName});
  }

  @override
  Future<int> getPlayerOrder() async {
    final completer = Completer<int>();
    socket.emit('getPlayerOrder', (order) {
      completer.complete(order);
    });
    return completer.future;
  }

  @override
  Future<void> sendGameAction(Map<String, dynamic> action) async {
    socket.emit('gameAction', action);
  }

  @override
  Stream<dynamic> getGameUpdates() {
    return socket.on('gameUpdate');
  }

  @override
  Stream<dynamic> getTurnUpdates() {
    return socket.on('TURN_UPDATE');
  }

  @override
  Stream<dynamic> getPlayerJoinedUpdates() {
    return socket.on('playerJoined');
  }

  @override
  Stream<dynamic> getGameActions() {
    return socket.on('gameAction');
  }
}
