import 'package:landlords_3/data/repositories/game_repository.dart';

class GetPlayerOrder {
  final GameRepository repository;

  GetPlayerOrder({required this.repository});

  Future<int> execute() async {
    return await repository.getPlayerOrder();
  }
}
