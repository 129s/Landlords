import 'dart:async';
import 'package:landlords_3/core/network/socket_manager.dart';
import 'package:landlords_3/data/datasources/remote/dto/player_dto.dart';
import 'package:landlords_3/data/datasources/remote/dto/poker_dto.dart';
import 'package:landlords_3/data/datasources/remote/dto/room_dto.dart';

class RoomService {
  final _socket = SocketManager();
  final _roomStream = StreamController<List<RoomDTO>>.broadcast();
  final _createController = StreamController<String>.broadcast();

  RoomService() {
    _socket.on<List<dynamic>>('roomUpdate', (data) {
      _roomStream.add(data.map((e) => RoomDTO.fromJson(e)).toList());
    });

    _socket.on<String>(
      'roomCreated',
      (roomId) => _createController.add(roomId),
    );

    _socket.on<List<dynamic>>('playerUpdate', (data) {
      _playerUpdateStream.add(data.map((p) => PlayerDTO.fromJson(p)).toList());
    });

    _socket.on<List<dynamic>>('cardsPlayed', (data) {
      _playCardsStream.add(data.map((c) => PokerDTO.fromJson(c)).toList());
    });
  }

  Stream<List<RoomDTO>> get roomUpdates => _roomStream.stream;

  Future<String> createRoom() {
    _socket.emit('createRoom', {'socketId': _socket.id});
    return _createController.stream.first;
  }

  void joinRoom(String roomId) =>
      _socket.emit('joinRoom', {'roomId': roomId, 'socketId': _socket.id});

  void leaveRoom() {
    _socket.emit('leaveRoom');
    requestRooms(); // 离开房间后自动请求最新房间列表
  }

  void requestRooms() => _socket.emit('requestRooms');

  final _playerUpdateStream = StreamController<List<PlayerDTO>>.broadcast();
  final _playCardsStream = StreamController<List<PokerDTO>>.broadcast();

  Stream<List<PlayerDTO>> get playerUpdateStream => _playerUpdateStream.stream;
  Stream<List<PokerDTO>> get playCardsStream => _playCardsStream.stream;

  void requestRoomDetails(String roomId) {
    _socket.emit('requestRoomDetails', {'roomId': roomId});
  }

  void emitPlayCards(String roomId, List<PokerDTO> cards) {
    _socket.emit('playCards', {
      'roomId': roomId,
      'cards': cards.map((c) => c.toJson()).toList(),
    });
  }
}
