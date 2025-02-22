import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network/socket_service.dart';
import 'package:landlords_3/data/providers/room_repo_providers.dart';
import 'package:landlords_3/domain/entities/room_model.dart';
import 'package:landlords_3/domain/repositories/room_repo.dart';

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
  final RoomRepository _repository;
  final SocketService _socketService = SocketService(); // 获取 SocketService 实例
  StreamSubscription? _roomSubscription;

  LobbyNotifier(this._repository) : super(const LobbyState()) {
    _init();
  }

  void _init() {
    // 实时监听房间更新
    _roomSubscription = _repository.watchRooms().listen((rooms) {
      print('Received rooms from stream: $rooms');
      state = state.copyWith(rooms: rooms);
    });
  }

  // 修改创建房间方法
  Future<bool> createRoom() async {
    if (!hasPlayerName()) {
      return false;
    }
    await _repository.createRoom(state.playerName!);
    return true;
  }

  // 修改加入房间方法
  Future<bool> joinRoom(String roomId) async {
    if (!hasPlayerName()) {
      return false;
    }
    _repository.joinRoom(roomId, state.playerName!);
    return true;
  }

  bool hasPlayerName() {
    return state.playerName != null && state.playerName!.isNotEmpty;
  }

  void setPlayerName(String name) {
    state = state.copyWith(playerName: name);
  }

  void toggleLoading() {
    state = state.copyWith(isLoading: !state.isLoading);
  }

  void updateRooms(List<RoomModel> rooms) {
    state = state.copyWith(rooms: rooms);
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _socketService.dispose(); // 释放 SocketService 资源
    super.dispose();
  }
}

final lobbyProvider = StateNotifierProvider<LobbyNotifier, LobbyState>((ref) {
  final repository = ref.watch(roomRepoProvider); // 注入依赖
  return LobbyNotifier(repository);
});
