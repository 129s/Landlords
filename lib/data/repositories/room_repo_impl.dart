import 'dart:async';
import 'package:landlords_3/core/network/chat_service.dart';
import 'package:landlords_3/core/network/room_service.dart';
import 'package:landlords_3/data/datasources/remote/dto/poker_dto.dart';
import 'package:landlords_3/domain/entities/message_model.dart';
import 'package:landlords_3/domain/entities/player_model.dart';
import 'package:landlords_3/domain/entities/poker_model.dart';
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
  Future<void> requestRooms() async {
    _roomService.requestRooms();
  }

  @override
  Future<void> leaveRoom() async {
    _roomService.leaveRoom();
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

  @override
  Future<RoomModel> getRoomDetails(String roomId) async {
    _roomService.requestRoomDetails(roomId);
    final rooms = await _roomService.roomUpdates.first;
    final roomDTO = rooms.firstWhere(
      (room) => room.id == roomId,
      orElse: () => throw Exception('Room $roomId not found'),
    );
    return roomDTO;
  }

  @override
  Stream<List<PlayerModel>> get onPlayerUpdate {
    return _roomService.playerUpdateStream.map(
      (dtos) => dtos.map((d) => d.toModel()).toList(),
    );
  }

  @override
  Stream<List<PokerModel>> get onPlayCards {
    return _roomService.playCardsStream.map(
      (cardDTOs) => cardDTOs.map((c) => c.toModel()).toList(),
    );
  }

  @override
  Future<void> playCards(String roomId, List<PokerModel> cards) async {
    final pokerDTOs =
        cards.map((poker) {
          final suitStr = poker.suit.toString().split('.').last.toLowerCase();
          final valueStr = poker.value.toString().split('.').last.toLowerCase();
          return PokerDTO(suit: suitStr, value: valueStr);
        }).toList();
    _roomService.emitPlayCards(roomId, pokerDTOs);
  }
}
