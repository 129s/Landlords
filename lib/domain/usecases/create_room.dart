import 'package:landlords_3/domain/repositories/game_repository.dart';

class CreateRoom {
  final GameRepository _repository;

  CreateRoom(this._repository);

  Future<String> execute(String playerName) async {
    return _repository.createRoom(playerName);
  }
}
