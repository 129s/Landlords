// presentation\providers\lobby_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network/socket_service.dart';
import 'package:landlords_3/data/providers/room_repo_providers.dart';
import 'package:landlords_3/domain/entities/room_model.dart';
import 'package:landlords_3/domain/repositories/room_repo.dart';
import 'package:landlords_3/presentation/providers/user_provider.dart'; // Import user provider

class LobbyState {
  final List<RoomModel> rooms;
  final bool isLoading;

  const LobbyState({this.rooms = const [], this.isLoading = false});

  LobbyState copyWith({List<RoomModel>? rooms, bool? isLoading}) {
    return LobbyState(
      rooms: rooms ?? this.rooms,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LobbyNotifier extends StateNotifier<LobbyState> {
  final RoomRepository _repository;
  final SocketService _socketService = SocketService(); // 获取 SocketService 实例
  final Ref ref; // Inject Ref
  StreamSubscription? _roomSubscription;

  LobbyNotifier(this._repository, this.ref) : super(const LobbyState()) {
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
  Future<void> createRoom(String roomName) async {
    await _repository.createRoom(roomName);
  }

  // 修改加入房间方法
  Future<void> joinRoom(String roomId) async {
    _repository.joinRoom(roomId);
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
  final repository = ref.watch(roomRepoProvider(ref)); // 注入依赖
  return LobbyNotifier(repository, ref);
});
