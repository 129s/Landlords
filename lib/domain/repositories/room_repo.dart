import 'package:landlords_3/domain/entities/message_model.dart';
import 'package:landlords_3/domain/entities/room_model.dart';

abstract class RoomRepository {
  Future<void> createRoom(String playerName);
  Future<void> joinRoom(String roomId, String playerName);
  Future<void> sendMessage(String roomId, String content);
  Stream<List<RoomModel>> watchRooms();
  Future<void> loadMessageHistory(String roomId);
  Stream<List<MessageModel>> watchMessages(String roomId);
}
