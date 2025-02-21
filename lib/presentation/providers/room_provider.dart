import 'package:flutter_riverpod/flutter_riverpod.dart';

final roomProvider = StateNotifierProvider<RoomNotifier, List<Player>>((ref) {
  return RoomNotifier();
});

class RoomNotifier extends StateNotifier<List<Player>> {
  RoomNotifier() : super([]);

  void updatePlayers(List<dynamic> serverData) {
    state = serverData.map((p) => Player.fromJson(p)).toList();
  }
}
