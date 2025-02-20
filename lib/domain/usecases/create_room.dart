import 'package:landlords_3/data/repositories/game_repository.dart';

class CreateRoom {
  final GameRepository repository;

  CreateRoom({required this.repository});

  Future<String> execute(String playerName) async {
    return await repository.createRoom(playerName);
  }
}
