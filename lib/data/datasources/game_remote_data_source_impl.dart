import 'dart:async';
import 'package:landlords_3/core/socket/socket_client.dart';
import 'package:landlords_3/data/datasources/game_remote_data_source.dart';
import 'package:landlords_3/data/models/poker_model.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final String playerName;
  late IO.Socket _socket;

  GameRemoteDataSourceImpl({required this.playerName}) {
    _socket = SocketClient.getSocket(playerName);
    _socket.connect();
  }

  @override
  Future<String> createRoom(String playerName) async {
    final completer = Completer<String>();
    _socket.emitWithAck(
      'createRoom',
      playerName,
      ack: (roomId) {
        completer.complete(roomId);
      },
    );
    return completer.future;
  }

  @override
  Future<void> joinRoom(String roomId, String playerName) async {
    _socket.emit('joinRoom', {'roomId': roomId, 'playerName': playerName});
  }

  @override
  Stream<dynamic> getGameUpdates() {
    final controller = StreamController<dynamic>();
    _socket.on('gameUpdate', (data) => controller.add(data));
    return controller.stream;
  }

  @override
  Future<void> playCards(
    List<PokerModel> cards,
    String roomId,
    int playerOrder,
  ) {
    final cardMaps = cards.map((c) => c.toJson()).toList();
    _socket.emitWithAck(
      'gameAction',
      {
        'type': 'playCards',
        'cards': cardMaps,
        'roomId': roomId,
        'playerOrder': playerOrder,
      },
      ack: (response) {
        if (response['status'] != 'success') {
          throw Exception(response['error'] ?? '出牌失败');
        }
      },
    );
    return Future.value();
  }

  @override
  Future<int> getPlayerOrder() async {
    final completer = Completer<int>();
    _socket.once('playerOrder', (order) => completer.complete(order));
    return completer.future;
  }
}
