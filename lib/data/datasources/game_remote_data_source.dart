// 远程数据源接口
abstract class GameRemoteDataSource {
  Future<String> createRoom(String playerName);
  Future<void> joinRoom(String roomId, String playerName);
  Future<int> getPlayerOrder();
  Future<void> sendGameAction(Map<String, dynamic> action);
  Stream<dynamic> getGameUpdates();
  Stream<dynamic> getTurnUpdates();
  Stream<dynamic> getPlayerJoinedUpdates();
  Stream<dynamic> getGameActions();
}
