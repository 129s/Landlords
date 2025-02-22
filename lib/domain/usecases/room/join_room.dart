import 'package:landlords_3/domain/repositories/room_repo.dart';

class JoinRoom {
  final RoomRepository repository;

  JoinRoom(this.repository);

  Future<void> call(String roomId, String playerName) async {
    return repository.joinRoom(roomId);
  }
}
