import 'package:landlords_3/domain/entities/room_model.dart';

abstract class RoomRepository {
  Future<void> createRoom(String playerName);
  Future<void> joinRoom(String roomId, String playerName);
  Stream<List<RoomModel>> watchRooms();
}
