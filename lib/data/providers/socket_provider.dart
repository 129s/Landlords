import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network/socket_service.dart';

final socketConnectionProvider = StreamProvider<GameConnectionState>((ref) {
  return SocketService().connectionStream;
});
