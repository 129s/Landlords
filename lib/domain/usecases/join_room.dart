import 'package:landlords_3/data/repositories/game_repository.dart';

class JoinRoom {
  final GameRepository repository;

  JoinRoom({required this.repository});

  Future<void> execute(String roomId, String playerName) async {
    return await repository.joinRoom(roomId, playerName);
  }
}
