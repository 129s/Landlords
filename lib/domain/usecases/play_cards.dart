import 'package:landlords_3/data/repositories/game_repository.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';

class PlayCards {
  final GameRepository repository;

  PlayCards({required this.repository});

  Future<void> execute(
    List<PokerData> cards,
    String roomId,
    int playerOrder,
  ) async {
    return await repository.playCards(cards, roomId, playerOrder);
  }
}
