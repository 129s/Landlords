import 'package:landlords_3/domain/repositories/game_repository.dart';

class JoinRoomParams {
  final String roomId;
  final String playerName;

  JoinRoomParams({required this.roomId, required this.playerName});
}

class JoinRoom {
  final GameRepository _repository;

  JoinRoom(this._repository);

  Future<void> execute(JoinRoomParams params) async {
    return _repository.joinRoom(params.roomId, params.playerName);
  }
}
