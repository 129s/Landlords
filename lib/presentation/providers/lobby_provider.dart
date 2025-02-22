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
  final bool isGaming;

  const LobbyState({
    this.rooms = const [],
    this.playerName,
    this.isLoading = false,
    this.isGaming = false,
  });

  LobbyState copyWith({
    List<RoomModel>? rooms,
    String? playerName,
    bool? isLoading,
    bool? isGaming,
  }) {
    return LobbyState(
      rooms: rooms ?? this.rooms,
      playerName: playerName ?? this.playerName,
      isLoading: isLoading ?? this.isLoading,
      isGaming: isGaming ?? this.isGaming,
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
    if (state.isGaming) {
      // 如果正在游戏中，则阻止创建房间
      return false;
    }
    await _repository.createRoom(state.playerName!);
    state = state.copyWith(isGaming: true); // 创建房间后设置为 true
    return true;
  }

  // 修改加入房间方法
  Future<bool> joinRoom(String roomId) async {
    if (!hasPlayerName()) {
      return false;
    }
    if (state.isGaming) {
      // 如果正在游戏中，则阻止加入房间
      return false;
    }
    _repository.joinRoom(roomId, state.playerName!);
    state = state.copyWith(isGaming: true); // 加入房间后设置为 true
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

  // 添加退出游戏的方法
  void exitGame() {
    state = state.copyWith(isGaming: false); // 退出游戏后设置为 false
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
