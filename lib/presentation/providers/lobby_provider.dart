import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/data/providers/service_providers.dart';
import 'package:landlords_3/domain/entities/room_model.dart';
import 'package:landlords_3/domain/repositories/room_repo.dart';
import 'package:landlords_3/presentation/pages/chat/chat_page.dart';
import 'package:landlords_3/presentation/widgets/player_name_dialog.dart';

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

  //如果成功则返回roomId,否则为null
  Future<String?> createAndJoinRoom() async {
    state = state.copyWith(isLoading: true);
    try {
      final roomId = await _repository.createRoom();
      return roomId;
    } catch (e) {
      print(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> joinExistingRoom(String roomId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.joinRoom(roomId);
      MaterialPageRoute(builder: (_) => ChatPage(roomId: roomId));
    } catch (e) {
      print(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void toggleLoading() {
    state = state.copyWith(isLoading: !state.isLoading);
  }

  void updateRooms(List<RoomModel> rooms) {
    state = state.copyWith(rooms: rooms);
  }

  void leaveRoom() {
    _repository.leaveRoom();
    _roomSubscription = _repository.watchRooms().listen((rooms) {
      state = state.copyWith(rooms: rooms);
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
