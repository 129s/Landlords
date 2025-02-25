import 'dart:async';

import 'package:landlords_3/data/models/room.dart';
import 'package:landlords_3/core/network/socket_manager.dart';
import 'package:logger/web.dart';

class RoomService {
  final _socket = SocketManager().socket;
  final _logger = Logger();

  /// 创建并加入房间
  Future<String> createRoom() async {
    final completer = Completer<String>();

    _socket.emit('create_room');
    _socket.once('room_created', (roomId) {
      _logger.d('Room created: $roomId');
      completer.complete(roomId as String);
    });

    return completer.future;
  }

  /// 加入现有房间
  Future<void> joinRoom(String roomId) async {
    final completer = Completer<void>();

    _socket.emit('join_room', {'roomId': roomId});
    _socket.once('player_joined', (_) {
      _logger.d('Joined room: $roomId');
      completer.complete();
    });

    return completer.future;
  }

  /// 实时房间列表流
  Stream<List<Room>> roomStream() {
    final controller = StreamController<List<Room>>();

    _socket.on('room_update', (data) {
      final rooms = (data as List).map((json) => Room.fromJson(json)).toList();
      controller.add(rooms);
    });

    return controller.stream;
  }

  Future<Room> getRoom(String roomId) async {
    final completer = Completer<Room>();
    _socket.emit('get_room', {'roomId': roomId});
    _socket.once('room_info', (data) {
      final room = Room.fromJson(data);
      completer.complete(room);
    });
    return completer.future;
  }

  Future<List<Room>> getRooms() async {
    final completer = Completer<List<Room>>();
    _socket.emit('request_rooms');
    _socket.once('room_update', (data) {
      final rooms = (data as List).map((json) => Room.fromJson(json)).toList();
      completer.complete(rooms);
    });
    return completer.future;
  }

  /// 离开当前房间
  void leaveRoom() {
    _socket.emit('leave_room');
  }
}
