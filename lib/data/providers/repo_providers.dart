import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network/chat_service.dart';
import 'package:landlords_3/core/network/room_service.dart';
import 'package:landlords_3/data/repositories/room_repo_impl.dart';
import 'package:landlords_3/domain/repositories/room_repo.dart';

final roomServiceProvider = Provider<RoomService>((ref) {
  return RoomService();
});

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

final roomRepoProvider = Provider<RoomRepository>((ref) {
  return RoomRepoImpl(
    roomService: ref.read(roomServiceProvider),
    chatService: ref.read(chatServiceProvider),
  );
});
