import 'package:landlords_3/data/models/poker_model.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';

abstract class GameRemoteDataSource {
  Future<String> createRoom(String playerName);
  Future<void> joinRoom(String roomId, String playerName);
  Future<void> playCards(
    List<PokerModel> cards,
    String roomId,
    int playerOrder,
  );

  Stream<dynamic> getGameUpdates();
  Future<int> getPlayerOrder();
}
