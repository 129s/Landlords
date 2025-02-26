import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/services/constants.dart';
import 'package:landlords_3/core/services/socket_service.dart';

final socketManagerProvider = Provider<SocketService>((ref) {
  return SocketService();
});

final connectionStateProvider = StreamProvider<GameConnectionState>((ref) {
  return ref.watch(socketManagerProvider).connectionStream;
});
