import 'package:landlords_3/data/repositories/game_repository.dart';

class GetGameState {
  final GameRepository repository;

  GetGameState({required this.repository});

  Stream<dynamic> execute() {
    return repository.getGameUpdates();
  }
}
