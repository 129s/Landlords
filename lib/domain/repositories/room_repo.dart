import 'package:landlords_3/domain/entities/message_model.dart';
import 'package:landlords_3/domain/entities/room_model.dart';

abstract class RoomRepository {
  Future<String> createRoom();
  Future<void> joinRoom(String roomId);
  Future<void> requestRooms();
  Future<void> leaveRoom();
  Future<void> sendMessage(String roomId, String content);
  Stream<List<RoomModel>> watchRooms();
  Stream<List<MessageModel>> watchMessages(String roomId);
}
