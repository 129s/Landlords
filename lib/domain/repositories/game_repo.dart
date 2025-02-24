import 'package:landlords_3/data/datasources/remote/dto/game_state_dto.dart';
import 'package:landlords_3/domain/entities/poker_model.dart';

abstract class GameRepository {
  Stream<GameStateDTO> watchGameState(String roomId);
  Future<void> startGame();
  Future<void> placeBid(int bidValue);
  Future<void> playCards(List<PokerModel> cards);
  Future<void> passTurn();
}
