import 'package:landlords_3/domain/repositories/game_repository.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';

// domain/usecases/play_cards.dart
class PlayCardsParams {
  final List<PokerData> cards;
  final String roomId;
  final int playerOrder;

  PlayCardsParams({
    required this.cards,
    required this.roomId,
    required this.playerOrder,
  });
}

class PlayCards {
  final GameRepository _repository;

  PlayCards(this._repository);

  Future<void> execute(PlayCardsParams params) async {
    return _repository.playCards(
      params.cards,
      params.roomId,
      params.playerOrder,
    );
  }
}
