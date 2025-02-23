import 'dart:async';
import 'package:landlords_3/core/network/chat_service.dart';
import 'package:landlords_3/core/network/room_service.dart';
import 'package:landlords_3/domain/entities/message_model.dart';
import 'package:landlords_3/domain/entities/room_model.dart';
import 'package:landlords_3/domain/repositories/room_repo.dart';

class RoomRepoImpl implements RoomRepository {
  final RoomService _roomService;
  final ChatService _chatService;

  RoomRepoImpl({
    required RoomService roomService,
    required ChatService chatService,
  }) : _roomService = roomService,
       _chatService = chatService;

  @override
  Future<String> createRoom() async {
    return _roomService.createRoom();
  }

  @override
  Future<void> joinRoom(String roomId) async {
    _roomService.joinRoom(roomId);
  }

  @override
  Future<void> leaveRoom(String roomId) async {
    _roomService.leaveRoom(roomId);
  }

  @override
  Stream<List<RoomModel>> watchRooms() {
    return _roomService.roomUpdates.map((dtos) => dtos.cast<RoomModel>());
  }

  @override
  Future<void> sendMessage(String roomId, String content) async {
    _chatService.sendMessage(roomId, content);
  }

  @override
  Stream<List<MessageModel>> watchMessages(String roomId) {
    return _chatService.messages.map((dtos) => dtos.cast<MessageModel>());
  }
}
