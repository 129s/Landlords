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

    _socket.on<List<dynamic>>('room_update', (data) {
      final rooms = data.map((e) => Room.fromJson(e)).toList();
      _roomStream.add(rooms);
      _roomsRequestController.add(rooms);
    });

    _socket.on<List<dynamic>>('player_update', (data) {
      final players = data.map((e) => Player.fromJson(e)).toList();
      _playerUpdateStream.add(players);
    });
  }

  Stream<List<Room>> get roomUpdates => _roomStream.stream;
  Stream<List<Player>> get playerUpdates => _playerUpdateStream.stream;

  Future<String> createRoom() async {
    try {
      final completer = Completer<String>();
      _socket.emitWithAck('create_room', null, (ack) {
        if (ack['success']) {
          completer.complete(ack['roomId']);
        } else {
          completer.completeError(ack['error']);
        }
      });
      return completer.future;
    } catch (e) {
      throw Exception('房间创建失败: ${e.toString()}');
    }
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
    try {
      final completer = Completer<Room>();
      _socket.emitWithAck('get_room_details', {'roomId': roomId}, (ack) {
        if (ack['success']) {
          completer.complete(Room.fromJson(ack['room']));
        } else {
          completer.completeError(ack['error']);
        }
      });
      return completer.future;
    } catch (e) {
      throw Exception('获取房间详情失败: ${e.toString()}');
    }
  }

  Future<List<Room>> requestRooms() async {
    try {
      final completer = Completer<List<Room>>();
      _socket.emitWithAck('request_rooms', null, (ack) {
        final rooms = (ack as List).map((e) => Room.fromJson(e)).toList();
        completer.complete(rooms);
      });
      return completer.future;
    } catch (e) {
      throw Exception('获取房间列表失败: ${e.toString()}');
    }
  }
}
