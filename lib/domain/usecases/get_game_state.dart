import 'package:landlords_3/domain/repositories/game_repository.dart';

class GetGameState {
  final GameRepository _repository;

  GetGameState(this._repository);

  Stream<dynamic> execute() {
    return _repository.getGameUpdates();
  }
}
