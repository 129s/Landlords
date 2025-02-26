import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network_services/chat_service.dart';
import 'package:landlords_3/core/network_services/game_service.dart';
import 'package:landlords_3/core/network_services/room_service.dart';

final roomServiceProvider = Provider<RoomService>((ref) => RoomService());
final gameServiceProvider = Provider<GameService>((ref) => GameService());
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());
