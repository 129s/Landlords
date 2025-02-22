// domain/repositories/room_repo.dart
import 'package:landlords_3/domain/entities/room_model.dart';

abstract class RoomRepository {
  /// 创建房间
  Future<void> createRoom(String roomName);

  /// 加入房间
  Future<void> joinRoom(String roomId);

  /// 监听房间列表更新
  Stream<List<RoomModel>> watchRooms();
}
