import 'package:landlords_3/core/network/socket_service.dart';
import 'package:landlords_3/data/datasources/remote/dto/room_dto.dart';
import 'package:landlords_3/domain/entities/room_model.dart';
import 'package:landlords_3/domain/repositories/room_repo.dart';

class RoomRepoImpl implements RoomRepository {
  final SocketService _socket = SocketService();

  @override
  Future<void> createRoom(String playerName) async {
    _socket.createRoom(playerName);
  }

  @override
  Future<void> joinRoom(String roomId, String playerName) async {
    _socket.joinRoom(roomId, playerName);
  }

  Stream<List<RoomModel>> watchRooms() {
    return _socket.roomsStream.map(
      (data) =>
          (data)
              .map((e) => RoomDTO.fromJson(e as Map<String, dynamic>))
              .cast<RoomModel>()
              .toList(),
    );
  }
}
