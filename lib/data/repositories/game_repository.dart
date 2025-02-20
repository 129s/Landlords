// 仓库接口
import 'package:landlords_3/domain/entities/poker_data.dart';

abstract class GameRepository {
  Future<String> createRoom(String playerName);
  Future<void> joinRoom(String roomId, String playerName);
  Future<int> getPlayerOrder();
  Future<void> playCards(List<PokerData> cards, String roomId, int playerOrder);
  Stream<dynamic> getGameUpdates();
  Stream<dynamic> getTurnUpdates();
  Stream<dynamic> getPlayerJoinedUpdates();
  Stream<dynamic> getGameActions();
}
