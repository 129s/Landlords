import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/domain/entities/room_model.dart';

class LobbyState {
  final List<RoomModel> rooms;
  final String? playerName;
  final bool isLoading;

  const LobbyState({
    this.rooms = const [],
    this.playerName,
    this.isLoading = false,
  });

  LobbyState copyWith({
    List<RoomModel>? rooms,
    String? playerName,
    bool? isLoading,
  }) {
    return LobbyState(
      rooms: rooms ?? this.rooms,
      playerName: playerName ?? this.playerName,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LobbyNotifier extends StateNotifier<LobbyState> {
  LobbyNotifier() : super(const LobbyState());

  // 更新房间列表
  void updateRooms(List<RoomModel> rooms) {
    state = state.copyWith(rooms: rooms);
  }

  // 设置玩家名称
  void setPlayerName(String name) {
    state = state.copyWith(playerName: name);
  }

  // 切换加载状态
  void toggleLoading() {
    state = state.copyWith(isLoading: !state.isLoading);
  }
}

final lobbyProvider = StateNotifierProvider<LobbyNotifier, LobbyState>((ref) {
  return LobbyNotifier();
});
