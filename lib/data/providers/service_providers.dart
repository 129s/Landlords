import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network/chat_service.dart';
import 'package:landlords_3/core/network/game_service.dart';
import 'package:landlords_3/core/network/room_service.dart';

final roomServiceProvider = Provider<RoomService>((ref) => RoomService());
final gameServiceProvider = Provider<GameService>((ref) => GameService());
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final gameUpdatesProvider = StreamProvider.autoDispose((ref) {
  return ref.watch(gameServiceProvider).onPlayCards;
});

final playerUpdatesProvider = StreamProvider.autoDispose((ref) {
  return ref.watch(gameServiceProvider).onPlayerStateUpdate;
});
