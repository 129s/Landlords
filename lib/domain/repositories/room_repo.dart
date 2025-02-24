import 'package:landlords_3/domain/entities/message_model.dart';
import 'package:landlords_3/domain/entities/player_model.dart';
import 'package:landlords_3/domain/entities/poker_model.dart';
import 'package:landlords_3/domain/entities/room_model.dart';

abstract class RoomRepository {
  Future<String> createRoom();
  Future<void> joinRoom(String roomId);
  Future<void> requestRooms();
  Future<void> leaveRoom();
  Future<void> sendMessage(String roomId, String content);
  Stream<List<RoomModel>> watchRooms();
  Stream<List<MessageModel>> watchMessages(String roomId);
  Future<RoomModel> getRoomDetails(String roomId);
  Stream<List<PlayerModel>> get onPlayerUpdate;
  Stream<List<PokerModel>> get onPlayCards;
}
