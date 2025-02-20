import 'package:landlords_3/data/datasources/game_remote_data_source.dart';
import 'package:landlords_3/data/models/poker_model.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';
import 'package:landlords_3/data/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  final GameRemoteDataSource remoteDataSource;

  GameRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> createRoom(String playerName) async {
    return await remoteDataSource.createRoom(playerName);
  }

  @override
  Future<void> joinRoom(String roomId, String playerName) async {
    await remoteDataSource.joinRoom(roomId, playerName);
  }

  @override
  Future<int> getPlayerOrder() async {
    return await remoteDataSource.getPlayerOrder();
  }

  @override
  Future<void> playCards(
    List<PokerData> cards,
    String roomId,
    int playerOrder,
  ) async {
    final cardMaps =
        cards.map((card) => (card as PokerModel).toJson()).toList();
    final action = {
      'type': 'PLAY_CARDS',
      'cards': cardMaps,
      'roomId': roomId,
      'playerOrder': playerOrder,
    };
    await remoteDataSource.sendGameAction(action);
  }

  @override
  Stream<dynamic> getGameUpdates() {
    return remoteDataSource.getGameUpdates();
  }

  @override
  Stream<dynamic> getTurnUpdates() {
    return remoteDataSource.getTurnUpdates();
  }

  @override
  Stream<dynamic> getPlayerJoinedUpdates() {
    return remoteDataSource.getPlayerJoinedUpdates();
  }

  @override
  Stream<dynamic> getGameActions() {
    return remoteDataSource.getGameActions();
  }
}
