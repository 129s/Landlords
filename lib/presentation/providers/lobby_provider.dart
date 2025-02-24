import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network/room_service.dart';
import 'package:landlords_3/data/providers/service_providers.dart';
import 'package:landlords_3/data/models/room.dart';
import 'package:landlords_3/presentation/pages/chat/chat_page.dart';

class LobbyState {
  final List<Room> rooms;
  final String? playerName;
  final bool isLoading;

  const LobbyState({
    this.rooms = const [],
    this.playerName,
    this.isLoading = false,
  });

  LobbyState copyWith({
    List<Room>? rooms,
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
  final RoomService _roomService;
  StreamSubscription? _roomSubscription;

  LobbyNotifier(this._roomService) : super(const LobbyState()) {
    _init();
  }

  void _init() {
    // 实时监听房间更新
    _roomSubscription = _roomService.watchRooms().listen((rooms) {
      print('Received rooms from stream: $rooms');
      state = state.copyWith(rooms: rooms);
    });
  }

  Future<String> createAndJoinRoom() async {
    state = state.copyWith(isLoading: true);
    try {
      // 发送创建请求
      await _roomService.createRoom();

      print("\n1\n");
      // 等待房间创建成功事件
      final roomId = await _roomService.roomCreated.first;
      print("\n2\n");

      // 自动加入自己创建的房间
      await _roomService.joinRoom(roomId);

      return roomId;
    } catch (e) {
      throw Exception('房间创建失败: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> joinExistingRoom(String roomId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _roomService.joinRoom(roomId);
      MaterialPageRoute(builder: (_) => ChatPage(roomId: roomId));
    } catch (e) {
      print(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshRooms() async {
    final rooms = await _roomService.requestRooms();
    state = state.copyWith(rooms: rooms);
  }

  void toggleLoading() {
    state = state.copyWith(isLoading: !state.isLoading);
  }

  void updateRooms(List<Room> rooms) {
    state = state.copyWith(rooms: rooms);
  }

  void leaveRoom() {
    _roomService.leaveRoom();
  }
}

final lobbyProvider = StateNotifierProvider<LobbyNotifier, LobbyState>((ref) {
  final repository = ref.watch(roomServiceProvider);
  return LobbyNotifier(repository);
});
