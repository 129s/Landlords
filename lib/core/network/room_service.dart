import 'dart:async';
import 'package:landlords_3/core/network/socket_manager.dart';
import 'package:landlords_3/data/models/room.dart';

class RoomService {
  final SocketManager _socket = SocketManager();
  final _roomStream = StreamController<List<Room>>.broadcast();
  final _roomsRequestController = StreamController<List<Room>>.broadcast();
  final _roomCreatedStream = StreamController<String>.broadcast();

  RoomService() {
    _socket.on<List<dynamic>>('room_update', (data) {
      final rooms = data.map((e) => Room.fromJson(e)).toList();
      _roomStream.add(rooms);
      _roomsRequestController.add(rooms);
    });

    _socket.on<List<dynamic>>('room_created', (data) {
      _roomCreatedStream.add(data[0]);
    });
  }

  Stream<List<Room>> get roomUpdates => _roomStream.stream;
  Stream<String> get roomCreated => _roomCreatedStream.stream;

  Future<void> createRoom() async {
    _socket.emit('create_room');
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

  Future<void> requestRooms() async {
    try {
      _socket.emit('request_rooms');
      print("\nHERE\n");
    } catch (e) {
      throw Exception('获取房间列表失败: ${e.toString()}');
    }
  }
}
