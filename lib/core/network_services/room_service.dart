import 'dart:async';

import 'package:landlords_3/core/network_services/constants/constants.dart';
import 'package:landlords_3/core/network_services/socket_service.dart';
import 'package:landlords_3/data/models/room.dart';
import 'package:logger/logger.dart';

/// RoomService 类：
///
/// 单例类，用于管理房间相关的 Socket 事件和数据。
/// 它依赖于 SocketService 来进行底层的 Socket 通信。
///
/// 主要功能：
///   - 提供加入房间、离开房间、创建房间等方法，并发送相应的 Socket 事件。
///   - 监听服务器发送的房间相关事件，如房间状态更新、玩家加入/离开等。
///   - 提供房间数据的流，以便其他组件可以监听房间数据的变化。
///   - 提供房间列表和当前房间的属性，并提供刷新房间列表的方法。
///
/// 使用方式：
///   - 通过 RoomService() 获取单例实例。
///   - 使用 joinRoom()、leaveRoom()、createRoom() 等方法进行房间操作。
///   - 使用 roomDataStream 监听房间数据的变化。
///   - 使用 refreshRoomList() 获取最新的房间列表。
///   - 通过 roomList 和 currentRoom 属性访问房间列表和当前房间。

class RoomService {
  final _logger = Logger();
  final SocketService _socketService = SocketService();

  // 房间列表
  List<Room> _roomList = [];
  // 当前房间
  Room? _currentRoom;

  // 流控制
  final _roomListController = StreamController<List<Room>>.broadcast();
  final _currentRoomController = StreamController<Room?>.broadcast();

  // get
  Stream<List<Room>> get roomListStream => _roomListController.stream;
  Stream<Room?> get currentRoomStream => _currentRoomController.stream;
  List<Room> get roomList => _roomList;
  Room? get currentRoom => _currentRoom;

  // 单例
  static final _instance = RoomService._internal();
  RoomService._internal() {
    _setupEventListeners();
  }
  factory RoomService() => _instance;

  // 初始化事件监听器
  void _setupEventListeners() {
    _socketService.on<Map<String, dynamic>>('room_update', _handleRoomUpdate);
    _socketService.on<Map<String, dynamic>>(
      'player_joined',
      _handlePlayerJoined,
    );
    _socketService.on<Map<String, dynamic>>('player_left', _handlePlayerLeft);
    _socketService.on<List<dynamic>>('room_list', _handleRoomList);
    // 添加其他房间相关的事件监听器
  }

  // 处理房间更新事件
  void _handleRoomUpdate(Map<String, dynamic> data) {
    try {
      _currentRoom = Room.fromJson(data);
      _currentRoomController.add(_currentRoom);
      _logger.i('Room updated: ${_currentRoom?.toJson()}');
    } catch (e) {
      _logger.e('Error parsing room update: $e');
    }
  }

  // 处理玩家加入事件
  void _handlePlayerJoined(Map<String, dynamic> data) {
    try {
      // Assuming the server sends the updated room data after a player joins
      _currentRoom = Room.fromJson(data);
      _currentRoomController.add(_currentRoom);
      _logger.i('Player joined room: ${_currentRoom?.toJson()}');
    } catch (e) {
      _logger.e('Error parsing player joined event: $e');
    }
  }

  // 处理玩家离开事件
  void _handlePlayerLeft(Map<String, dynamic> data) {
    try {
      // Assuming the server sends the updated room data after a player leaves
      _currentRoom = Room.fromJson(data);
      _currentRoomController.add(_currentRoom);
      _logger.i('Player left room: ${_currentRoom?.toJson()}');
    } catch (e) {
      _logger.e('Error parsing player left event: $e');
    }
  }

  // 处理房间列表事件
  void _handleRoomList(List<dynamic> data) {
    try {
      _roomList =
          data
              .map((item) => Room.fromJson(item as Map<String, dynamic>))
              .toList();
      _roomListController.add(_roomList);
      _logger.i('Room list updated: ${_roomList.length} rooms');
    } catch (e) {
      _logger.e('Error parsing room list: $e');
    }
  }

  // 加入房间
  void joinRoom(String roomId) {
    _socketService.emit('join_room', {'room_id': roomId});
    _logger.i('Joining room: $roomId');
  }

  // 离开房间
  void leaveRoom() {
    _socketService.emit('leave_room');
    _logger.i('Leaving room');
    _currentRoom = null; // Clear the current room when leaving
    _currentRoomController.add(null);
  }

  // 创建房间
  void createRoom() {
    _socketService.emit('create_room');
    _logger.i('Creating room');
  }

  // 刷新房间列表
  void refreshRoomList() {
    _socketService.emit('get_room_list');
    _logger.i('Refreshing room list');
  }

  // 释放资源
  void dispose() {
    _roomListController.close();
    _currentRoomController.close();
    // 移除所有事件监听器，避免内存泄漏
    _socketService.off('room_update');
    _socketService.off('player_joined');
    _socketService.off('player_left');
    _socketService.off('room_list');
    // 移除其他事件监听器
  }
}
