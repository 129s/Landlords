// data/repositories/room_repo_impl.dart
import 'package:landlords_3/core/network/socket_service.dart';
import 'package:landlords_3/data/datasources/remote/dto/room_dto.dart';
import 'package:landlords_3/domain/entities/room_model.dart';
import 'package:landlords_3/domain/repositories/room_repo.dart';
import 'package:landlords_3/presentation/providers/user_provider.dart'; // Import user provider
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoomRepoImpl implements RoomRepository {
  final SocketService _socket = SocketService();
  final Ref ref;

  RoomRepoImpl(this.ref); // Inject Ref

  @override
  Future<void> createRoom(String roomName) async {
    final user = ref.read(userProvider); // Get user from provider
    if (user == null) {
      throw Exception('用户未登录');
    }
    _socket.createRoom(
      roomName: roomName,
      userId: user.id,
    ); // Send roomName and userId
  }

  @override
  Future<void> joinRoom(String roomId) async {
    final user = ref.read(userProvider); // Get user from provider
    if (user == null) {
      throw Exception('用户未登录');
    }
    _socket.joinRoom(roomId: roomId, userId: user.id); // Send roomId and userId
  }

  @override
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
