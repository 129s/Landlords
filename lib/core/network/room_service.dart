import 'dart:async';
import 'package:landlords_3/core/network/socket_manager.dart';
import 'package:landlords_3/data/datasources/remote/dto/room_dto.dart';

class RoomService {
  final _socket = SocketManager();
  final _roomStream = StreamController<List<RoomDTO>>.broadcast();
  final _createController = StreamController<String>();

  RoomService() {
    _socket.on<List<dynamic>>('roomUpdate', (data) {
      _roomStream.add(data.map((e) => RoomDTO.fromJson(e)).toList());
    });

    _socket.on<String>(
      'roomCreated',
      (roomId) => _createController.add(roomId),
    );
  }

  Stream<List<RoomDTO>> get roomUpdates => _roomStream.stream;

  Future<String> createRoom(String name) {
    _socket.emit('createRoom', {'playerName': name, 'socketId': _socket.id});
    return _createController.stream.first;
  }

  void joinRoom(String roomId, String name) =>
      _socket.emit('joinRoom', {'roomId': roomId, 'playerName': name});

  void leaveRoom(String roomId) {
    _socket.emit('leaveRoom', roomId);
    requestRooms(); // 离开房间后自动请求最新房间列表
  }

  void requestRooms() => _socket.emit('requestRooms');
}
