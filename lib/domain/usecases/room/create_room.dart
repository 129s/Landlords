import 'package:landlords_3/domain/repositories/room_repo.dart';

class CreateRoom {
  final RoomRepository repository;

  CreateRoom(this.repository);

  Future<void> call(String playerName) async {
    return repository.createRoom(playerName);
  }
}
