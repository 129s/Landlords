import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/data/providers/repo_providers.dart';
import 'package:landlords_3/domain/entities/room_model.dart';
import 'package:landlords_3/domain/repositories/room_repo.dart';
import 'package:landlords_3/presentation/widgets/player_name_dialog.dart';

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

  // 创建房间
  Future<bool> createRoom() async {
    if (!hasPlayerName()) return false;

    if (state.isGaming) {
      // 如果正在游戏中，则阻止创建房间
      return false;
    }
    await _repository.createRoom();
    state = state.copyWith(isGaming: true); // 创建房间后设置为 true
    return true;
  }

  // 加入房间
  Future<bool> joinRoom(String roomId) async {
    if (!hasPlayerName()) return false;
    await _repository.joinRoom(roomId);
    // 新增房间列表刷新
    _repository.watchRooms().listen((rooms) {
      state = state.copyWith(rooms: rooms);
    });
    state = state.copyWith(isGaming: true);
    return true;
  }

  // 验证玩家名
  Future<bool> validatePlayerName(BuildContext context) async {
    if (hasPlayerName()) return true;

    final completer = Completer<bool>();
    showDialog(
      context: context,
      builder:
          (context) => PlayerNameDialog(
            title: '设置玩家名',
            onConfirm: (name) {
              setPlayerName(name);
              completer.complete(true);
            },
            onCancel: () => completer.complete(false),
          ),
    );

    return completer.future;
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

  void exitGame() {
    _roomSubscription?.cancel(); // 取消现有订阅
    _roomSubscription = _repository.watchRooms().listen((rooms) {
      state = state.copyWith(rooms: rooms, isGaming: false);
    });
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }
}

final lobbyProvider = StateNotifierProvider<LobbyNotifier, LobbyState>((ref) {
  final repository = ref.watch(roomRepoProvider);
  return LobbyNotifier(repository);
});
