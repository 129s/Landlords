import 'package:landlords_3/data/datasources/game_remote_data_source.dart';
import 'package:landlords_3/data/models/poker_model.dart';
import 'package:landlords_3/data/repositories/game_repository.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';

class GameRepositoryImpl implements GameRepository {
  final GameRemoteDataSource remoteDataSource;

  GameRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> createRoom(String playerName) =>
      remoteDataSource.createRoom(playerName);

  @override
  Future<void> joinRoom(String roomId, String playerName) =>
      remoteDataSource.joinRoom(roomId, playerName);

  @override
  Stream<dynamic> getGameUpdates() => remoteDataSource.getGameUpdates();

  @override
  Future<int> getPlayerOrder() => remoteDataSource.getPlayerOrder();

  @override
  Future<void> playCards(
    List<PokerData> cards,
    String roomId,
    int playerOrder,
  ) {
    final models = cards.map((e) => PokerModel.fromEntity(e)).toList();
    return remoteDataSource.playCards(models, roomId, playerOrder);
  }
}
