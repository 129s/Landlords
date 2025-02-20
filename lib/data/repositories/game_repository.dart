import 'package:landlords_3/domain/entities/poker_data.dart';

abstract class GameRepository {
  Future<String> createRoom(String playerName);
  Future<void> joinRoom(String roomId, String playerName);
  Stream<dynamic> getGameUpdates();
  Future<int> getPlayerOrder();
  Future<void> playCards(List<PokerData> cards, String roomId, int playerOrder);
}
