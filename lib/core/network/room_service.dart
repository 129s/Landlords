import 'dart:async';

import 'package:landlords_3/core/network/event_handler.dart';
import 'package:landlords_3/core/network/socket_manager.dart';
import 'package:landlords_3/data/datasources/remote/dto/room_dto.dart';

class RoomService {
  final SocketManager _socket = SocketManager();
  final _roomStream = StreamController<List<RoomDTO>>.broadcast();

  RoomService() {
    _socket.on('roomUpdate', _RoomEventHandler(_roomStream));
    _socket.on('roomCreated', _RoomCreatedHandler());
  }

  Stream<List<RoomDTO>> get roomUpdates => _roomStream.stream;

  void createRoom(String playerName) => _socket.emit('createRoom', playerName);

  void joinRoom(String roomId, String playerName) =>
      _socket.emit('joinRoom', {'roomId': roomId, 'playerName': playerName});

  void requestRooms() => _socket.emit('requestRooms');
}

class _RoomEventHandler implements EventHandler<List<RoomDTO>> {
  final StreamController<List<RoomDTO>> _controller;

  _RoomEventHandler(this._controller);

  @override
  List<RoomDTO> convert(dynamic data) =>
      (data as List).map((e) => RoomDTO.fromJson(e)).toList();

  @override
  void handle(dynamic data) => _controller.add(convert(data));
}

class _RoomCreatedHandler implements EventHandler<String> {
  @override
  String convert(dynamic data) => data as String;

  @override
  void handle(dynamic data) => SocketManager().emit('room:join', convert(data));
}
