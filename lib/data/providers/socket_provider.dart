import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network/socket_manager.dart';

final socketManagerProvider = Provider<SocketManager>((ref) {
  return SocketManager();
});

final connectionStateProvider = StreamProvider<GameConnectionState>((ref) {
  return ref.watch(socketManagerProvider).connectionStream;
});
