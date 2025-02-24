import 'dart:async';
import 'package:landlords_3/core/network/socket_manager.dart';
import 'package:landlords_3/data/models/room.dart';
import 'package:landlords_3/data/models/player.dart';

class RoomService {
  final SocketManager _socket = SocketManager();
  final _roomStream = StreamController<List<Room>>.broadcast();
  final _playerUpdateStream = StreamController<List<Player>>.broadcast();
  final _roomsRequestController = StreamController<List<Room>>.broadcast();

  RoomService() {
    _socket.on<List<dynamic>>('room_update', (data) {});

    _socket.on<List<dynamic>>('player_update', (data) {});
  }

  Stream<List<Room>> get roomUpdates => _roomStream.stream;
  Stream<List<Player>> get playerUpdates => _playerUpdateStream.stream;

  Future<String> createRoom() async {
    final completer = Completer<String>();
    _socket.emit('room_created', (roomId) => completer.complete(roomId));
    _socket.emit('create_room');
    return completer.future;
  }

  Future<void> joinRoom(String roomId) async {
    _socket.emit('join_room', {'roomId': roomId});
  }

  Future<void> leaveRoom() async {
    _socket.emit('leave_room');
  }

  Stream<List<Room>> watchRooms() {
    _socket.emit('request_rooms');
    return _roomsRequestController.stream;
  }

  Future<Room> getRoomDetails(String roomId) async {
    final completer = Completer<Room>();

    _socket.emitWithAck('get_room_details', {'roomId': roomId}, (response) {
      if (response['success']) {
        // 解析房间数据
        final players =
            (response['room']['players'] as List)
                .map(
                  (p) => Player(
                    id: p['id'],
                    name: p['name'],
                    seat: p['seat'],
                    isLandlord: p['isLandlord'],
                  ),
                )
                .toList();

        completer.complete(
          Room(
            id: response['room']['id'],
            players: players,
            createdAt: DateTime.parse(response['room']['createdAt']),
          ),
        );
      } else {
        completer.completeError(Exception(response['error']));
      }
    });

    return completer.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () => throw TimeoutException('房间详情请求超时'),
    );
  }

  Future<List<Room>> requestRooms() async {
    final completer = Completer<List<Room>>();

    _socket.emitWithAck('request_rooms', null, (response) {
      if (response['success']) {
        final rooms =
            (response['rooms'] as List).map((r) => _parseRoom(r)).toList();
        completer.complete(rooms);
      } else {
        completer.completeError(Exception(response['error']));
      }
    });

    return completer.future;
  }
}
